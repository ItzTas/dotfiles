#!/usr/bin/env bash
# Fetch the review feedback of this branch's PR (GitHub) and/or MR (GitLab):
# review threads, top-level conversation comments and review summaries, as one
# JSON object. Read-only.
set -euo pipefail

FORGE_DETECT="$HOME/.claude/scripts/forge-detect.sh"
WORK="" # scratch dir, created in main and removed on exit

usage() {
  cat <<'EOF'
Usage: fetch.sh [pr/mr number | url] [--forge github|gitlab] [--all]
                [-R [host/]owner/repo]

No number: the open PR/MR whose source is the current branch, on every forge
remote (origin first). A number is looked up on each forge present (or
--forge); a PR/MR URL picks its forge and repo.
Resolved and outdated threads (and minimized comments, dismissed reviews) are
skipped and counted unless --all is given.

Prints: {"branch","results":[{"forge","repo","number","url","title","state",
  "head","base","threads":[{"id","resolved","outdated","path","line",
  "comments":[{"author","bot","body","url","created_at"}]}],
  "conversation":[{"id","author","bot","body","url","created_at"}],
  "reviews":[{"id","author","state","body","url","submitted_at"}],
  "skipped":{"resolved","outdated","minimized"},"truncated"}],
  "not_found":[forges],"errors":[{"forge","error"}]}
Thread ids feed respond.sh (GitHub: review-thread node id; GitLab: discussion
id, together with the MR number).

Exit: 0 found, 1 no open PR/MR found, 2 error.
EOF
}

die() {
  echo "fetch: $*" >&2
  exit 2
}

split_repo_arg() {
  local forge=$1 value=$2 first=${2%%/*}
  local -A default_host=([github]=github.com [gitlab]=gitlab.com)
  [[ $first == *.* ]] && printf '%s\t%s' "$first" "${value#*/}" && return 0
  printf '%s\t%s' "${default_host[$forge]}" "$value"
}

# Echoes "forge<TAB>host<TAB>slug<TAB>number" for a PR/MR URL.
parse_url() {
  local url=$1
  [[ $url =~ ^https?://([^/]+)/([^/]+/[^/]+)/pull/([0-9]+) ]] &&
    printf 'github\t%s\t%s\t%s' "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}" "${BASH_REMATCH[3]}" && return 0
  [[ $url =~ ^https?://([^/]+)/(.+)/-/merge_requests/([0-9]+) ]] &&
    printf 'gitlab\t%s\t%s\t%s' "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}" "${BASH_REMATCH[3]}" && return 0
  return 1
}

# --- GitHub -----------------------------------------------------------------

# GraphQL variables, not shell ones.
# shellcheck disable=SC2016
GH_QUERY='query($owner: String!, $name: String!, $number: Int!) {
  repository(owner: $owner, name: $name) {
    pullRequest(number: $number) {
      number url title state headRefName baseRefName
      reviewThreads(first: 100) {
        pageInfo { hasNextPage }
        nodes {
          id isResolved isOutdated path line originalLine
          comments(first: 50) { nodes { author { __typename login } body url createdAt } }
        }
      }
      comments(first: 100) {
        pageInfo { hasNextPage }
        nodes { id author { __typename login } body url createdAt isMinimized }
      }
      reviews(first: 100) {
        pageInfo { hasNextPage }
        nodes { id author { __typename login } state body url submittedAt }
      }
    }
  }
}'

github_find() {
  local host=$1 slug=$2 branch=$3
  gh pr list -R "$host/$slug" --head "$branch" --state open --limit 1 --json number --jq '.[0].number // empty'
}

github_fetch() {
  local host=$1 slug=$2 number=$3 all=$4
  gh api graphql --hostname "$host" -f query="$GH_QUERY" \
    -f owner="${slug%%/*}" -f name="${slug#*/}" -F number="$number" |
    jq -c --arg repo "$host/$slug" --argjson all "$all" '
      def who: {author: (.author.login // "ghost"), bot: (.author.__typename == "Bot")};
      .data.repository.pullRequest as $pr
      | $pr.reviewThreads.nodes as $threads
      | {forge: "github", repo: $repo, number: $pr.number, url: $pr.url, title: $pr.title,
         state: $pr.state, head: $pr.headRefName, base: $pr.baseRefName,
         threads: [$threads[] | select($all or ((.isResolved or .isOutdated) | not))
           | {id, resolved: .isResolved, outdated: .isOutdated, path, line: (.line // .originalLine),
              comments: [.comments.nodes[] | who + {body, url, created_at: .createdAt}]}],
         conversation: [$pr.comments.nodes[] | select($all or (.isMinimized | not))
           | {id} + who + {body, url, created_at: .createdAt}],
         reviews: [$pr.reviews.nodes[]
           | select(.body != "" or .state == "CHANGES_REQUESTED")
           | select($all or .state != "DISMISSED")
           | {id} + who + {state, body, url, submitted_at: .submittedAt}],
         skipped: (if $all then {resolved: 0, outdated: 0, minimized: 0} else
           {resolved: ($threads | map(select(.isResolved)) | length),
            outdated: ($threads | map(select(.isOutdated and (.isResolved | not))) | length),
            minimized: ($pr.comments.nodes | map(select(.isMinimized)) | length)} end),
         truncated: ([$pr.reviewThreads, $pr.comments, $pr.reviews] | any(.pageInfo.hasNextPage))}'
}

# --- GitLab -----------------------------------------------------------------

gitlab_find() {
  local host=$1 slug=$2 branch=$3
  glab api --hostname "$host" \
    "projects/$(jq -rn --arg s "$slug" '$s | @uri')/merge_requests?source_branch=$(jq -rn --arg s "$branch" '$s | @uri')&state=opened&per_page=1" |
    jq -r '.[0].iid // empty'
}

gitlab_fetch() {
  local host=$1 slug=$2 number=$3 all=$4 project base mr_pid disc_rc=0
  project=$(jq -rn --arg s "$slug" '$s | @uri')
  base="projects/$project/merge_requests/$number"
  glab api --hostname "$host" "$base" >"$WORK/mr-$number.json" &
  mr_pid=$!
  glab api --hostname "$host" --paginate "$base/discussions?per_page=100" >"$WORK/disc-$number.json" || disc_rc=$?
  wait "$mr_pid" || return 1
  ((disc_rc == 0)) || return 1
  jq -s -c --arg repo "$host/$slug" --argjson all "$all" --slurpfile mr "$WORK/mr-$number.json" '
    def who: {author: .author.username, bot: (.author.bot // null)};
    def note: who + {body, url: "\($mr[0].web_url)#note_\(.id)", created_at};
    (add // []) | map(.notes |= map(select(.system | not)) | select(.notes | length > 0)) as $all_disc
    | ($all_disc | map(select(any(.notes[]; .resolvable)))) as $threads
    | ($threads | map(. + {resolved: all(.notes[] | select(.resolvable); .resolved)})) as $threads
    | $mr[0] as $m
    | {forge: "gitlab", repo: $repo, number: $m.iid, url: $m.web_url, title: $m.title,
       state: $m.state, head: $m.source_branch, base: $m.target_branch,
       threads: [$threads[] | select($all or (.resolved | not))
         | (.notes[0].position // {}) as $pos
         | {id, resolved, outdated: null, path: ($pos.new_path // $pos.old_path),
            line: ($pos.new_line // $pos.old_line), comments: [.notes[] | note]}],
       conversation: [$all_disc[] | select(any(.notes[]; .resolvable) | not) | .id as $did
         | .notes[] | {id: $did} + note],
       reviews: [],
       skipped: {resolved: (if $all then 0 else $threads | map(select(.resolved)) | length end),
                 outdated: 0, minimized: 0},
       truncated: false}' "$WORK/disc-$number.json"
}

# --- dispatch ---------------------------------------------------------------

# Writes {"result"}, {"not_found"} or {"error"} for one forge to $out.
query_forge() {
  local forge=$1 host=$2 slug=$3 number=$4 branch=$5 all=$6 out=$7 result
  if [[ -z $number ]]; then
    number=$("${forge}_find" "$host" "$slug" "$branch" 2>"$out.err") || number="ERR"
  fi
  if [[ $number == ERR ]]; then
    jq -nc --arg f "$forge" --arg e "$(tail -n 3 "$out.err")" '{error: {forge: $f, error: $e}}' >"$out"
    return 0
  fi
  if [[ -z $number ]]; then
    jq -nc --arg f "$forge" '{not_found: $f}' >"$out"
    return 0
  fi
  if result=$("${forge}_fetch" "$host" "$slug" "$number" "$all" 2>"$out.err"); then
    jq -nc --argjson r "$result" '{result: $r}' >"$out"
    return 0
  fi
  if grep -q '404' "$out.err"; then
    jq -nc --arg f "$forge" '{not_found: $f}' >"$out"
    return 0
  fi
  jq -nc --arg f "$forge" --arg e "$(tail -n 3 "$out.err")" '{error: {forge: $f, error: $e}}' >"$out"
}

main() {
  local arg="" only="" all=false repo_arg=""
  while (($#)); do
    case "$1" in
      -h | --help) usage && return 0 ;;
      --all) all=true ;;
      --forge) shift && only=${1:?--forge needs github|gitlab} ;;
      -R | --repo) shift && repo_arg=${1:?-R needs [host/]owner/repo} ;;
      -*) die "unknown flag: $1" ;;
      *)
        [[ -z $arg ]] || die "unexpected argument: $1"
        arg=$1
        ;;
    esac
    shift
  done

  local ctx branch targets=() forge target parsed
  ctx=$("$FORGE_DETECT") || exit 2
  branch=$(jq -r '.branch // empty' <<<"$ctx")
  if [[ $arg == http* ]]; then
    parsed=$(parse_url "$arg") || die "not a PR/MR URL: $arg"
    targets=("$parsed")
  else
    [[ -z $arg || $arg =~ ^[0-9]+$ ]] || die "PR/MR number must be numeric or a URL: $arg"
    [[ -n $arg || -n $branch ]] || die "detached HEAD: pass a PR/MR number"
    for forge in github gitlab; do
      [[ -z $only || $only == "$forge" ]] || continue
      if [[ -n $repo_arg ]]; then
        target=$(split_repo_arg "$forge" "$repo_arg")
      else
        target=$(jq -r --arg f "$forge" '.[$f] | (map(select(.remote == "origin")) + .)[0] // empty
          | "\(.host)\t\(.slug)"' <<<"$ctx")
      fi
      [[ -n $target ]] && targets+=("$forge"$'\t'"$target"$'\t'"$arg")
    done
  fi
  ((${#targets[@]})) || die "no GitHub/GitLab remote found (pass -R or a URL)"

  local t n=0 pids=() host slug number
  WORK=$(mktemp -d)
  trap 'rm -rf "${WORK:?}"' EXIT
  for t in "${targets[@]}"; do
    IFS=$'\t' read -r forge host slug number <<<"$t"
    query_forge "$forge" "$host" "$slug" "$number" "$branch" "$all" "$WORK/q$n.json" &
    pids+=($!)
    n=$((n + 1))
  done
  wait "${pids[@]}"

  local out
  out=$(jq -cs --arg branch "$branch" '
    {branch: ($branch | if . == "" then null else . end),
     results: map(.result // empty), not_found: map(.not_found // empty), errors: map(.error // empty)}' \
    "$WORK"/q[0-9]*.json)
  echo "$out"
  jq -e '.results | length > 0' <<<"$out" >/dev/null && return 0
  jq -e '.errors | length > 0' <<<"$out" >/dev/null && return 2
  return 1
}

main "$@"
