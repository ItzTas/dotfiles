#!/bin/bash

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

_record() {
    if pgrep wf-recorder; then
        killall wf-recorder
        exit 0
    fi

    local dir="$HOME/Videos/.recordings/system"
    mkdir -p "$dir"

    local filename basename
    filename="$dir/recording_$(date '+%Y-%m-%d_%H-%M-%S').mp4"
    basename=$(basename "$filename")

    notify-send -a "sys_recording" "Recording Started" "Recording to $filename" || exit 1

    if ! wf-recorder -f "$filename"; then
        dunstify "Error" "Failed to start recording"
        exit 1
    fi

    local tmpdir
    tmpdir=$(mktemp -d)
    local thumbnail="$tmpdir/thumbnail.png"
    rm -f "$thumbnail"

    if ! ffmpeg -y -i "$filename" -vframes 1 "$thumbnail"; then
        dunstify "Error" "Failed to generate thumbnail"
        rm -rf "$tmpdir"
        exit 1
    fi

    local action
    action=$(dunstify -a "sys_recording" -i "$thumbnail" --action="default,open" "Recording Finished" "The recording has been saved as $basename")

    rm -rf "$tmpdir"

    case "$action" in
    "default")
        open "$filename"
        ;;
    esac
}

_record
