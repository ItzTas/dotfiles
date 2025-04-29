#!/usr/bin/env bash

MIC_STATUS=$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@)

if echo "$MIC_STATUS" | grep -q '\[MUTED\]'; then
    echo "󰍭"
else
    VOL=$(echo "$MIC_STATUS" | awk '{print int($2 * 100)}')

    if [ "$VOL" -ge 80 ]; then
        echo "󰍬"
    elif [ "$VOL" -ge 40 ]; then
        echo "󰍬"
    elif [ "$VOL" -ge 10 ]; then
        echo "󰍬"
    else
        echo "󰍭"
    fi
fi

