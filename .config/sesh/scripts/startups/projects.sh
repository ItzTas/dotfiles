#!/bin/env bash

_f() {
    local original_path="$PWD"
    local selection
    selection=$(
        find . \
            -maxdepth 1 -mindepth 1 \
            \( -name ".*" -o -name "*" \) \
            -printf '%P\n' |
            fzf \
                --bind "ctrl-y:accept" \
                --preview="lsd --tree --icon always --color always --depth 2 {}"
    )
    if [[ -n "$selection" ]]; then
        cd "$selection" || return
    else
        cd "$original_path" || return
    fi
    clear
    exec "$SHELL"
}

_f
