#!/bin/env bash

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
        local id
        id=$(hyprctl activeworkspace -j | jq -r '.id') || nemo "$fullpath"
        hyprctl dispatch exec "[workspace $id] nemo $fullpath &" || nemo "$fullpath"
        ;;
    esac
}

print_selected_area
