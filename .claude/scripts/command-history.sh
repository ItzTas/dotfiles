#!/usr/bin/env bash
# Manual access to the command-history files that ~/.claude/hooks/command-history.sh also writes:
# project <root>/.claude/command-history/history.txt (cap 500) and global
# $HOME/.claude/command-history/history.txt (cap 1000). Same semantics as the hook.
set -euo pipefail

PROJECT_CAP=500
GLOBAL_CAP=1000

usage() {
  cat <<'EOF'
Usage: command-history.sh [--project <dir>] add <command...>
       command-history.sh [--project <dir>] remove-last <command...>
       command-history.sh [--project <dir>] search [--limit N] <words...>

  add          Append <command> to the project and global history, trimming the
               oldest lines past each cap (project 500, global 1000).
  remove-last  Delete the last line exactly equal to <command> from both files.
  search       History entries closest to <words> (fuzzy, typo-tolerant), both
               files deduped, best match first; ties go to the most recent,
               project before global. Default --limit 10.

Files: project <root>/.claude/command-history/history.txt, where <root> is --project,
else $CLAUDE_PROJECT_DIR, else the git toplevel, else $PWD;
global $HOME/.claude/command-history/history.txt; the project file is skipped
when it resolves to the global one. Leading whitespace of <command> is dropped.

Output (stdout, JSON):
  add          {"command":"…","files":["…"]}
  remove-last  {"command":"…","removed_from":["…"]}             exit 1: no line matched
  search       [{"command":"…","score":0.83,"scopes":["project","global"]}]  exit 1: none
Exit 2: usage error (missing/multi-line command).
EOF
}

die() {
  printf 'command-history: %s\n' "$1" >&2
  exit 2
}

# Project root: --project <dir>, else $CLAUDE_PROJECT_DIR (set for hooks, not for Bash tool
# calls), else the git toplevel, else $PWD.
project_dir() {
  [[ -n ${PROJECT_DIR:-} ]] && printf '%s' "$PROJECT_DIR" && return 0
  [[ -n ${CLAUDE_PROJECT_DIR:-} ]] && printf '%s' "$CLAUDE_PROJECT_DIR" && return 0
  git rev-parse --show-toplevel 2>/dev/null || pwd
}

project_file() { realpath -m "$(project_dir)/.claude/command-history/history.txt"; }
global_file() { realpath -m "$HOME/.claude/command-history/history.txt"; }

# Prints "<file>\t<cap>\t<scope>" for each history file in scope.
history_files() {
  local project global
  project=$(project_file)
  global=$(global_file)
  [[ $project == "$global" ]] || printf '%s\t%s\tproject\n' "$project" "$PROJECT_CAP"
  printf '%s\t%s\tglobal\n' "$global" "$GLOBAL_CAP"
}

read_command() {
  local cmd="$*"
  cmd="${cmd#"${cmd%%[![:space:]]*}"}"
  [[ -n $cmd ]] || die "missing command"
  [[ $cmd != *$'\n'* ]] || die "multi-line commands can't be stored (history is one command per line)"
  printf '%s' "$cmd"
}

append_capped() {
  local file=$1 cap=$2 cmd=$3 tmp
  mkdir -p "$(dirname "$file")"
  printf '%s\n' "$cmd" >>"$file"
  (($(wc -l <"$file") > cap)) || return 0
  tmp="$file.$$.tmp"
  tail -n "$cap" "$file" >"$tmp" && mv "$tmp" "$file"
}

remove_last_line() {
  local file=$1 cmd=$2 n
  [[ -f $file ]] || return 1
  n=$(CMD=$cmd awk '$0 == ENVIRON["CMD"] { n = NR } END { print n + 0 }' "$file")
  ((n > 0)) || return 1
  sed -i "${n}d" "$file"
}

cmd_add() {
  local cmd file cap _scope
  local -a written=()
  cmd=$(read_command "$@")
  while IFS=$'\t' read -r file cap _scope; do
    append_capped "$file" "$cap" "$cmd"
    written+=("$file")
  done < <(history_files)
  jq -cn --arg c "$cmd" '{command: $c, files: $ARGS.positional}' --args "${written[@]}"
}

cmd_remove_last() {
  local cmd file _cap _scope
  local -a removed=()
  cmd=$(read_command "$@")
  while IFS=$'\t' read -r file _cap _scope; do
    remove_last_line "$file" "$cmd" && removed+=("$file")
  done < <(history_files)
  jq -cn --arg c "$cmd" '{command: $c, removed_from: $ARGS.positional}' --args "${removed[@]}"
  ((${#removed[@]} > 0))
}

# Emits "<scope>\t<command>" lines, newest first, project file before global.
history_lines() {
  local file _cap scope
  while IFS=$'\t' read -r file _cap scope; do
    [[ -f $file ]] || continue
    tac "$file" | awk -v s="$scope" 'NF { print s "\t" $0 }'
  done < <(history_files)
}

# Scores each unique entry against the query: per query word, the best typo-tolerant similarity
# (optimal string alignment distance, substring bonus) to an entry word, averaged, then weighted
# by how close the word counts are. Prints "score\torder\tscopes\tcommand" above the threshold.
score_entries() {
  QUERY=$1 awk -F'\t' '
    function osa(a, b,   la, lb, i, j, d, cost, x) {
      la = length(a); lb = length(b)
      if (la == 0) return lb
      if (lb == 0) return la
      for (i = 0; i <= la; i++) d[i, 0] = i
      for (j = 0; j <= lb; j++) d[0, j] = j
      for (i = 1; i <= la; i++) {
        for (j = 1; j <= lb; j++) {
          cost = substr(a, i, 1) == substr(b, j, 1) ? 0 : 1
          x = d[i - 1, j] + 1
          if (d[i, j - 1] + 1 < x) x = d[i, j - 1] + 1
          if (d[i - 1, j - 1] + cost < x) x = d[i - 1, j - 1] + cost
          if (i > 1 && j > 1 && substr(a, i, 1) == substr(b, j - 1, 1) && substr(a, i - 1, 1) == substr(b, j, 1) && d[i - 2, j - 2] + 1 < x) x = d[i - 2, j - 2] + 1
          d[i, j] = x
        }
      }
      return d[la, lb]
    }
    function word_sim(q, e,   m, s) {
      m = length(q) > length(e) ? length(q) : length(e)
      s = m ? 1 - osa(q, e) / m : 1
      if (length(q) >= 3 && index(e, q) && 0.75 + 0.25 * length(q) / length(e) > s) s = 0.75 + 0.25 * length(q) / length(e)
      return s
    }
    BEGIN { nq = split(tolower(ENVIRON["QUERY"]), qw, /[[:space:]]+/) }
    {
      cmd = substr($0, index($0, "\t") + 1)
      if (!(cmd in order)) { order[cmd] = ++n; cmds[n] = cmd; scopes[cmd] = $1; next }
      if (index("," scopes[cmd] ",", "," $1 ",") == 0) scopes[cmd] = scopes[cmd] "," $1
    }
    END {
      for (k = 1; k <= n; k++) {
        cmd = cmds[k]
        ne = split(tolower(cmd), ew, /[[:space:]]+/)
        total = 0
        for (i = 1; i <= nq; i++) {
          best = 0
          for (j = 1; j <= ne; j++) { s = word_sim(qw[i], ew[j]); if (s > best) best = s }
          total += best
        }
        score = (total / nq) * (0.85 + 0.15 * (nq < ne ? nq / ne : ne / nq))
        if (score >= 0.45) printf "%.3f\t%d\t%s\t%s\n", score, k, scopes[cmd], cmd
      }
    }'
}

cmd_search() {
  local limit=10 query results
  if [[ ${1:-} == --limit ]]; then
    [[ ${2:-} =~ ^[1-9][0-9]*$ ]] || die "--limit needs a positive integer"
    limit=$2
    shift 2
  fi
  query="$*"
  [[ -n ${query//[[:space:]]/} ]] || die "missing search words"
  results=$(history_lines | score_entries "$query" | LC_ALL=C sort -t $'\t' -k1,1gr -k2,2n | awk -v n="$limit" 'NR <= n')
  printf '%s' "$results" | jq -cRn '[inputs | split("\t") | {command: (.[3:] | join("\t")), score: (.[0] | tonumber * 1000 | round / 1000), scopes: (.[2] | split(","))}]'
  [[ -n $results ]]
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
    add) cmd_add "$@" ;;
    remove-last) cmd_remove_last "$@" ;;
    search) cmd_search "$@" ;;
    -h | --help | help) usage ;;
    *)
      usage >&2
      exit 2
      ;;
  esac
}

main "$@"
