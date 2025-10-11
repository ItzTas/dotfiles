#!/bin/env bash

open() {
    local path="$1"
    local id

    id=$(hyprctl activeworkspace -j | jq -r '.id')

    if [[ -n "$id" && "$id" != "null" ]]; then
        hyprctl dispatch exec "[workspace $id] nemo \"$path\"" || nemo "$path"
        return
    fi
    nemo "$path"
}

print_img() {
    local filename
    filename="screenshot_$(date '+%Y-%m-%d_%H-%M-%S-%3N').png"
    local path
    path="$(xdg-user-dir PICTURES)/screenshots"
    local fullpath="$path/$filename"

    mkdir -p "$path"

    grim "$fullpath"

    local ACTION
    sleep 0.2
    ACTION=$(dunstify -a "sys_print" -I "$fullpath" --action="default,open" "Screenshot saved" "Image saved in $fullpath")

    case "$ACTION" in
    "default")
        open "$fullpath"
        ;;
    esac
}

print_img
