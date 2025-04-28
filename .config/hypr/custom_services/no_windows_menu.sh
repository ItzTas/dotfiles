#!/bin/bash

windows_count=$(hyprctl activeworkspace | grep -oP 'windows: \K\d+')

if [ "$windows_count" -eq 0 ]; then
    rofi -show run &
else
    pkill rofi
fi

