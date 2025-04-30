#!/usr/bin/env bash

STATUS=$(dunstctl is-paused)

toggle() {
    if [ "$STATUS" == "false" ]; then
        dunstctl set-paused true
        notify-send --urgency=normal "Notifications silenced" "You will not receive notifications."
    else
        dunstctl set-paused false
        notify-send --urgency=normal "Notifications are live." "Notifications have been turned on, no more silence!"
    fi
}

status() {
    if [ "$STATUS" == "false" ]; then
        echo ""
    else
        echo ""
    fi
}

if [[ $1 == "--toggle" ]]; then
    toggle
elif [[ $1 == "--status" ]]; then
    status
fi
