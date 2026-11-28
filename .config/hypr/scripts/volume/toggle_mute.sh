#!/usr/bin/env bash

wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
muted=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print $3}')

icon="volume.svg"
msg="Audio: Unmuted"
if [ "$muted" = "[MUTED]" ]; then
	icon="volume-mute.svg"
	msg="Audio: Muted"
fi

notify-send "$msg" -e --icon="$ICON_DIR/$icon" --expire-time=500 --replace-id="$REPLACE_ID"
