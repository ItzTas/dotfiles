#!/usr/bin/env bash

hyprctl dispatch exec "[workspace 9] spotify" || spotify &

# while ! playerctl -p spotify status &>/dev/null; do
#     sleep 0.05
# done

sleep 0.8

playerctl -p spotify play

