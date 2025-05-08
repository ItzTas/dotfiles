#!/bin/bash
wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
volume=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2 * 100)}')
dunstify -h int:value:"$volume" -i ~/.config/dunst/assets/volume.svg -t 500 -r 2593 "Volume: $volume%"

