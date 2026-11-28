#!/usr/bin/env bash
# Changes Spotifast's own volume by $1 (e.g. 0.05 or -0.05), clamped to 0-1.

delta="$1"

status=$(playerctl -p spotifast status 2>&1)
if [[ -z "$status" ]] || grep -q "No players found" <<<"$status"; then
	exit 0
fi

current=$(playerctl -p spotifast volume)
new=$(awk -v v="$current" -v d="$delta" 'BEGIN { v += d; if (v > 1) v = 1; if (v < 0) v = 0; print v }')
playerctl -p spotifast volume "$new"

vol=$(awk -v v="$new" 'BEGIN { print int(v * 100 + 0.5) }')
notify-send -e -h "int:value:$vol" -i "$ICON_DIR/volume.svg" -t 500 -r "$REPLACE_ID" "Spotify: $vol%"
