#!/usr/bin/env bash

session="$1"

if [ "$session" != "default" ]; then
    tmux kill-session -t "$session"
else
    notify-send -a "_transient" "Cannot kill session default"
fi
