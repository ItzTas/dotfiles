#!/bin/env bash

launch() {
    local style_num="$1"
    local style="style-$style_num"
    local path="$HOME/.config/waybar/$style"

    waybar -c "$path/config.jsonc" -s "$path/style.css"
}

launch "$@"
