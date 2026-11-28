#!/usr/bin/env bash

wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle

icon="mic.svg"
msg="Microphone: Unmuted"
if wpctl get-mute @DEFAULT_AUDIO_SOURCE@ | grep -q true; then
	icon="mic-mute.svg"
	msg="Microphone: Muted"
fi

notify-send -e -i "$ICON_DIR/$icon" -r "$REPLACE_ID" "$msg"
