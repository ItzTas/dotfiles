#!/usr/bin/env bash

STATUS=$(wpctl get-volume @DEFAULT_AUDIO_SINK@)

if echo "$STATUS" | grep -q '\[MUTED\]'; then
    echo "󰝟"
else
    VOL=$(echo "$STATUS" | awk '{print int($2 * 100)}')

    if [ "$VOL" -ge 80 ]; then
        echo "󰕾"
    elif [ "$VOL" -ge 40 ]; then
        echo "󰖀"
    elif [ "$VOL" -ge 10 ]; then
        echo "󰕿"
    else
        echo "󰝟"
    fi
fi
