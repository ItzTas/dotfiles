#!/bin/env bash

current=$(playerctl --player=spotify volume)

new=$(awk -v v="$current" 'BEGIN { v=v-0.05; if(v<0) v=0; print v }')

playerctl --player=spotify volume "$new"

volume=$(awk -v v="$new" 'BEGIN { print int(v*100) }')

notify-send -a "_transient" -h "int:value:$volume" -i ~/.config/dunst/assets/volume.svg -t 500 -r 2593 "Spotify: $volume%"
