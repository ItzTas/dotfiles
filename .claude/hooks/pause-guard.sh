#!/usr/bin/env bash
# PreToolUse hook: while ~/.claude/state/pause exists (created by claude-pause), blocks every tool
# call, so each session stops between two actions instead of in the middle of one.
# The first block in a session asks Claude to note where it stopped; any later one ends the turn.

flag=~/.claude/state/pause
[[ -e $flag ]] || exit 0

IFS=$'\t' read -r session tool command < <(jq -r '[.session_id, .tool_name, (.tool_input.command // "")] | @tsv')

# Lets a session turn the pause off when asked to.
[[ $tool == Bash && $command == *claude-resume* ]] && exit 0

marker=$flag.d/$session
if [[ -e $marker ]]; then
	jq -n '{
		continue: false,
		stopReason: "Pausado pelo claude-pause",
		hookSpecificOutput: {
			hookEventName: "PreToolUse",
			permissionDecision: "deny",
			permissionDecisionReason: "Paused by claude-pause"
		}
	}'
	exit 0
fi

mkdir -p "$flag.d"
touch "$marker"
cat >&2 <<'EOF'
Paused by the user (claude-pause): they are shutting down or need the CPU. Do not call any more
tools. Reply with a short note in the conversation's language: what you were doing, what is done,
and the exact next step, so the work can resume later. Then end your turn.
EOF
exit 2
