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
dunstify -a _transient -i ~/.config/dunst/assets/$icon -t 500 -r 2593 "$message"

