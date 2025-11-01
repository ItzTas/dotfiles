#!/bin/bash

wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
muted=$(wpctl get-mute @DEFAULT_AUDIO_SOURCE@)
if [[ "$muted" == *"true"* ]]; then
    icon="mic-mute.svg"
    message="Microphone: Muted"
else
    icon="mic.svg"
    message="Microphone: Unmuted"
fi
notify-send -e -i ~/.config/dunst/assets/"$icon" -r 2593 "$message"
