#!/usr/bin/env bash
# UserPromptSubmit hook: tracks FLOW MODE (~/.claude/commands/flow.md) state so
# the statusline can show a [FLOW] / [FLOW:PAUSED] badge.
#
# State lives in $CLAUDE_CONFIG_DIR/.flow-active-<session_id> — per session,
# because two parallel Claude Code sessions can be in different modes.
#
# Must never block a prompt — always exits 0.

CONFIG_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"

write_state() {
  local file=$1 state=$2
  [ -L "$file" ] && return 0
  ( umask 077; printf '%s' "$state" > "$file.tmp" ) 2>/dev/null || return 0
  mv "$file.tmp" "$file" 2>/dev/null || rm -f "$file.tmp" 2>/dev/null
}

# Decide the new state from the prompt. Echoes: active | paused | off | (empty
# for "no change").
classify() {
  local p=$1

  case "$p" in
    # Explicit exits, slash form and plain words.
    /flow\ end*|/flow\ out*|/flow\ off*|/flow\ stop*|/flow\ exit*) printf 'off'; return 0 ;;
    *"exit flow"*|*"end flow"*|*"leave flow"*|*"stop flow"*|*"sair do flow"*|*"encerrar flow"*)
      printf 'off'; return 0 ;;
    /flow\ pause*) printf 'paused'; return 0 ;;
    /flow\ resume*) printf 'active'; return 0 ;;
    # Read-only subcommands: mode unchanged.
    /flow\ status*|/flow\ recap*|/flow\ help*) return 0 ;;
    # Any other /flow invocation enters (or stays in) the mode.
    /flow|/flow\ *) printf 'active'; return 0 ;;
  esac
}

main() {
  local input prompt lower state file
  input=$(cat) || return 0
  prompt=$(printf '%s' "$input" | jq -r '.prompt // empty' 2>/dev/null) || return 0
  [ -n "$prompt" ] || return 0

  lower=$(printf '%s' "$prompt" | tr '[:upper:]' '[:lower:]')
  state=$(classify "$lower")
  [ -n "$state" ] || return 0

  local session
  session=$(printf '%s' "$input" | jq -r '.session_id // empty' 2>/dev/null | tr -cd 'a-zA-Z0-9-')
  [ -n "$session" ] || return 0

  # Sessions end without a shutdown hook, so old flags would pile up.
  find "$CONFIG_DIR" -maxdepth 1 -name '.flow-active-*' -type f -mtime +7 -delete 2>/dev/null

  file="$CONFIG_DIR/.flow-active-$session"
  if [ "$state" = "off" ]; then
    [ -L "$file" ] || rm -f "$file" 2>/dev/null
    return 0
  fi
  write_state "$file" "$state"
}

main
exit 0
