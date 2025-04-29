#!/usr/bin/env bash
STATUS=$(wpctl get-volume @DEFAULT_AUDIO_SINK@)
toggle() {
    wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
}

status() {
    if echo "$STATUS" | grep -q '\[MUTED\]'; then
        echo "󰖁"
    else
        echo "󰕾"
    fi
}

if [[ $1 == "--toggle" ]]; then
    toggle
elif [[ $1 == "--status" ]]; then
    status
fi
