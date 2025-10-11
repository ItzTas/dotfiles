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

print_selected_area() {
    local filename
    local path
    local fullpath

    filename="screenshot_$(date '+%Y-%m-%d_%H-%M-%S-%3N').png"
    path="$(xdg-user-dir PICTURES)/screenshots"
    fullpath="$path/$filename"

    mkdir -p "$path"

    grim -g "$(slurp)" "$fullpath"

    local ACTION
    ACTION=$(dunstify -a "sys_print" -I "$fullpath" --action="default,open" "Screenshot saved" "Image saved in $fullpath")

    case "$ACTION" in
    "default")
        open "$fullpath"
        ;;
    esac
}

print_selected_area
