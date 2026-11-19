#!/usr/bin/env bash
# UserPromptSubmit hook: records input-box `!` shell commands into the
# command-history files (project: 500 lines, global: 1000 lines).
# Commands whose name zsh doesn't know (would be "command not found") are
# skipped. Must never block a prompt — always exits 0.

# Prints the name of the command the line runs, skipping leading VAR=value words.
command_name() {
	local -a words
	local word
	read -r -a words <<<"$1"
	for word in "${words[@]}"; do
		[[ $word =~ ^[A-Za-z_][A-Za-z0-9_]*= ]] && continue
		printf '%s' "$word"
		return
	done
}

# Fails only when zsh (with the user's aliases/functions loaded) says the command
# doesn't exist. Names zsh can't check literally (quotes, expansions, subshells,
# `~`) pass, and so does everything when zsh is missing. A plain zsh (~0.01s)
# already knows PATH executables, builtins and keywords; only names it misses
# pay for loading .zshrc (~0.4s) to look at aliases and functions.
command_exists() {
	local name=$1 dir=$2
	[[ $name =~ ^[A-Za-z0-9_./+:@-]+$ ]] || return 0
	command -v zsh >/dev/null || return 0
	(
		cd "${dir:-.}" 2>/dev/null || exit 0
		zsh -c 'whence -- "$1"' zsh "$name" >/dev/null 2>&1 && exit 0
		zsh -ic 'whence -- "$1"' zsh "$name" >/dev/null 2>&1
	)
}

append_capped() {
	local file=$1 cap=$2 cmd=$3
	mkdir -p "$(dirname "$file")" 2>/dev/null || return 0
	printf '%s\n' "$cmd" >>"$file" 2>/dev/null || return 0
	if [ "$(wc -l <"$file")" -gt "$cap" ]; then
		tail -n "$cap" "$file" >"$file.tmp" && mv "$file.tmp" "$file"
	fi
}

main() {
	local input prompt cmd project_file global_file
	input=$(cat) || return 0
	printf '%s\n' "$input" >>/tmp/claude-1000/-home-talinux--claude/fd2f7436-b600-4755-a6de-a3dc59e8b190/scratchpad/hook-input.log # DEBUG: remover
	prompt=$(printf '%s' "$input" | jq -r '.prompt // empty' 2>/dev/null) || return 0

	case "$prompt" in
	'!'*) cmd=${prompt#'!'} ;;
	*) return 0 ;;
	esac

	cmd="${cmd#"${cmd%%[![:space:]]*}"}"
	[ -n "$cmd" ] || return 0
	command_exists "$(command_name "$cmd")" "$(printf '%s' "$input" | jq -r '.cwd // empty' 2>/dev/null)" || return 0

	project_file="${CLAUDE_PROJECT_DIR:-$PWD}/.claude/command-history/history.txt"
	global_file="$HOME/.claude/command-history/history.txt"

	[ "$project_file" != "$global_file" ] && append_capped "$project_file" 500 "$cmd"
	append_capped "$global_file" 1000 "$cmd"
}

main
exit 0
