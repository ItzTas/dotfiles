#!/usr/bin/env bash

init() {
  CONFIG_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
  C_RESET=$'\033[0m'
  C_DIM=$'\033[2m'
  C_PY=$'\033[38;5;220m'
  C_MODEL=$'\033[38;5;110m'
  C_EFFORT=$'\033[38;5;141m'
  C_DIR=$'\033[38;5;150m'
  C_GIT=$'\033[38;5;180m'
  C_CAVEMAN=$'\033[38;5;172m'
  C_FLOW=$'\033[38;5;44m'
  C_ADVISE=$'\033[38;5;213m'
}

read_input() {
  cat 2>/dev/null || printf ''
}

json_field() {
  printf '%s' "$1" | jq -r "$2" 2>/dev/null
}

session_id() {
  json_field "$1" '.session_id // empty' | tr -cd 'a-zA-Z0-9-'
}

read_flag() {
  local file=$1
  [ -L "$file" ] && return 0
  [ -f "$file" ] || return 0
  head -c 64 "$file" 2>/dev/null \
    | tr -d '\n\r' \
    | tr '[:upper:]' '[:lower:]' \
    | tr -cd 'a-z0-9-'
}

venv_badge() {
  [ -n "${VIRTUAL_ENV:-}" ] || return 0
  local glyph
  glyph=$(printf '\xee\x88\xb5')
  printf '%s%s%s' "$C_PY" "$glyph" "$C_RESET"
}

model_part() {
  [ -n "$1" ] || return 0
  printf '%s%s%s' "$C_MODEL" "$1" "$C_RESET"
  [ -n "$2" ] || return 0
  printf ' %s%s%s' "$C_EFFORT" "$2" "$C_RESET"
}

short_dir() {
  local dir=${1/#$HOME/\~} parent
  parent=${dir%/*}
  if [ "$parent" = "$dir" ] || [ -z "$parent" ]; then
    printf '%s' "$dir"
    return 0
  fi
  printf '%s/%s' "${parent##*/}" "${dir##*/}"
}

dir_part() {
  [ -n "$1" ] || return 0
  printf '%s%s%s' "$C_DIR" "$(short_dir "$1")" "$C_RESET"
}

git_branch() {
  local dir=$1 branch
  [ -d "$dir" ] || return 0
  branch=$(git -C "$dir" rev-parse --abbrev-ref HEAD 2>/dev/null) || return 0
  [ -n "$branch" ] || return 0
  printf '%s(%s)%s' "$C_GIT" "$branch" "$C_RESET"
}

caveman_mode() {
  local mode
  mode=$(read_flag "$CONFIG_DIR/.caveman-active")
  case "$mode" in
    lite|full|ultra|wenyan-lite|wenyan|wenyan-full|wenyan-ultra|commit|review|compress) printf '%s' "$mode" ;;
  esac
}

caveman_label() {
  [ "$1" = "full" ] && {
    printf 'CAVEMAN'
    return 0
  }
  printf 'CAVEMAN:%s' "$(printf '%s' "$1" | tr '[:lower:]' '[:upper:]')"
}

caveman_savings() {
  [ "${CAVEMAN_STATUSLINE_SAVINGS:-1}" = "0" ] && return 0
  local file="$CONFIG_DIR/.caveman-statusline-suffix" suffix
  [ -L "$file" ] && return 0
  [ -f "$file" ] || return 0
  suffix=$(head -c 64 "$file" 2>/dev/null | tr -d '\000-\037')
  [ -n "$suffix" ] || return 0
  printf ' %s%s%s' "$C_CAVEMAN" "$suffix" "$C_RESET"
}

caveman_badge() {
  local mode
  mode=$(caveman_mode)
  [ -n "$mode" ] || return 0
  printf '%s[%s]%s' "$C_CAVEMAN" "$(caveman_label "$mode")" "$C_RESET"
  caveman_savings
}

flow_badge() {
  [ -n "$1" ] || return 0
  local mode
  mode=$(read_flag "$CONFIG_DIR/.flow-active-$1")
  case "$mode" in
    active) printf '%s[FLOW]%s' "$C_FLOW" "$C_RESET" ;;
    paused) printf '%s[FLOW:PAUSED]%s' "$C_FLOW" "$C_RESET" ;;
  esac
}

advise_badge() {
  [ -n "$1" ] || return 0
  local mode
  mode=$(read_flag "$CONFIG_DIR/.advise-active-$1")
  [ "$mode" = "active" ] || return 0
  printf '%s[ADVISE]%s' "$C_ADVISE" "$C_RESET"
}

add_part() {
  [ -n "$1" ] || return 0
  parts+=("$1")
}

join_parts() {
  local out='' sep='' part
  for part in "${parts[@]}"; do
    out+="${sep}${part}"
    sep="${C_DIM} | ${C_RESET}"
  done
  printf '%s' "$out"
}

main() {
  init
  local input model effort dir session parts=()
  input=$(read_input)
  model=$(json_field "$input" '.model.display_name // empty')
  effort=$(json_field "$input" '.effort.level // empty')
  dir=$(json_field "$input" '.workspace.current_dir // .cwd // empty')
  session=$(session_id "$input")

  add_part "$(venv_badge)"
  add_part "$(model_part "$model" "$effort")"
  add_part "$(dir_part "$dir")"
  add_part "$(git_branch "$dir")"
  add_part "$(caveman_badge)"
  add_part "$(flow_badge "$session")"
  add_part "$(advise_badge "$session")"

  join_parts
}

main
