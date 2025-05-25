#!/bin/bash

_handle_fifo() {
    local fifo=$1
    local search_dir=$2

    (zoxide query -l && find "$search_dir" -type d 2>/dev/null) | awk '!seen[$0]++' >"$fifo" &
}

_find() {
    local dir fifo search_dir

    if [[ $1 == "root" ]]; then
        search_dir="/"
    else
        search_dir="$HOME"
    fi

    fifo=$(mktemp -u)
    mkfifo "$fifo"

    _handle_fifo "$fifo" "$search_dir"

    dir=$(
        fzf \
            --preview 'eza -A --git --icons --tree --level 3 -F {}' \
            --bind 'ctrl-y:accept' <"$fifo"
    )

    rm "$fifo"

    if [[ -n "$dir" ]]; then
        hyprscratch nemo "exec nemo \"$dir\""
        exit 0
    fi
}

_find "$1"
