#!/bin/bash

wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
muted=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print $3}')
if [[ "$muted" == "[MUTED]" ]]; then
    icon="volume-mute.svg"
    message="Audio: Muted"
else
    icon="volume.svg"
    message="Audio: Unmuted"
fi
notify-send "$message" \
    --icon="$HOME/.config/dunst/assets/$icon" \
    --expire-time=500 \
    --replace-id=2593 \
    -a "_transient"
