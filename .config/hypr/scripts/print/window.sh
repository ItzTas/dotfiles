#!/bin/env bash

print_window() {
    local filename
    local path
    local fullpath
    local ACTION

    filename="screenshot_$(date '+%Y-%m-%d_%H-%M-%S-%3N').png"
    path="$(xdg-user-dir PICTURES)/screenshots"
    fullpath="$path/$filename"

    mkdir -p "$path"

    hyprshot -m window -s -o "$path" -f "$filename"

    sleep 0.2

    ACTION=$(dunstify -a "sys_print" -I "$fullpath" --action="default,open" "Screenshot saved" "Image saved in $fullpath")

    case "$ACTION" in
    "default") nemo "$fullpath" & ;;
    esac
}

print_window
