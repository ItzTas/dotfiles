#!/usr/bin/env bash
# Safety checks for /uncommit before `git reset --soft HEAD~<n>`. Read-only: it
# only inspects the commits that would be undone; the reset stays with the model.
set -euo pipefail

SEP=$'\x1f'

usage() {
  cat <<'EOF'
Usage: preflight.sh [n]        (n: positive integer, default 1)

Prints one JSON object about undoing the last n commits (first-parent line,
exactly what `git reset --soft HEAD~n` removes):
  {"count", "branch",
   "commits": [{"sha", "subject", "is_merge", "pushed"}],   newest first
   "new_head": {"sha", "subject"} | null,
   "enough_history",     false when HEAD~n doesn't exist (past the root commit)
   "upstream",           null when the branch has no upstream
   "pushed",             how many of those commits the upstream already has; null without upstream
   "in_progress",        rebase/merge/cherry-pick/revert in progress, or null
   "blocking": [...], "warnings": [...]}

Blocking: not enough history, no commits yet, an operation in progress.
Warnings (ask before resetting): merge commits, commits already pushed.

Exit: 0 no blocking condition, 1 blocking condition (stop), 2 bad args / not a git repo.
EOF
}

in_progress() {
  local -A markers=(["rebase-merge"]=rebase ["rebase-apply"]=rebase [MERGE_HEAD]=merge
    [CHERRY_PICK_HEAD]=cherry-pick [REVERT_HEAD]=revert)
  local marker
  for marker in "${!markers[@]}"; do
    [[ -e $(git rev-parse --git-path "$marker") ]] || continue
    printf '%s' "${markers[$marker]}"
    return 0
  done
  return 1
}

# One JSON line per commit to undo, newest first.
commits_json() {
  local n=$1 upstream=$2 sha subject parents pushed
  git log --first-parent -n "$n" --format="%H${SEP}%P${SEP}%s" |
    while IFS=$SEP read -r sha parents subject; do
      pushed=null
      if [[ -n $upstream ]]; then
        pushed=false
        git merge-base --is-ancestor "$sha" "$upstream" && pushed=true
      fi
      jq -cn --arg sha "${sha:0:12}" --arg subject "$subject" --arg parents "$parents" \
        --argjson pushed "$pushed" \
        '{sha: $sha, subject: $subject, is_merge: ($parents | split(" ") | length > 1), pushed: $pushed}'
    done
}

main() {
  local n=1
  case "${1:-}" in
    -h | --help) usage && return 0 ;;
    "") ;;
    *) n=$1 ;;
  esac
  (($# <= 1)) || {
    echo "preflight: expected at most one argument" >&2
    return 2
  }
  [[ $n =~ ^[1-9][0-9]*$ ]] || {
    echo "preflight: n must be a positive integer, got: $n" >&2
    return 2
  }
  git rev-parse --git-dir >/dev/null 2>&1 || {
    echo "preflight: not inside a git repository" >&2
    return 2
  }

  local upstream="" op="" commits="[]" new_head=null enough=false
  upstream=$(git rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null) || upstream=""
  op=$(in_progress) || op=""
  if git rev-parse --verify --quiet HEAD >/dev/null; then
    commits=$(commits_json "$n" "$upstream" | jq -cs .)
    if git rev-parse --verify --quiet "HEAD~$n^{commit}" >/dev/null; then
      enough=true
      new_head=$(jq -cn --arg sha "$(git rev-parse --short=12 "HEAD~$n")" \
        --arg subject "$(git log -1 --format=%s "HEAD~$n")" '{sha: $sha, subject: $subject}')
    fi
  fi

  local result
  result=$(jq -cn --argjson n "$n" --arg branch "$(git branch --show-current)" --argjson commits "$commits" \
    --argjson new_head "$new_head" --argjson enough "$enough" --arg upstream "$upstream" --arg op "$op" '
    def nonempty: if . == "" then null else . end;
    ($commits | map(select(.pushed)) | length) as $pushed
    | {count: $n, branch: ($branch | nonempty), commits: $commits, new_head: $new_head,
       enough_history: $enough, upstream: ($upstream | nonempty),
       pushed: (if $upstream == "" then null else $pushed end), in_progress: ($op | nonempty)}
    | .blocking = [
        (if $commits == [] then "the branch has no commits yet" else empty end),
        (if $commits != [] and ($enough | not) then
          "only \($commits | length) commit(s) on this line; undoing \($n) would go past the root commit"
         else empty end),
        (if $op != "" then "a \($op) is in progress; finish or abort it first" else empty end)]
    | .warnings = [
        (.commits[] | select(.is_merge) | "\(.sha) is a merge commit: \(.subject)"),
        (if $pushed > 0 then "\($pushed) of these commit(s) are already on \($upstream); undoing them rewrites pushed history and needs a force-push later" else empty end)]')
  printf '%s\n' "$result"
  jq -e '.blocking == []' <<<"$result" >/dev/null || return 1
}

main "$@"
