#!/usr/bin/env bash
# Stop hook: transient desktop notification when Claude finishes a turn and goes idle,
# naming the session (its /rename title, else the auto title), an excerpt of the last prompt,
# the project and the tmux window.
input=$(cat)
project=$(jq -r '.cwd // empty' <<<"$input" | xargs -r basename)
transcript=$(jq -r '.transcript_path // empty' <<<"$input")

meta="{}"
if [[ -r $transcript ]]; then
	meta=$(jq -cs '
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
		}' "$transcript" 2>/dev/null) || meta="{}"
fi
title=$(jq -r '.title // empty' <<<"$meta")
prompt=$(jq -r '.prompt // empty' <<<"$meta")

where=""
if [[ -n $TMUX_PANE ]]; then
	where=$(tmux display -p -t "$TMUX_PANE" '#S:#I' 2>/dev/null)
fi

body="${prompt:+“$prompt”}"
body+="${prompt:+$'\n'}${project:-?}${where:+ · tmux $where}"

notify-send --transient --expire-time=3000 --app-name="Claude Code" --icon=dialog-information \
	"Claude terminou: ${title:-sessão sem título}" "$body" 2>/dev/null
exit 0
