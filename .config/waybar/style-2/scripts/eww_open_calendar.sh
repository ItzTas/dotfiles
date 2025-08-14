#!/bin/env bash

EWW_PATH="$HOME/.config/eww/binaryharbinger"

eww() {
    command eww --config "$EWW_PATH" "$@"
}

eww open calendar --toggle --no-daemonize &
eww close actioncenter musiccenter
