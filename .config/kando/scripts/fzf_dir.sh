#!/bin/env bash

_handle_fifo() {
    local fifo
    fifo=$1

    (zoxide query -l && find "$HOME" -type d) | awk '!seen[$0]++' >"$fifo" &
}

_find() {
    local dir fifo

    fifo=$(mktemp -u)
    mkfifo "$fifo"

    _handle_fifo "$fifo"

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

_find
