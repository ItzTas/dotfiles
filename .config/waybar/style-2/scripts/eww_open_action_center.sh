#!/bin/bash

EWW_PATH="$HOME/.config/eww/binaryharbinger"

eww() {
    command eww --config "$EWW_PATH" "$@"
}

eww close calendar

is_open=$(eww active-windows | grep -c "actioncenter")

if [ "$is_open" -eq 0 ]; then
    eww update actioncenter_reveal=false
fi

current="$(eww get actioncenter_reveal)"

if [ "$current" = "true" ]; then
    eww close musiccenter
    sleep 0.3
    eww update actioncenter_reveal=false
    sleep 0.2
    eww close actioncenter
else
    eww close musiccenter
    eww open actioncenter
    eww update actioncenter_reveal=true
    sleep 0.3
    eww open musiccenter --toggle --no-daemonize
fi
