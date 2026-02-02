#!/usr/bin/env bash

launch() {
    local style_num="$1"
    : "${style_num:=1}"
    local style="style-$style_num"
    local path="$HOME/.config/waybar/$style"

    local config_file

    if [ -f "$path/config.jsonc" ]; then
        config_file="$path/config.jsonc"
    elif [ -f "$path/config" ]; then
        config_file="$path/config"
    else
        echo "Error: No config file found in '$path'" >&2
        return 1
    fi

    local style_file="$path/style.css"

    local log_file="$HOME/.cache/waybar-$style.log"

    waybar -c "$config_file" -s "$style_file" >"$log_file" 2>&1 &
    disown
}

launch "$@"
