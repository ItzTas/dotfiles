#!/usr/bin/env bash
# Lists the local branches /prune-branches may delete: merged into the base (safe
# `git branch -d`) and upstream gone (needs `git branch -D`). Never deletes
# anything; the only write is `git fetch --all --prune`, which just refreshes the
# local remote-tracking refs.
set -euo pipefail

# skills/prune-branches/scripts/ -> ~/.claude/scripts/forge-detect.sh
FORGE_DETECT="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/../../../scripts/forge-detect.sh"
NEVER_DELETE=(main master dev develop pre-homolog)
SEP=$'\x1f'

usage() {
  cat <<'EOF'
Usage: candidates.sh [base] [--no-fetch] [--check-prs]

Runs `git fetch --all --prune` (unless --no-fetch), then prints JSON:
  {"base", "base_ref", "base_source": "argument"|"origin/HEAD"|"fallback",
   "current", "fetch": "ok"|"failed"|"skipped",
   "protected": [{"branch", "reason"}],
   "merged": [{"branch", "upstream", "upstream_gone", "last_commit": {"date", "subject"}}],
   "gone":   [{"branch", "upstream", "last_commit": {...}, "pr"?}]}

base: the argument, else origin/HEAD, else main, else master. "merged" lists
branches fully merged into it (`git branch -d`); "gone" lists branches whose
upstream no longer exists and that are not merged (`git branch -D`). Never
listed: main, master, dev, develop, pre-homolog, the base, the current branch,
and branches checked out in another worktree (all reported in "protected").

--check-prs adds to each gone branch
  "pr": {"status": "merged"|"none"|"unknown", "number", "url", "notes": [...]}
looked up with gh/glab; a missing CLI or auth only yields "unknown".

Exit: 0 ok, 2 not a git repo / bad args / base not determinable or not found.
EOF
}

die() {
  echo "candidates: $1" >&2
  exit 2
}

ref_exists() {
  git rev-parse --verify --quiet "$1^{commit}" >/dev/null
}

# Echoes "<base><TAB><source>"; fails when no base can be determined.
pick_base() {
  local arg=$1 ref name
  [[ -n $arg ]] && printf '%s\targument' "$arg" && return 0
  if ref=$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null); then
    printf '%s\torigin/HEAD' "${ref#origin/}"
    return 0
  fi
  for name in main master; do
    ref_exists "refs/heads/$name" || ref_exists "refs/remotes/origin/$name" || continue
    printf '%s\tfallback' "$name"
    return 0
  done
  return 1
}

# The ref "merged" is measured against: the local branch, else the remote one.
resolve_base_ref() {
  local base=$1 candidate
  for candidate in "refs/heads/$base" "refs/remotes/$base" "refs/remotes/origin/$base"; do
    ref_exists "$candidate" || continue
    printf '%s' "$candidate"
    return 0
  done
  return 1
}

branches_json() {
  local fmt
  fmt='%(refname:short)%1f%(upstream:short)%1f%(upstream:track)%1f%(committerdate:iso-strict)%1f%(worktreepath)%1f%(contents:subject)'
  git for-each-ref refs/heads --format="$fmt" | jq -Rc --arg sep "$SEP" '
    split($sep) | def nonempty: if . == "" or . == null then null else . end;
    {branch: .[0], upstream: (.[1] | nonempty), upstream_gone: (.[2] == "[gone]"),
     worktree: (.[4] | nonempty), last_commit: {date: .[3], subject: (.[5:] | join($sep))}}' |
    jq -cs .
}

pr_note() {
  jq -cn --arg note "$1" '{merged: false, ok: false, note: $note}'
}

# One forge lookup for one branch; prints {merged, ok, number?, url?, note?}.
pr_lookup() {
  local forge=$1 repo=$2 branch=$3 out errfile
  errfile=$(mktemp)
  local -A cli=([github]=gh [gitlab]=glab)
  command -v "${cli[$forge]}" >/dev/null || {
    pr_note "${cli[$forge]} not installed"
    return 0
  }
  if [[ $forge == github ]]; then
    out=$(GH_PROMPT_DISABLED=1 gh pr list -R "$repo" --state merged --head "$branch" \
      --json number,url --limit 1 </dev/null 2>"$errfile") || out=""
  else
    out=$(NO_PROMPT=1 glab mr list -R "$repo" --source-branch "$branch" --merged \
      -F json </dev/null 2>"$errfile") || out=""
  fi
  if [[ -z $out ]] || ! jq -e 'type == "array"' <<<"$out" >/dev/null 2>&1; then
    pr_note "${cli[$forge]} failed for $repo: $(head -n1 "$errfile")"
    rm -f "$errfile"
    return 0
  fi
  rm -f "$errfile"
  jq -c '.[0] // null | if . == null then {merged: false, ok: true}
    else {merged: true, ok: true, number: (.number // .iid), url: (.url // .web_url)} end' <<<"$out"
}

# Combines every forge lookup for one branch into the "pr" object.
pr_status() {
  local branch=$1 forge_json=$2 forge repo
  {
    for forge in github gitlab; do
      jq -r --arg f "$forge" '.[$f][] | if $f == "gitlab" then .url else "\(.host)/\(.slug)" end' \
        <<<"$forge_json" | while read -r repo; do
        pr_lookup "$forge" "$repo" "$branch"
      done
    done
  } | jq -cs '
    if length == 0 then {status: "unknown", notes: ["no GitHub/GitLab remote"]}
    elif any(.merged) then (map(select(.merged))[0] | {status: "merged", number, url})
    elif all(.ok) then {status: "none"}
    else {status: "unknown", notes: [.[].note | select(.)]} end'
}

# Adds "pr" to each gone branch, one background lookup per branch.
attach_prs() {
  local result=$1 tmp forge_json i branch
  tmp=$(mktemp -d)
  forge_json=$("$FORGE_DETECT" 2>/dev/null) || forge_json='{"github":[],"gitlab":[]}'
  i=0
  while read -r branch; do
    pr_status "$branch" "$forge_json" >"$tmp/$i.json" &
    i=$((i + 1))
  done < <(jq -r '.gone[].branch' <<<"$result")
  wait
  jq -c --slurpfile prs <(for ((j = 0; j < i; j++)); do cat "$tmp/$j.json"; done) \
    '.gone |= [to_entries[] | .value + {pr: $prs[.key]}]' <<<"$result"
  rm -rf "$tmp"
}

main() {
  local base_arg="" fetch=1 check_prs=0
  while (($#)); do
    case "$1" in
      -h | --help) usage && return 0 ;;
      --no-fetch) fetch=0 ;;
      --check-prs) check_prs=1 ;;
      -*) die "unknown option: $1" ;;
      *)
        [[ -z $base_arg ]] || die "only one base branch may be given"
        base_arg=$1
        ;;
    esac
    shift
  done

  git rev-parse --git-dir >/dev/null 2>&1 || die "not inside a git repository"

  local fetch_status=skipped
  if ((fetch)); then
    fetch_status=ok
    git fetch --all --prune >&2 || fetch_status=failed
  fi

  local picked base source base_ref
  picked=$(pick_base "$base_arg") || die "cannot determine the base branch (no origin/HEAD, main or master); pass it as an argument"
  base=${picked%%$'\t'*}
  source=${picked#*$'\t'}
  base_ref=$(resolve_base_ref "$base") || die "base branch not found: $base"

  local merged result
  merged=$(git for-each-ref --merged "$base_ref" refs/heads --format='%(refname:short)' | jq -Rcs 'split("\n") | map(select(. != ""))')

  local short_ref=${base_ref#refs/heads/}
  short_ref=${short_ref#refs/remotes/}
  result=$(branches_json | jq -c \
    --arg base "${base#origin/}" --arg base_ref "$short_ref" --arg source "$source" \
    --arg current "$(git branch --show-current)" --arg fetch "$fetch_status" \
    --argjson never "$(printf '%s\n' "${NEVER_DELETE[@]}" | jq -Rcs 'split("\n") | map(select(. != ""))')" \
    --argjson merged "$merged" '
    def reason(b):
      if (b.branch | IN($never[])) then "protected branch"
      elif b.branch == $base then "base branch"
      elif b.branch == $current then "current branch"
      elif b.worktree then "checked out in worktree \(b.worktree)"
      else null end;
    (map(. + {reason: reason(.)})) as $all
    | ($all | map(select(.reason == null))) as $free
    | {base: $base, base_ref: $base_ref, base_source: $source,
       current: (if $current == "" then null else $current end), fetch: $fetch,
       protected: [$all[] | select(.reason) | {branch, reason}],
       merged: [$free[] | select(.branch | IN($merged[]))
                | {branch, upstream, upstream_gone, last_commit}],
       gone: [$free[] | select(.upstream_gone and (.branch | IN($merged[]) | not))
              | {branch, upstream, last_commit}]}')

  ((check_prs)) || {
    printf '%s\n' "$result"
    return 0
  }
  attach_prs "$result"
}

main "$@"
