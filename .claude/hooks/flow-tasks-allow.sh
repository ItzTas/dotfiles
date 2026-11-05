#!/usr/bin/env bash
# PreToolUse hook: auto-approves writes that stay inside the current session's
# FLOW MODE task folder, <project>/.claude/tasks/<session_id>/ (see
# ~/.claude/commands/flow.md, rule 5).
#
# .claude/ is a protected path, and permissions.allow rules in settings don't
# pre-approve it, so this hook is the only way to skip those prompts.
#
# Covers:
#   - Write / Edit / MultiEdit / NotebookEdit whose target is in the folder;
#   - Bash running ONE simple file command (mkdir, rm, rmdir, mv, cp, touch)
#     whose path arguments are all in the folder;
#   - Bash saving the clipboard (wl-paste / xclip ... > file) into the folder.
#
# Anything else (other sessions' folders, compound shell commands, quoting,
# expansions, symlinked folders) gets no decision, so the normal permission
# flow applies. Never denies, always exits 0. Deny hooks (advise-guard) still
# win over this allow.

session_dir=""
cwd=""

approve() {
  printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"allow","permissionDecisionReason":"FLOW MODE: write inside this session'"'"'s own task folder"}}\n'
  exit 0
}

# Resolves the session folder, refusing symlinks on the way so a link can't
# redirect the approval somewhere else.
resolve_session_dir() {
  local project=$1 session=$2 root
  [[ $session =~ ^[A-Za-z0-9-]+$ ]] || return 1
  root=$(realpath -m -- "$project") || return 1
  local part path=$root
  for part in .claude tasks "$session"; do
    path="$path/$part"
    [ -L "$path" ] && return 1
  done
  printf '%s' "$path"
}

inside_session_dir() {
  local target=$1 resolved
  [ -n "$target" ] || return 1
  [[ $target == /* ]] || target="$cwd/$target"
  resolved=$(realpath -m -- "$target") || return 1
  [ "$resolved" = "$session_dir" ] && return 0
  [[ $resolved == "$session_dir"/* ]]
}

# Every non-flag argument must be a path inside the session folder.
all_paths_inside() {
  local arg count=0
  for arg in "$@"; do
    [[ $arg == -* ]] && continue
    inside_session_dir "$arg" || return 1
    count=$((count + 1))
  done
  [ "$count" -gt 0 ]
}

check_bash() {
  local command=$1
  # No chaining, pipes, substitutions, globs, quoting or escapes: only plain
  # words, so the whitespace split below is what the shell will run.
  [[ $command == *[\;\&\|\$\`\(\)\<\{\}\*\?\[\]\~\'\"\\]* ]] && return 0
  [[ $command == *$'\n'* ]] && return 0

  local -a words
  read -r -a words <<<"$command"
  [ "${#words[@]}" -gt 0 ] || return 0

  local -A file_commands=([mkdir]=1 [rm]=1 [rmdir]=1 [mv]=1 [cp]=1 [touch]=1)
  local -A clipboard_commands=(["wl-paste"]=1 [xclip]=1)
  local program=${words[0]}

  if [ -n "${file_commands[$program]}" ]; then
    [[ $command == *'>'* ]] && return 0
    all_paths_inside "${words[@]:1}" && approve
    return 0
  fi

  [ -n "${clipboard_commands[$program]}" ] || return 0
  # Exactly one '>' redirect, as the second-to-last word, into the folder.
  local count=${#words[@]}
  [ "$count" -ge 3 ] || return 0
  [ "${words[count - 2]}" = ">" ] || return 0
  local before=${command%>*}
  [[ $before == *'>'* ]] && return 0
  inside_session_dir "${words[count - 1]}" && approve
  return 0
}

main() {
  local input tool session project
  input=$(cat) || return 0
  tool=$(jq -r '.tool_name // empty' <<<"$input" 2>/dev/null) || return 0
  session=$(jq -r '.session_id // empty' <<<"$input" 2>/dev/null) || return 0
  cwd=$(jq -r '.cwd // empty' <<<"$input" 2>/dev/null) || return 0
  project=${CLAUDE_PROJECT_DIR:-$cwd}
  [ -n "$project" ] && [ -n "$cwd" ] || return 0
  session_dir=$(resolve_session_dir "$project" "$session") || return 0

  local -A file_tools=([Write]=1 [Edit]=1 [MultiEdit]=1 [NotebookEdit]=1)
  if [ -n "${file_tools[$tool]}" ]; then
    local target
    target=$(jq -r '.tool_input.file_path // .tool_input.notebook_path // empty' <<<"$input" 2>/dev/null) || return 0
    inside_session_dir "$target" && approve
    return 0
  fi

  [ "$tool" = "Bash" ] || return 0
  local command
  command=$(jq -r '.tool_input.command // empty' <<<"$input" 2>/dev/null) || return 0
  check_bash "$command"
}

main
exit 0
