#!/usr/bin/env bash
# Fetch the failed-step logs of a CI run/pipeline/job and trim them down to the
# error regions (via trim-log.py). Read-only.
set -euo pipefail

FORGE_DETECT="$HOME/.claude/scripts/forge-detect.sh"
TRIM="$(dirname "${BASH_SOURCE[0]}")/trim-log.py"
WORK="" # scratch dir, created in main and removed on exit

usage() {
  cat <<'EOF'
Usage: failed-log.sh <github|gitlab> <run/pipeline id> [--job] [--max-lines N]
                     [--before N] [--after N] [-R [host/]owner/repo]

GitHub: `gh run view <id> --log-failed` (with --job: `--job <id>`).
GitLab: the traces of the pipeline's failed jobs (allowed failures only when
        nothing else failed); with --job, that job's trace.
Logs are cleaned (ANSI, timestamps, GitLab section markers, \r redraws) and
cut to the lines matching error/failed/panic/exception/assert/FAIL/✗/exit code
plus context and each log's last lines; repeats are collapsed.

Prints: {"forge","repo","id","kind":"run|job|pipeline","truncated",
  "sections":[{"job","step","lines_total","lines_kept","matches","excerpt"}]}
--max-lines caps each section (default 120); --before/--after set the context
(default 3/5). Raise them when the excerpt lacks the surrounding context.

Exit: 0 ok, 1 nothing failed (no failed jobs found), 2 error.
EOF
}

die() {
  echo "failed-log: $*" >&2
  exit 2
}

split_repo_arg() {
  local forge=$1 value=$2 first=${2%%/*}
  local -A default_host=([github]=github.com [gitlab]=gitlab.com)
  [[ $first == *.* ]] && printf '%s\t%s' "$first" "${value#*/}" && return 0
  printf '%s\t%s' "${default_host[$forge]}" "$value"
}

resolve_target() {
  local forge=$1 repo_arg=$2
  [[ -n $repo_arg ]] && split_repo_arg "$forge" "$repo_arg" && return 0
  "$FORGE_DETECT" | jq -r --arg f "$forge" '.[$f] | (map(select(.remote == "origin")) + .)[0] // empty
    | "\(.host)\t\(.slug)"'
}

github_log() {
  local repo=$1 id=$2 is_job=$3 trim_args=("${@:4}")
  local view=("$id")
  ((is_job)) && view=(--job "$id")
  gh run view "${view[@]}" -R "$repo" --log-failed >"$WORK/gh.log" || return 2
  [[ -s $WORK/gh.log ]] || return 1
  "$TRIM" --format github "${trim_args[@]}" <"$WORK/gh.log"
}

gitlab_api() { glab api --hostname "$1" "$2"; }

# Echoes "id<TAB>name" for every failed job of a pipeline (allowed failures as fallback).
gitlab_failed_jobs() {
  local host=$1 project=$2 pipeline=$3
  gitlab_api "$host" "projects/$project/pipelines/$pipeline/jobs?per_page=100" | jq -r '
    (map(select(.status == "failed" and (.allow_failure | not)))
     | if length > 0 then . else null end) as $hard
    | ($hard // map(select(.status == "failed")))[] | "\(.id)\t\(.name)"'
}

gitlab_log() {
  local host=$1 project=$2 id=$3 is_job=$4 trim_args=("${@:5}") jobs=() pairs=() pids=() list line jid name
  if ((is_job)); then
    name=$(gitlab_api "$host" "projects/$project/jobs/$id" | jq -r .name) || return 2
    jobs=("$id"$'\t'"$name")
  else
    list=$(gitlab_failed_jobs "$host" "$project" "$id") || return 2
    [[ -z $list ]] || mapfile -t jobs <<<"$list"
  fi
  ((${#jobs[@]})) || return 1
  for line in "${jobs[@]}"; do
    jid=${line%%$'\t'*}
    gitlab_api "$host" "projects/$project/jobs/$jid/trace" >"$WORK/$jid.log" &
    pids+=($!)
    pairs+=("${line#*$'\t'} (job $jid)=$WORK/$jid.log")
  done
  for jid in "${pids[@]}"; do wait "$jid" || return 2; done
  "$TRIM" --format plain "${trim_args[@]}" "${pairs[@]}"
}

main() {
  local positional=() is_job=0 repo_arg="" trim_args=()
  while (($#)); do
    case "$1" in
      -h | --help) usage && return 0 ;;
      --job) is_job=1 ;;
      --max-lines | --before | --after)
        trim_args+=("$1" "${2:?$1 needs a number}")
        shift
        ;;
      -R | --repo) shift && repo_arg=${1:?-R needs [host/]owner/repo} ;;
      -*) die "unknown flag: $1" ;;
      *) positional+=("$1") ;;
    esac
    shift
  done
  ((${#positional[@]} == 2)) || {
    usage >&2
    exit 2
  }
  local forge=${positional[0]} id=${positional[1]}
  local -A clis=([github]=gh [gitlab]=glab) kinds=([github]=run [gitlab]=pipeline)
  [[ -n ${clis[$forge]:-} ]] || die "forge must be github or gitlab, got: $forge"
  [[ $id =~ ^[0-9]+$ ]] || die "id must be numeric: $id"
  command -v "${clis[$forge]}" >/dev/null || die "${clis[$forge]} is not installed"

  local target host slug kind=${kinds[$forge]} out rc=0
  target=$(resolve_target "$forge" "$repo_arg")
  [[ -n $target ]] || die "no $forge remote found (pass -R)"
  host=${target%%$'\t'*}
  slug=${target#*$'\t'}
  ((is_job)) && kind=job
  WORK=$(mktemp -d)
  trap 'rm -rf "${WORK:?}"' EXIT

  if [[ $forge == github ]]; then
    out=$(github_log "$host/$slug" "$id" "$is_job" "${trim_args[@]}") || rc=$?
  else
    out=$(gitlab_log "$host" "$(jq -rn --arg s "$slug" '$s | @uri')" "$id" "$is_job" "${trim_args[@]}") || rc=$?
  fi
  ((rc != 2)) || die "could not fetch logs for $forge $kind $id"
  [[ -n $out ]] || out='{"sections":[],"truncated":false}'
  jq -c --arg forge "$forge" --arg repo "$host/$slug" --argjson id "$id" --arg kind "$kind" \
    '{forge: $forge, repo: $repo, id: $id, kind: $kind} + .' <<<"$out"
  return "$rc"
}

main "$@"
