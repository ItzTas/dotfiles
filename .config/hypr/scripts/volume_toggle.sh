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
dunstify -i ~/.config/dunst/assets/$icon -t 500 -r 2593 "$message"
