#!/usr/bin/env bash

current=$(playerctl -p spotify volume)

new=$(awk -v v="$current" 'BEGIN { v=v-0.05; if(v<0) v=0; print v }')

playerctl -p spotify volume "$new"

volume=$(awk -v v="$new" 'BEGIN { print int(v*100 + 0.5) }')

notify-send -e -h "int:value:$volume" -i ~/.config/dunst/assets/volume.svg -t 500 -r 2593 "Spotify: $volume%"
