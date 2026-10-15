#!/usr/bin/env bash
# Spellcheck a path with typos (preferred), codespell, or `uvx typos@<pin>`, and print the
# findings as normalized JSON with each finding's source line. Read-only.
set -euo pipefail

TYPOS_PIN=1.50.3
PATH="$PATH:$HOME/.local/share/nvim/mason/bin"
SECRETS=$(realpath -s -m "$HOME/.config/zsh/secrets")
RUNNER=""
CMD=()
WORK=""

usage() {
  cat <<EOF
Usage: scan.sh [path]   (default: .)

Runner: typos (typos-cli) if installed, else codespell, else \`uvx typos@$TYPOS_PIN\`.
Respects .gitignore; never reads ~/.config/zsh/secrets.

Output (stdout, one JSON object):
  {"runner":"typos|codespell|uvx typos","path":"…","count":N,
   "configs":{"typos":["_typos.toml"…],"codespell":[".codespellrc"…]},
   "findings":[{"file","line","column","word","corrections":[…],"text"}]}
  line/column are 1-based (null for a typo in a file name); text is the source line, so you can
  tell a comment/string from an identifier.
Exit: 0 no findings, 1 findings, 2 usage/environment error ({"error","detail"} on stdout).
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
  local err
  if command -v typos >/dev/null; then
    RUNNER=typos CMD=(typos)
    return
  fi
  if command -v codespell >/dev/null; then
    RUNNER=codespell CMD=(codespell)
    return
  fi
  command -v uvx >/dev/null || fail_json no_spellchecker "install typos-cli or codespell (uvx isn't available either)"
  err=$(uvx --version 2>&1) || fail_json uvx_failed "uvx can't run here, so no typos fallback: $err"
  RUNNER="uvx typos" CMD=(uvx "typos@$TYPOS_PIN")
}

# Path of the secrets dir relative to <dir>, when it lies inside it.
secrets_inside() {
  local dir
  dir=$(realpath -m "$1")
  [[ $SECRETS == "$dir"/* ]] && printf '%s' "${SECRETS#"$dir"/}"
  return 0
}

# Paths come back relative to <target> when it's a directory (we run inside it, so the secrets
# exclusion can be rooted); prefix them back.
display_prefix() {
  [[ -d $1 && $1 != . ]] && printf '%s/' "${1%/}"
  return 0
}

run_typos() {
  local target=$1 inside status=0
  local -a args=(--format json --color never)
  if [[ ! -d $target ]]; then
    "${CMD[@]}" "${args[@]}" -- "$target" || status=$?
  else
    inside=$(secrets_inside "$target")
    [[ -n $inside ]] && args+=(--exclude "/$inside")
    (cd "$target" && "${CMD[@]}" "${args[@]}" -- .) || status=$?
  fi
  ((status == 0 || status == 2)) || return "$status"
}

run_codespell() {
  local target=$1 inside status=0
  if [[ ! -d $target ]]; then
    codespell -- "$target" || status=$?
  elif git -C "$target" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    inside=$(secrets_inside "$target")
    (cd "$target" && git ls-files -co --exclude-standard -z . |
      { if [[ -n $inside ]]; then grep -zv "^$inside/" || true; else cat; fi; } |
      xargs -0 -r codespell --) || status=$?
  else
    inside=$(secrets_inside "$target")
    (cd "$target" && codespell --skip "./.git,*/node_modules,*/target,*/dist,*/build,*/vendor${inside:+,./$inside}" -- .) || status=$?
  fi
  ((status == 0 || status == 65 || status == 123)) || return "$status"
}

normalize_typos() {
  jq -c --arg prefix "$1" 'select(.type == "typo")
    | {file: ($prefix + (.path | ltrimstr("./"))), line: .line_num, byte_offset, word: .typo, corrections}'
}

normalize_codespell() {
  jq -cR --arg prefix "$1" 'capture("^(?<file>.+?):(?<line>[0-9]+): (?<word>.+?) ==> (?<fix>.*)$")
    | {file: ($prefix + (.file | ltrimstr("./"))), line: (.line | tonumber), byte_offset: null, word,
       corrections: (.fix | split(" | ")[0] | split(", ") | map(select(length > 0)))}'
}

# "file\tline\ttext" for every (file, line) pair on stdin.
source_lines() {
  awk -F'\t' '
    { want[$1, $2] = 1; files[$1] = 1 }
    END {
      for (f in files) {
        n = 0
        while ((getline l < f) > 0) {
          n++
          sub(/\r$/, "", l)
          if ((f, n) in want) print f "\t" n "\t" l
        }
        close(f)
      }
    }'
}

find_configs() {
  local dir file
  local -a typos=() codespell=()
  local -A seen=()
  for dir in "$@"; do
    [[ -n $dir ]] || continue
    dir=$(realpath -m "$dir")
    [[ -z ${seen[$dir]:-} ]] || continue
    seen[$dir]=1
    for file in _typos.toml .typos.toml typos.toml; do
      [[ -f $dir/$file ]] && typos+=("$dir/$file")
    done
    [[ -f $dir/.codespellrc ]] && codespell+=("$dir/.codespellrc")
    grep -qs '^\[tool\.typos' "$dir/pyproject.toml" && typos+=("$dir/pyproject.toml")
    grep -qs 'metadata\.typos' "$dir/Cargo.toml" && typos+=("$dir/Cargo.toml")
    grep -qs '^\[tool\.codespell\]' "$dir/pyproject.toml" && codespell+=("$dir/pyproject.toml")
    grep -qs '^\[codespell\]' "$dir/setup.cfg" && codespell+=("$dir/setup.cfg")
  done
  jq -cn --argjson t "$(jq -cn '$ARGS.positional' --args "${typos[@]}")" \
    '{typos: $t, codespell: $ARGS.positional}' --args "${codespell[@]}"
}

assemble() {
  local findings=$1 texts=$2 configs=$3 target=$4
  jq -cs --rawfile t "$texts" --argjson configs "$configs" --arg runner "$RUNNER" --arg path "$target" '
    def utf8_len: if . < 128 then 1 elif . < 2048 then 2 elif . < 65536 then 3 else 4 end;
    def byte_col($text; $offset):
      reduce ($text | explode[]) as $c ({bytes: 0, chars: 0};
        if .bytes < $offset then .bytes += ($c | utf8_len) | .chars += 1 else . end)
      | .chars + 1;
    ($t | split("\n") | map(select(length > 0) | split("\t")
      | {key: (.[0] + "\t" + .[1]), value: (.[2:] | join("\t"))}) | from_entries) as $lines
    | reduce .[] as $f ({seen: {}, out: []};
        ($f.file + "\t" + ($f.line | tostring) + "\t" + $f.word) as $k
        | .out += [$f + {nth: (.seen[$k] // 0)}] | .seen[$k] = (.seen[$k] // 0) + 1)
    | [.out[] | . as $f
        | (if $f.line == null then null else $lines[$f.file + "\t" + ($f.line | tostring)] end) as $text
        | {file, line, word, corrections, text: $text,
           column: (if $text == null then null
                    elif $f.byte_offset != null then byte_col($text; $f.byte_offset)
                    else ([$text | indices($f.word)[]][$f.nth] // null | if . == null then null else . + 1 end) end)}
        | {file, line, column, word, corrections, text}]
    | sort_by(.file, (.line // 0), (.column // 0))
    | {runner: $runner, path: $path, count: length, configs: $configs, findings: .}' "$findings"
}

main() {
  local target=${1:-.} prefix configs toplevel dir status=0
  case $target in
    -h | --help)
      usage
      return 0
      ;;
  esac
  (($# <= 1)) || fail_json usage "expected at most one path"
  command -v jq >/dev/null || {
    printf 'scan: jq is required\n' >&2
    exit 2
  }
  check_target "$target"
  pick_runner
  WORK=$(mktemp -d)
  trap 'rm -rf "$WORK"' EXIT
  prefix=$(display_prefix "$target")

  if [[ $RUNNER == codespell ]]; then
    run_codespell "$target" >"$WORK/raw" 2>"$WORK/err" || status=$?
  else
    run_typos "$target" >"$WORK/raw" 2>"$WORK/err" || status=$?
  fi
  ((status == 0)) || fail_json runner_failed "$RUNNER exited $status: $(tail -n 5 "$WORK/err")"

  if [[ $RUNNER == codespell ]]; then
    normalize_codespell "$prefix" <"$WORK/raw" >"$WORK/findings"
  else
    normalize_typos "$prefix" <"$WORK/raw" >"$WORK/findings"
  fi
  jq -r 'select(.line != null) | [.file, (.line | tostring)] | join("\t")' "$WORK/findings" |
    sort -u | source_lines >"$WORK/texts"

  [[ -d $target ]] && dir=$target || dir=$(dirname "$target")
  toplevel=$(git -C "$dir" rev-parse --show-toplevel 2>/dev/null || true)
  configs=$(find_configs "$dir" "$toplevel")
  assemble "$WORK/findings" "$WORK/texts" "$configs" "$target" | tee "$WORK/out"
  [[ $(jq '.count' "$WORK/out") == 0 ]] || return 1
}

main "$@"
