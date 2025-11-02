#!/usr/bin/env bash

session="$1"

if [ "$session" != "default" ]; then
    tmux kill-session -t "$session"
else
    notify-send -e "Cannot kill session default" -t 500
fi
