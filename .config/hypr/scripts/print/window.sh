#!/bin/env bash

print_window() {
    local filename path fullpath

    filename="screenshot_$(date '+%Y-%m-%d_%H-%M-%S-%3N').png"
    path="$(xdg-user-dir PICTURES)/screenshots"
    fullpath="$path/$filename"

    mkdir -p "$path"

    hyprshot -m window -s -o "$path" -f "$filename"

    local max_retries=20
    local retry_interval=0.1
    for ((i = 1; i <= max_retries; i++)); do
        if [ -f "$fullpath" ]; then
            sleep 0.6
            break
        fi
        sleep "$retry_interval"
    done

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

print_window
