#!/bin/bash

case "$1" in
speaker)
    vol=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null | awk '{print $2}')
    percent=$(printf "%.0f" "$(echo "$vol * 100" | bc -l)")

    if wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -qi 'muted'; then
        echo 0
    else
        echo "$percent"
    fi
    ;;
mic)
    src=$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@ 2>/dev/null | awk '{print $2}')
    fmt=$(printf "%.0f" "$(echo "$src * 100" | bc -l)")
    echo "$fmt"
    ;;
*)
    echo "Usage: $0 {speaker|mic}"
    exit 1
    ;;
esac
