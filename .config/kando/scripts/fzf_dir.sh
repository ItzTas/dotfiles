#!/bin/bash

_handle_fifo() {
    local fifo=$1
    local search_dir=$2
    local mode=$3

    if [[ $mode == "file" ]]; then
        find "$search_dir" -type f 2>/dev/null
    else
        zoxide query -l
        find "$search_dir" -type d 2>/dev/null
    fi | awk '!seen[$0]++' >"$fifo" &
}

_find() {
    local selected fifo search_dir mode

    mode="dir"
    search_dir="$HOME"

    for arg in "$@"; do
        [[ "$arg" == "root" ]] && search_dir="/"
        [[ "$arg" == "file" ]] && mode="file"
    done

    fifo=$(mktemp -u)
    mkfifo "$fifo"

    _handle_fifo "$fifo" "$search_dir" "$mode"

    if [[ "$mode" != "file" ]]; then
        selected=$(
            fzf \
                --preview 'lsd --color always --icon always --tree -F --depth 3 {}' \
                --ansi \
                --bind 'ctrl-y:accept' <"$fifo"
        )
    else
        selected=$(
            fzf \
                --preview 'bat --style=numbers --color=always --paging=never {}' \
                --ansi \
                --bind 'ctrl-y:accept' <"$fifo"
        )
    fi

    rm "$fifo"

    if [[ -n "$selected" ]]; then
        trap '' SIGHUP
        nohup nemo "$selected" &>/dev/null 2>&1 &
        disown
        exit 0
    fi
}

_find "$@"
