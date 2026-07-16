#!/usr/bin/env bash
# UserPromptSubmit hook: records input-box `!` shell commands into the
# command-history files (project: 500 lines, global: 1000 lines).
# Must never block a prompt — always exits 0.

append_capped() {
  local file=$1 cap=$2 cmd=$3
  mkdir -p "$(dirname "$file")" 2>/dev/null || return 0
  printf '%s\n' "$cmd" >> "$file" 2>/dev/null || return 0
  if [ "$(wc -l < "$file")" -gt "$cap" ]; then
    tail -n "$cap" "$file" > "$file.tmp" && mv "$file.tmp" "$file"
  fi
}

main() {
  local input prompt cmd project_file global_file
  input=$(cat) || return 0
  prompt=$(printf '%s' "$input" | jq -r '.prompt // empty' 2>/dev/null) || return 0

  case "$prompt" in
    '!'*) cmd=${prompt#'!'} ;;
    *) return 0 ;;
  esac

  cmd="${cmd#"${cmd%%[![:space:]]*}"}"
  [ -n "$cmd" ] || return 0

  project_file="${CLAUDE_PROJECT_DIR:-$PWD}/.claude/command-history/history.txt"
  global_file="$HOME/.claude/command-history/history.txt"

  [ "$project_file" != "$global_file" ] && append_capped "$project_file" 500 "$cmd"
  append_capped "$global_file" 1000 "$cmd"
}

main
exit 0
