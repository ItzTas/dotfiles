#!/bin/env bash

yadm_update() {
    (
        set -e

        pacman -Q >"$HOME"/.pacmanlist

        yadm --no-pager diff

        yadm add "$HOME/.pacmanlist"
        yadm add "$HOME/Pictures/.backgrounds"
        yadm add "$HOME/.config/hypr/config"

        yadm add -u :/

        local files
        files=$(yadm status -s | awk '{print $1 " " $2}' | tr '\n' ', ')

        local commit_msg
        commit_msg="$(date '+%Y-%m-%d %H:%M') - Updated: $files"

        yadm commit -m "$commit_msg"
        yadm push
    )
}

yadm_update
