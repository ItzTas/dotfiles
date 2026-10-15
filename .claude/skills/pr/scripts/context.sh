#!/usr/bin/env bash
# Gather everything /pr needs before opening a PR/MR: parsed arguments, branch
# and working-tree state, open PRs/MRs on each forge and template files.
# Read-only: never switches branches, commits, pushes or creates anything.
set -euo pipefail

FORGE_DETECT="$HOME/.claude/scripts/forge-detect.sh"
WORK="" # scratch dir, created in main and removed on exit

usage() {
  cat <<'EOF'
Usage: context.sh [target] [source] [merge|-merge|--merge]

`merge` (any spelling) is pulled out from anywhere; the remaining tokens are
target then source (source defaults to the current branch).

Prints: {"current_branch","target","source","source_given","switch_needed",
  "merge","merge_ambiguous","extra_args":[...],
  "source_exists":{"local","remote"},"upstream","ahead","behind",
  "dirty":{"clean","staged","unstaged","untracked","conflicted","files":[...]},
  "forges":{"github":{remote,host,slug,url}|null,"gitlab":...,"cli":{gh,glab}},
  "open":{"github":[{number,title,head,base,url,draft}],"gitlab":[...]} (30 newest),
  "open_total":{"github":N,"gitlab":N},
  "existing_from_source":{"github":{...}|null,"gitlab":{...}|null},
  "same_target":{"github":[numbers],"gitlab":[numbers]} (open against target),
  "templates":{"github":[paths],"gitlab":[paths]},"errors":[{"forge","error"}]}

target is null when not given (ask; never assume main/master). merge_ambiguous
is true when a bare `merge` was passed and a branch named `merge` exists.
Exit: 0 ok, 2 not a git repo / bad args.
EOF
}

# Echoes the JSON of the remote to use for a forge: origin if it is one, else the first.
pick_remote() {
  jq -c --arg f "$1" '.[$f] | (map(select(.remote == "origin")) + .)[0]' <<<"$2"
}

branch_exists_local() { git show-ref --verify --quiet "refs/heads/$1"; }

branch_exists_remote() {
  [[ -n $(git for-each-ref --format='%(refname)' "refs/remotes/*/$1") ]]
}

dirty_json() {
  git status --porcelain=v1 | jq -Rsc '
    split("\n") | map(select(. != "")) as $l
    | {clean: ($l | length == 0),
       staged: ($l | map(select(.[0:1] | test("[MADRC]"))) | length),
       unstaged: ($l | map(select(.[1:2] | test("[MD]"))) | length),
       untracked: ($l | map(select(startswith("??"))) | length),
       conflicted: ($l | map(select(.[0:2] | test("^(DD|AU|UD|UA|DU|AA|UU)$"))) | length),
       files: $l[0:30]}'
}

# Echoes {"upstream","ahead","behind"} for a local branch.
tracking_json() {
  local branch=$1 upstream counts
  branch_exists_local "$branch" || {
    echo '{"upstream":null,"ahead":null,"behind":null}'
    return 0
  }
  upstream=$(git rev-parse --abbrev-ref --symbolic-full-name "$branch@{u}" 2>/dev/null) || upstream=""
  [[ -n $upstream ]] || {
    echo '{"upstream":null,"ahead":null,"behind":null}'
    return 0
  }
  counts=$(git rev-list --left-right --count "$upstream...$branch")
  jq -nc --arg u "$upstream" --argjson behind "${counts%%[[:space:]]*}" --argjson ahead "${counts##*[[:space:]]}" \
    '{upstream: $u, ahead: $ahead, behind: $behind}'
}

github_open() {
  local remote=$1
  gh pr list -R "$(jq -r '"\(.host)/\(.slug)"' <<<"$remote")" --state open --limit 100 \
    --json number,title,headRefName,baseRefName,url,isDraft |
    jq -c 'map({number, title, head: .headRefName, base: .baseRefName, url, draft: .isDraft})'
}

gitlab_open() {
  local remote=$1 host project
  host=$(jq -r .host <<<"$remote")
  project=$(jq -r '.slug | @uri' <<<"$remote")
  glab api --hostname "$host" "projects/$project/merge_requests?state=opened&per_page=100" |
    jq -c 'map({number: .iid, title, head: .source_branch, base: .target_branch, url: .web_url, draft})'
}

# Writes {"<forge>": [...]} or {"error": ...} to $out for one forge.
open_for() {
  local forge=$1 remote=$2 out=$3 list
  [[ $remote != null ]] || {
    echo '[]' >"$out"
    return 0
  }
  if list=$("${forge}_open" "$remote" 2>"$out.err"); then
    echo "$list" >"$out"
    return 0
  fi
  jq -nc --arg f "$forge" --arg e "$(tail -n 3 "$out.err")" '{error: {forge: $f, error: $e}}' >"$out"
}

templates_json() {
  local root=$1
  # find exits 1 for the directories that don't exist; that's expected here.
  {
    find "$root" "$root/.github" "$root/docs" -maxdepth 1 -type f -iname 'pull_request_template.md' 2>/dev/null |
      sed 's/^/github\t/' || true
    find "$root/.github" -maxdepth 2 -type f -ipath '*/.github/pull_request_template/*.md' 2>/dev/null |
      sed 's/^/github\t/' || true
    find "$root/.gitlab/merge_request_templates" -maxdepth 1 -type f -name '*.md' 2>/dev/null |
      sed 's/^/gitlab\t/' || true
  } | jq -Rsc --arg root "$root/" '
    split("\n") | map(select(. != "") | split("\t") | {forge: .[0], path: (.[1] | ltrimstr($root))})
    | {github: map(select(.forge == "github") | .path) | unique,
       gitlab: map(select(.forge == "gitlab") | .path) | unique}'
}

main() {
  local positional=() merge=false bare_merge=false
  while (($#)); do
    case "$1" in
      -h | --help) usage && return 0 ;;
      merge) merge=true bare_merge=true ;;
      -merge | --merge) merge=true ;;
      *) positional+=("$1") ;;
    esac
    shift
  done

  local ctx root current target source
  ctx=$("$FORGE_DETECT") || exit 2
  root=$(jq -r .repo_root <<<"$ctx")
  current=$(git branch --show-current)
  target=${positional[0]:-}
  source=${positional[1]:-$current}

  local ambiguous=false
  if [[ $bare_merge == true ]] && { branch_exists_local merge || branch_exists_remote merge; }; then
    ambiguous=true
  fi

  local gh_remote gl_remote
  gh_remote=$(pick_remote github "$ctx")
  gl_remote=$(pick_remote gitlab "$ctx")
  WORK=$(mktemp -d)
  trap 'rm -rf "${WORK:?}"' EXIT
  open_for github "$gh_remote" "$WORK/github.json" &
  local gh_pid=$!
  open_for gitlab "$gl_remote" "$WORK/gitlab.json" &
  local gl_pid=$!

  local dirty tracking templates exists_local=false exists_remote=false
  dirty=$(dirty_json)
  tracking=$(tracking_json "$source")
  templates=$(templates_json "$root")
  [[ -n $source ]] && branch_exists_local "$source" && exists_local=true
  [[ -n $source ]] && branch_exists_remote "$source" && exists_remote=true
  wait "$gh_pid" "$gl_pid"

  jq -nc \
    --arg current "$current" --arg target "$target" --arg source "$source" \
    --argjson source_given "$([[ -n ${positional[1]:-} ]] && echo true || echo false)" \
    --argjson merge "$merge" --argjson ambiguous "$ambiguous" \
    --argjson extra "$(jq -nc '$ARGS.positional[2:]' --args "${positional[@]}")" \
    --argjson exists_local "$exists_local" --argjson exists_remote "$exists_remote" \
    --argjson dirty "$dirty" --argjson tracking "$tracking" --argjson templates "$templates" \
    --argjson gh_remote "$gh_remote" --argjson gl_remote "$gl_remote" \
    --argjson cli "$(jq -c .cli <<<"$ctx")" \
    --slurpfile gh "$WORK/github.json" --slurpfile gl "$WORK/gitlab.json" '
    def nonempty: if . == "" then null else . end;
    def list(x): if (x | type) == "array" then x else [] end;
    def mine(x): list(x) | map(select(.head == $source)) | first // null;
    def others(x): if $target == "" then [] else list(x) | map(select(.base == $target and .head != $source) | .number) end;
    {current_branch: ($current | nonempty), target: ($target | nonempty), source: ($source | nonempty),
     source_given: $source_given, switch_needed: ($source != $current),
     merge: $merge, merge_ambiguous: $ambiguous, extra_args: $extra,
     source_exists: {local: $exists_local, remote: $exists_remote}}
    + $tracking
    + {dirty: $dirty,
       forges: {github: $gh_remote, gitlab: $gl_remote, cli: $cli},
       open: {github: list($gh[0])[0:30], gitlab: list($gl[0])[0:30]},
       open_total: {github: (list($gh[0]) | length), gitlab: (list($gl[0]) | length)},
       existing_from_source: {github: mine($gh[0]), gitlab: mine($gl[0])},
       same_target: {github: others($gh[0]), gitlab: others($gl[0])},
       templates: $templates,
       errors: [$gh[0], $gl[0] | objects | .error]}'
}

main "$@"
