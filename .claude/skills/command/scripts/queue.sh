#!/usr/bin/env bash
# Flag parsing and the per-project queue files of the command skill:
# .claude/flow-durable-commands.txt and .claude/flow-persistent-commands.txt in the project's
# .claude/ dir (--project, else $CLAUDE_PROJECT_DIR, else git toplevel, else $PWD).
# Never clears a whole file.
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: queue.sh parse '<raw arguments>'
       queue.sh [--project <dir>] add durable|persistent <command...>
       queue.sh [--project <dir>] list durable|persistent
       queue.sh [--project <dir>] remove durable|persistent <command...>

  parse   Strip the leading flags (--durable/-durable/-d, --persistent/-persistent/-p,
          --auto/-auto/-a, --now/-now/-n) and print what to do with the command:
          {"durable":b,"persistent":b,"auto":b,"now":b,"kind":"session|durable|persistent|now",
           "store":"durable|persistent|null","run_now":b,"command":"…"}
          Exit 2 with {"error":"…","message":"…"} on an empty command or
          --durable together with --persistent.
  add     Append <command> as its own line (no duplicates; creates the dir/file).
          {"status":"added|exists","kind":"…","file":"…","command":"…"}
  list    The queued commands, in file order: ["…", …] ([] when there's no file).
  remove  Delete exactly one line equal to <command> (the first match).
          {"status":"removed|not_found",…}; exit 1 when nothing matched.

Pass the command as one argument; several arguments are joined with spaces.
EOF
}

die() {
  printf 'queue: %s\n' "$1" >&2
  exit 2
}

# Project root: --project <dir>, else $CLAUDE_PROJECT_DIR (set for hooks, not for Bash tool
# calls), else the git toplevel, else $PWD.
project_dir() {
  [[ -n ${PROJECT_DIR:-} ]] && printf '%s' "$PROJECT_DIR" && return 0
  [[ -n ${CLAUDE_PROJECT_DIR:-} ]] && printf '%s' "$CLAUDE_PROJECT_DIR" && return 0
  git rev-parse --show-toplevel 2>/dev/null || pwd
}

queue_file() {
  case $1 in
    durable | persistent) printf '%s/.claude/flow-%s-commands.txt\n' "$(project_dir)" "$1" ;;
    *) die "queue must be durable or persistent, got '${1:-}'" ;;
  esac
}

trim() {
  local s=$1
  s="${s#"${s%%[![:space:]]*}"}"
  printf '%s' "${s%"${s##*[![:space:]]}"}"
}

read_command() {
  local cmd
  cmd=$(trim "$*")
  [[ -n $cmd ]] || die "missing command"
  [[ $cmd != *$'\n'* ]] || die "multi-line commands can't be queued (one command per line)"
  printf '%s' "$cmd"
}

emit() {
  jq -cn --arg status "$1" --arg kind "$2" --arg file "$3" --arg command "$4" \
    '{status: $status, kind: $kind, file: $file, command: $command}'
}

parse_error() {
  jq -cn --arg error "$1" --arg message "$2" '{error: $error, message: $message}'
  exit 2
}

cmd_parse() {
  local rest token kind store=null run_now=false
  local -A flag_of=(
    [--durable]=durable [-durable]=durable [-d]=durable
    [--persistent]=persistent [-persistent]=persistent [-p]=persistent
    [--auto]=auto [-auto]=auto [-a]=auto
    [--now]=now [-now]=now [-n]=now
  )
  local -A flags=([durable]=false [persistent]=false [auto]=false [now]=false)
  rest=$(trim "$*")
  while [[ $rest =~ ^([^[:space:]]+)(.*)$ ]]; do
    token=${BASH_REMATCH[1]}
    [[ -n ${flag_of[$token]:-} ]] || break
    flags[${flag_of[$token]}]=true
    rest=$(trim "${BASH_REMATCH[2]}")
  done
  [[ -n $rest ]] || parse_error missing_command "no shell command after the flags"
  [[ ${flags[durable]} == true && ${flags[persistent]} == true ]] &&
    parse_error conflicting_flags "--durable and --persistent can't be combined"

  kind=session
  [[ ${flags[durable]} == true ]] && kind=durable store='"durable"'
  [[ ${flags[now]} == true ]] && kind=now store=null run_now=true
  [[ ${flags[persistent]} == true ]] && kind=persistent store='"persistent"' run_now=true

  jq -cn --arg command "$rest" --arg kind "$kind" --argjson store "$store" --argjson run_now "$run_now" \
    --argjson durable "${flags[durable]}" --argjson persistent "${flags[persistent]}" \
    --argjson auto "${flags[auto]}" --argjson now "${flags[now]}" \
    '{durable: $durable, persistent: $persistent, auto: $auto, now: $now, kind: $kind, store: $store, run_now: $run_now, command: $command}'
}

cmd_add() {
  local kind=${1:-} file cmd
  file=$(queue_file "$kind")
  shift
  cmd=$(read_command "$@")
  if [[ -f $file ]] && grep -qxF -e "$cmd" "$file"; then
    emit exists "$kind" "$file" "$cmd"
    return 0
  fi
  mkdir -p "$(dirname "$file")"
  [[ -s $file && -n $(tail -c 1 "$file") ]] && printf '\n' >>"$file"
  printf '%s\n' "$cmd" >>"$file"
  emit added "$kind" "$file" "$cmd"
}

cmd_list() {
  local file
  file=$(queue_file "${1:-}")
  [[ -f $file ]] || {
    printf '[]\n'
    return 0
  }
  jq -cRn '[inputs | select(test("\\S"))]' "$file"
}

cmd_remove() {
  local kind=${1:-} file cmd n
  file=$(queue_file "$kind")
  shift
  cmd=$(read_command "$@")
  n=0
  [[ -f $file ]] && n=$(grep -nxF -m 1 -e "$cmd" "$file" | cut -d: -f1 || true)
  if ((${n:-0} == 0)); then
    emit not_found "$kind" "$file" "$cmd"
    return 1
  fi
  sed -i "${n}d" "$file"
  emit removed "$kind" "$file" "$cmd"
}

main() {
  if [[ ${1:-} == --project ]]; then
    [[ -n ${2:-} ]] || die "--project needs a directory"
    PROJECT_DIR=$2
    shift 2
  fi
  local sub=${1:-}
  (($# > 0)) && shift
  case $sub in
    parse) cmd_parse "$@" ;;
    add) cmd_add "$@" ;;
    list) cmd_list "$@" ;;
    remove) cmd_remove "$@" ;;
    -h | --help | help) usage ;;
    *)
      usage >&2
      exit 2
      ;;
  esac
}

main "$@"
