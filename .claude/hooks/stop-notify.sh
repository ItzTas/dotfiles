#!/usr/bin/env bash
# Stop hook: transient desktop notification when Claude finishes a turn and goes idle,
# naming the session (its /rename title, else the auto title), an excerpt of the last prompt,
# the project and the tmux window. Inside tmux, clicking it jumps to the session's pane.

# Prints {title, prompt} from the transcript as JSON ({} when unreadable).
transcript_meta() {
	[[ -r $1 ]] || {
		echo "{}"
		return
	}
	jq -cs '
		def prompt_text:
			.message.content
			| if type == "string" then . else (map(select(.type == "text") | .text) | first) end;
		{
			title: (
				(map(select(.type == "custom-title") | .customTitle) | last)
				// (map(select(.type == "ai-title") | .aiTitle) | last)
			),
			prompt: (
				map(select(.type == "user" and (.isMeta | not)) | prompt_text
					| strings | select(startswith("<") | not))
				| last
				| if . == null then null else gsub("\\s+"; " ") | ltrimstr(" ") end
				| if . != null and length > 110 then .[0:110] + "…" else . end
			)
		}' "$1" 2>/dev/null || echo "{}"
}

# Shows the notification and, if it gets clicked, focuses the tmux pane given as $1.
# shellcheck disable=SC2329 # invoked by the detached bash via export -f
notify_and_focus_on_click() {
	local pane=$1 action
	shift
	action=$(notify-send --action=default=Abrir --wait "$@") || return
	[[ $action == default ]] && ~/.claude/scripts/focus-tmux-pane.sh "$pane"
}

main() {
	local input project meta title prompt where body args
	input=$(cat)
	project=$(jq -r '.cwd // empty' <<<"$input" | xargs -r basename)
	meta=$(transcript_meta "$(jq -r '.transcript_path // empty' <<<"$input")")
	title=$(jq -r '.title // empty' <<<"$meta")
	prompt=$(jq -r '.prompt // empty' <<<"$meta")
	[[ -n $TMUX_PANE ]] && where=$(tmux display -p -t "$TMUX_PANE" '#S:#I' 2>/dev/null)

	body="${prompt:+“$prompt”}"
	body+="${prompt:+$'\n'}${project:-?}${where:+ · tmux $where}"
	args=(--transient --expire-time=6000 --app-name="Claude Code" --icon=dialog-information
		"Claude terminou: ${title:-sessão sem título}" "$body")

	if [[ -z $TMUX_PANE ]]; then
		notify-send "${args[@]}" 2>/dev/null
		return
	fi
	# Waiting for the click runs detached, so the hook returns right away.
	export -f notify_and_focus_on_click
	# shellcheck disable=SC2016 # $@ must expand inside the detached bash, not here
	setsid -f bash -c 'notify_and_focus_on_click "$@"' _ "$TMUX_PANE" "${args[@]}" \
		</dev/null >/dev/null 2>&1
}

main
exit 0
