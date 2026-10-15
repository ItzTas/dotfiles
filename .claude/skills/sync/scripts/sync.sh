#!/usr/bin/env bash
# Mechanical part of /sync: fetch with prune, pick the base, then rebase the
# current branch onto it (or fast-forward it when it is the base). Never pushes,
# never discards changes (always --autostash), leaves a conflicted rebase stopped.
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: sync.sh [base]

1. Refuses when a rebase/merge/cherry-pick/revert is in progress or HEAD is detached.
2. git fetch --all --prune
3. Base: the argument (origin/<base>), else origin/HEAD, else origin/main,
   origin/master, origin/dev, else the branch's upstream.
4. On the base itself: git merge --ff-only --autostash origin/<base> (what
   `git pull --ff-only` does after the fetch). Otherwise:
   git rebase --autostash origin/<base>. Nothing is pushed.

Prints one JSON object:
  {"status": "rebased"|"fast_forwarded"|"up_to_date"|"conflict"|"cannot_fast_forward"|"error"|"refused",
   "branch", "base", "base_ref", "base_source", "mode": "rebase"|"fast_forward",
   "behind",            commits the branch was missing from the base
   "ahead",             local commits on top of the base before syncing
   "replayed",          commits replayed on top of the base (rebase)
   "autostash": "none"|"reapplied"|"conflict_kept_in_stash"|"pending",
   "upstream", "force_push_needed",
   "conflicts": [files],      (conflict, or autostash re-applied with conflicts)
   "stopped_at": {"sha", "subject"},                         (conflict)
   "reason" / "message"}                                     (refused / error)

Exit: 0 synced or already up to date; 1 conflict, cannot fast-forward or git
error (details in the JSON); 2 refused (JSON "reason") or bad args.
EOF
}

ref_exists() {
  git rev-parse --verify --quiet "$1^{commit}" >/dev/null
}

refuse() {
  echo "sync: $1" >&2
  jq -cn --arg reason "$1" '{status: "refused", reason: $reason}'
  exit 2
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

# Echoes "<base><TAB><base_ref><TAB><source>"; fails when no base is found.
pick_base() {
  local arg=$1 ref name
  if [[ -n $arg ]]; then
    for ref in "origin/${arg#origin/}" "$arg"; do
      ref_exists "refs/remotes/$ref" || continue
      printf '%s\t%s\targument' "${ref#*/}" "$ref"
      return 0
    done
    return 1
  fi
  if ref=$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null); then
    printf '%s\t%s\torigin/HEAD' "${ref#origin/}" "$ref"
    return 0
  fi
  for name in main master dev; do
    ref_exists "refs/remotes/origin/$name" || continue
    printf '%s\torigin/%s\tfallback' "$name" "$name"
    return 0
  done
  ref=$(git rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null) || return 1
  printf '%s\t%s\tupstream' "${ref#*/}" "$ref"
}

# The remote copy of the branch: its upstream, else origin/<branch>.
pushed_ref() {
  local branch=$1 up
  if up=$(git rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null); then
    printf '%s' "$up"
    return 0
  fi
  ref_exists "refs/remotes/origin/$branch" && printf 'origin/%s' "$branch"
  return 0
}

is_dirty() {
  [[ -n $(git status --porcelain --untracked-files=no) ]]
}

stash_count() {
  git stash list | wc -l
}

unmerged() {
  git diff --name-only --diff-filter=U | jq -Rcs 'split("\n") | map(select(. != ""))'
}

autostash_state() {
  local dirty=$1 before=$2
  (($(stash_count) > before)) && echo conflict_kept_in_stash && return 0
  ((dirty)) && echo reapplied && return 0
  echo none
}

# Runs a git command with its output on stderr; on failure keeps the last lines in $LOG.
run_git() {
  "$@" >"$LOG" 2>&1 && cat "$LOG" >&2 && return 0
  cat "$LOG" >&2
  return 1
}

fast_forward() {
  local base_ref=$1 behind=$2 ahead=$3 dirty=$4 before
  ((behind == 0)) && jq -c '. + {status: "up_to_date"}' <<<"$CTX" && return 0
  ((ahead > 0)) && jq -c '. + {status: "cannot_fast_forward"}' <<<"$CTX" && return 1
  before=$(stash_count)
  run_git git merge --ff-only --autostash "$base_ref" || {
    jq -c --arg m "$(tail -n 5 "$LOG")" '. + {status: "error", message: $m}' <<<"$CTX"
    return 1
  }
  jq -c --arg a "$(autostash_state "$dirty" "$before")" --argjson conflicts "$(unmerged)" \
    '. + {status: "fast_forwarded", autostash: $a}
     + if $conflicts == [] then {} else {conflicts: $conflicts} end' <<<"$CTX"
}

conflict() {
  local dirty=$1 stopped=null autostash=none
  ((dirty)) && autostash=pending
  if ref_exists REBASE_HEAD; then
    stopped=$(jq -cn --arg sha "$(git rev-parse --short REBASE_HEAD)" \
      --arg subject "$(git log -1 --format=%s REBASE_HEAD)" '{sha: $sha, subject: $subject}')
  fi
  jq -c --argjson stopped "$stopped" --arg a "$autostash" --argjson conflicts "$(unmerged)" \
    '. + {status: "conflict", conflicts: $conflicts, stopped_at: $stopped, autostash: $a}' <<<"$CTX"
}

rebase_onto() {
  local branch=$1 base_ref=$2 behind=$3 dirty=$4 before up force=false
  ((behind == 0)) && jq -c '. + {status: "up_to_date"}' <<<"$CTX" && return 0
  before=$(stash_count)
  if ! run_git git rebase --autostash "$base_ref"; then
    in_progress >/dev/null && conflict "$dirty" && return 1
    jq -c --arg m "$(tail -n 5 "$LOG")" '. + {status: "error", message: $m}' <<<"$CTX"
    return 1
  fi
  up=$(pushed_ref "$branch")
  [[ -n $up ]] && ! git merge-base --is-ancestor "$up" HEAD && force=true
  jq -c --arg a "$(autostash_state "$dirty" "$before")" --argjson force "$force" \
    --argjson replayed "$(git rev-list --count "$base_ref..HEAD")" --argjson conflicts "$(unmerged)" \
    '. + {status: "rebased", replayed: $replayed, autostash: $a, force_push_needed: $force}
     + if $conflicts == [] then {} else {conflicts: $conflicts} end' <<<"$CTX"
}

main() {
  local base_arg=""
  while (($#)); do
    case "$1" in
      -h | --help) usage && return 0 ;;
      -*) echo "sync: unknown option: $1" >&2 && return 2 ;;
      *)
        [[ -z $base_arg ]] || { echo "sync: only one base branch may be given" >&2 && return 2; }
        base_arg=$1
        ;;
    esac
    shift
  done

  git rev-parse --git-dir >/dev/null 2>&1 || refuse "not inside a git repository"
  local branch op
  op=$(in_progress) && refuse "a $op is already in progress; finish or abort it first"
  branch=$(git branch --show-current)
  [[ -n $branch ]] || refuse "HEAD is detached; check out a branch first"
  git fetch --all --prune >&2 || refuse "git fetch --all --prune failed"

  local picked base base_ref source
  picked=$(pick_base "$base_arg") || refuse "cannot determine the base branch${base_arg:+ (origin/$base_arg not found)}"
  IFS=$'\t' read -r base base_ref source <<<"$picked"

  local behind ahead dirty=0 mode=rebase
  behind=$(git rev-list --count "HEAD..$base_ref")
  ahead=$(git rev-list --count "$base_ref..HEAD")
  is_dirty && dirty=1
  [[ $branch == "$base" ]] && mode=fast_forward

  LOG=$(mktemp)
  trap 'rm -f "$LOG"' EXIT
  CTX=$(jq -cn --arg branch "$branch" --arg base "$base" --arg base_ref "$base_ref" \
    --arg source "$source" --arg mode "$mode" --arg up "$(pushed_ref "$branch")" \
    --argjson behind "$behind" --argjson ahead "$ahead" \
    '{branch: $branch, base: $base, base_ref: $base_ref, base_source: $source, mode: $mode,
      behind: $behind, ahead: $ahead, replayed: 0, autostash: "none",
      upstream: (if $up == "" then null else $up end), force_push_needed: false}')

  [[ $mode == fast_forward ]] && {
    fast_forward "$base_ref" "$behind" "$ahead" "$dirty"
    return
  }
  rebase_onto "$branch" "$base_ref" "$behind" "$dirty"
}

main "$@"
