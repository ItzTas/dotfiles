#!/usr/bin/env bash
# Claude Code statusLine command
# Mirrors the oh-my-posh prompt: user  path  git  |  model  context  time

input=$(cat)

# --- Extract fields ---
user=$(whoami)
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // empty')
cwd_display="${cwd/#$HOME/\~}"

model=$(echo "$input" | jq -r '.model.display_name // empty')

# Git info (from workspace repo / worktree branch)
git_branch=""
git_dirty=""
if [ -n "$cwd" ]; then
    branch=$(git -C "$cwd" --no-optional-locks rev-parse --abbrev-ref HEAD 2>/dev/null)
    if [ -n "$branch" ]; then
        git_branch="$branch"
        dirty=$(git -C "$cwd" --no-optional-locks status --porcelain 2>/dev/null)
        [ -n "$dirty" ] && git_dirty="*"
    fi
fi

# Context window
remaining=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty')
ctx_part=""
if [ -n "$remaining" ]; then
    ctx_part="ctx:$(printf '%.0f' "$remaining")%"
fi

# Time
time_part=$(date +%H:%M:%S)

# --- Build output with ANSI colors ---
# Colors matching the ohmyposh theme (dimmed in status bar but kept readable)
C_USER='\033[38;2;180;190;254m'   # #B4BEFE  lavender
C_PATH='\033[38;2;106;127;234m'   # #6A7FEA  cornflower blue
C_GIT='\033[38;2;20;165;174m'     # #14A5AE  teal
C_TIME='\033[38;2;184;196;199m'   # #B8C4C7  light grey
C_MODEL='\033[38;2;208;103;157m'  # #D0679D  pink
C_CTX='\033[38;2;80;200;120m'     # soft green
R='\033[0m'

line=""

# leading icon (Nerd Font glyph built from its codepoint so the file stays ASCII)
# Change U+F007 to whatever icon you want.
icon=$(printf ' ')
line+="${C_USER}${icon}${R}"

# user segment
line+="${C_USER} ${user}${R}"

# path segment (U+F115 folder icon, built from codepoint)
path_icon=$(printf '')
line+=" ${C_PATH}${path_icon} ${cwd_display}${R}"

# git segment
if [ -n "$git_branch" ]; then
    line+=" ${C_GIT} ${git_branch}${git_dirty}${R}"
fi

# separator
line+=" |"

# model
if [ -n "$model" ]; then
    line+=" ${C_MODEL}${model}${R}"
fi

# context
if [ -n "$ctx_part" ]; then
    line+=" ${C_CTX}${ctx_part}${R}"
fi

# time
line+=" ${C_TIME}${time_part}${R}"

printf "%b\n" "$line"
