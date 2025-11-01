#!/bin/env bash

current=$(playerctl --player=spotify volume)

new=$(awk -v v="$current" 'BEGIN { v=v+0.05; if(v>1) v=1; print v }')

playerctl --player=spotify volume "$new"

volume=$(awk -v v="$new" 'BEGIN { print int(v*100 + 0.5) }')

notify-send -e -h "int:value:$volume" -i ~/.config/dunst/assets/volume.svg -t 500 -r 2593 "Spotify: $volume%"
