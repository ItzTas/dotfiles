#!/usr/bin/env bash
hyprctl dispatch exec "[workspace 9; silent] spotify" || spotify &

{
    count=0
    until playerctl -l 2>/dev/null | grep -q spotify || [ "$count" -ge 20 ]; do
        sleep 0.5
        ((count++))
    done
} || true

sleep 2

playerctl -p spotify volume 0 2>/dev/null || true
playerctl -p spotify play 2>/dev/null || true
