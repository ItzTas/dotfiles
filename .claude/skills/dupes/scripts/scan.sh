#!/usr/bin/env bash
# Find duplicated-code clusters with jscpd (installed, else a pinned npx jscpd) and print them as
# JSON, biggest impact first. Read-only: the report goes to a temp dir that is always removed.
set -euo pipefail

JSCPD_PIN=5.3.3
PATH="$PATH:$HOME/.local/share/nvim/mason/bin"
SECRETS=$(realpath -s -m "$HOME/.config/zsh/secrets")
IGNORES='**/node_modules/**,**/target/**,**/dist/**,**/build/**,**/vendor/**,**/.git/**'
CMD=()
RUNNER=""
WORK=""
TARGET=.
MIN_LINES=5

usage() {
  cat <<EOF
Usage: scan.sh [path] [--min-lines N]   (default: . and jscpd's 5 lines)

Runs jscpd (installed, else \`npx --yes jscpd@$JSCPD_PIN\`), ignoring node_modules, target, dist,
build, vendor and .git, respecting .gitignore, never reading ~/.config/zsh/secrets.

Output (stdout, one JSON object):
  {"runner","path","min_lines","stats":{"files","lines","duplicated_lines","percentage"},
   "clusters":[{"format","lines","tokens","occurrences","impact",
                "locations":[{"file","start","end"}]}]}
  A cluster is every place one block appears; impact = lines x occurrences, highest first.
Exit: 0 no duplicates, 1 clusters found, 2 usage/environment error ({"error","detail"}).
EOF
}

fail_json() {
  jq -cn --arg error "$1" --arg detail "$2" '{error: $error, detail: $detail}'
  exit 2
}

under_secrets() { [[ $1 == "$SECRETS" || $1 == "$SECRETS"/* ]]; }

check_target() {
  local target=$1
  under_secrets "$(realpath -s -m "$target")" && fail_json refused "won't scan under ~/.config/zsh/secrets"
  [[ -e $target ]] || fail_json not_found "$target"
  under_secrets "$(realpath -m "$target")" && fail_json refused "won't scan under ~/.config/zsh/secrets"
  return 0
}

pick_runner() {
  local version
  if command -v jscpd >/dev/null; then
    version=$(jscpd --version 2>/dev/null || true)
    RUNNER="jscpd ${version:-?}" CMD=(jscpd)
    [[ ${version%%.*} =~ ^[0-9]+$ ]] && ((${version%%.*} < 5)) && CMD+=(--gitignore)
    return 0
  fi
  command -v npx >/dev/null || fail_json no_jscpd "jscpd isn't installed and npx isn't available"
  RUNNER="npx jscpd@$JSCPD_PIN" CMD=(npx --yes "jscpd@$JSCPD_PIN")
}

# Ignore globs, plus the secrets dir when it lies inside <dir> (globs are rooted at the scan path).
ignore_globs() {
  local dir rel
  dir=$(realpath -m "$1")
  [[ $SECRETS == "$dir"/* ]] || {
    printf '%s' "$IGNORES"
    return 0
  }
  rel=${SECRETS#"$dir"/}
  printf '%s,%s/**,**/%s/**' "$IGNORES" "$rel" "$rel"
}

# jscpd reports paths relative to a directory scan path; prefix them back.
display_prefix() {
  [[ -d $1 && $1 != . ]] && printf '%s/' "${1%/}"
  return 0
}

clusters() {
  jq -c --arg prefix "$1" --arg runner "$RUNNER" --arg path "$2" --argjson min "$3" '
    def location: {file: ($prefix + .name), start, end};
    .statistics.total as $total
    | [.duplicates[] | {format, lines, tokens, locs: [(.firstFile, .secondFile) | location]}]
    | reduce .[] as $pair ([];
        ($pair.locs | map(tojson)) as $keys
        | (map(select(any(.keys[]; IN($keys[])))) ) as $hits
        | map(select(all(.keys[]; IN($keys[]) | not)))
          + [{format: $pair.format,
              lines: ([$pair.lines, $hits[].lines] | max),
              tokens: ([$pair.tokens, $hits[].tokens] | max),
              keys: ([$keys[], $hits[].keys[]] | unique)}])
    | map({format, lines, tokens, occurrences: (.keys | length), impact: (.lines * (.keys | length)),
           locations: (.keys | map(fromjson) | sort_by(.file, .start))})
    | sort_by(-.impact, .locations[0].file)
    | {runner: $runner, path: $path, min_lines: $min,
       stats: {files: $total.sources, lines: $total.lines, duplicated_lines: $total.duplicatedLines,
               percentage: (($total.percentage // 0) * 100 | round / 100)},
       clusters: .}' "$4"
}

parse_args() {
  local seen_path=false
  while (($# > 0)); do
    case $1 in
      -h | --help)
        usage
        exit 0
        ;;
      --min-lines=*) MIN_LINES=${1#*=} ;;
      --min-lines)
        MIN_LINES=${2:-}
        shift
        ;;
      -*) fail_json usage "unknown flag: $1" ;;
      *)
        [[ $seen_path == false ]] || fail_json usage "expected at most one path"
        TARGET=$1 seen_path=true
        ;;
    esac
    shift
  done
  [[ $MIN_LINES =~ ^[1-9][0-9]*$ ]] || fail_json usage "--min-lines needs a positive integer"
  return 0
}

main() {
  local status=0 report
  parse_args "$@"
  check_target "$TARGET"
  pick_runner
  WORK=$(mktemp -d)
  trap 'rm -rf "$WORK"' EXIT

  "${CMD[@]}" --reporters json --output "$WORK" --silent --min-lines "$MIN_LINES" \
    --ignore "$(ignore_globs "$TARGET")" "$TARGET" >"$WORK/log" 2>&1 || status=$?
  report="$WORK/jscpd-report.json"
  ((status == 0)) && [[ -s $report ]] ||
    fail_json jscpd_failed "$RUNNER exited $status: $(tail -n 5 "$WORK/log")"

  clusters "$(display_prefix "$TARGET")" "$TARGET" "$MIN_LINES" "$report" | tee "$WORK/out"
  [[ $(jq '.clusters | length' "$WORK/out") == 0 ]] || return 1
}

main "$@"
