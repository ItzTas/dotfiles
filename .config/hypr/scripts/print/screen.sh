#!/usr/bin/env bash
# @use open_on

filename="screenshot_$(date '+%Y-%m-%d_%H-%M-%S-%3N').png"
path="$(xdg-user-dir PICTURES)/screenshots"
fullpath="$path/$filename"

mkdir -p "$path"

grim "$fullpath"

sleep 0.2
open_on "sys_print" "$fullpath" "Screenshot saved" "Image saved in $fullpath" "$fullpath" "ocr"
