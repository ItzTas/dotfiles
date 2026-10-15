#!/usr/bin/env bash
# /sync --all-branches: fast-forward every other local branch to its upstream
# without checking it out (`git fetch . <upstream>:<branch>`, which refuses
# anything but a fast-forward). Never rebases, merges or forces.
set -euo pipefail

SEP=$'\x1f'

usage() {
  cat <<'EOF'
Usage: ff-all.sh

Run it after sync.sh (which already fetched); it does not fetch. For each local
branch other than the current one:
  no upstream                   -> skipped, reason "no_upstream"
  upstream gone (pruned)        -> skipped, reason "upstream_gone"
  checked out in a worktree     -> skipped, reason "checked_out_in_worktree"
  local and remote commits      -> skipped, reason "diverged"
  nothing new upstream          -> up_to_date ("ahead" = unpushed local commits)
  otherwise                     -> git fetch . <upstream>:<branch>, fast_forwarded

Prints one JSON object:
  {"current", "branches": [{"branch", "upstream", "status": "fast_forwarded"|"up_to_date"|"skipped",
                            "commits", "ahead", "behind", "reason", "worktree"}]}
("commits" = commits fast-forwarded; fields that don't apply are omitted.)

Exit: 0 ok, 2 not a git repo / bad args.
EOF
}

entry() {
  jq -cn --arg branch "$1" --arg upstream "$2" --arg status "$3" '{branch: $branch,
    upstream: (if $upstream == "" then null else $upstream end), status: $status}'
}

skip() {
  entry "$1" "$2" skipped | jq -c --arg reason "$3" '. + {reason: $reason}'
}

# Decides and, when possible, fast-forwards one branch; prints its JSON entry.
sync_branch() {
  local ref=$1 branch=$2 up_ref=$3 up=$4 track=$5 worktree=$6 counts ahead behind
  [[ -n $up ]] || {
    skip "$branch" "" no_upstream
    return 0
  }
  [[ $track != "[gone]" ]] || {
    skip "$branch" "$up" upstream_gone
    return 0
  }
  [[ -z $worktree ]] || {
    skip "$branch" "$up" checked_out_in_worktree | jq -c --arg w "$worktree" '. + {worktree: $w}'
    return 0
  }
  counts=$(git rev-list --left-right --count "$ref...$up_ref")
  read -r ahead behind <<<"$counts"
  local nums
  nums=$(jq -cn --argjson a "$ahead" --argjson b "$behind" '{ahead: $a, behind: $b}')
  ((behind == 0)) && entry "$branch" "$up" up_to_date | jq -c --argjson n "$nums" '. + $n' && return 0
  ((ahead == 0)) || {
    skip "$branch" "$up" diverged | jq -c --argjson n "$nums" '. + $n'
    return 0
  }
  git fetch --quiet . "$up_ref:$ref" >&2 || {
    skip "$branch" "$up" fetch_failed | jq -c --argjson n "$nums" '. + $n'
    return 0
  }
  entry "$branch" "$up" fast_forwarded | jq -c --argjson c "$behind" '. + {commits: $c}'
}

main() {
  case "${1:-}" in
    -h | --help) usage && return 0 ;;
    "") ;;
    *) echo "ff-all: unknown argument: $1" >&2 && return 2 ;;
  esac
  git rev-parse --git-dir >/dev/null 2>&1 || {
    echo "ff-all: not inside a git repository" >&2
    return 2
  }

  local current fmt ref branch up_ref up track worktree
  current=$(git branch --show-current)
  fmt='%(refname)%1f%(refname:short)%1f%(upstream)%1f%(upstream:short)%1f%(upstream:track)%1f%(worktreepath)'
  git for-each-ref refs/heads --format="$fmt" |
    while IFS=$SEP read -r ref branch up_ref up track worktree; do
      [[ $branch == "$current" ]] && continue
      sync_branch "$ref" "$branch" "$up_ref" "$up" "$track" "$worktree"
    done |
    jq -cs --arg current "$current" '{current: (if $current == "" then null else $current end), branches: .}'
}

main "$@"
