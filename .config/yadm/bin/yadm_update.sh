#!/bin/env bash

y() {
    (
        set -e

        pacman -Q >"$HOME"/.pacmanlist

        yadm --no-pager diff

        yadm add "$HOME/.pacmanlist"
        yadm add "$HOME/Pictures/.backgrounds"
        yadm add "$HOME/.config/hypr/config"

        yadm add -u :/

        files=$(yadm status -s | awk '{print $2}' | tr '\n' ', ')
        commit_msg="$(date '+%Y-%m-%d %H:%M') - Updated: $files"

        yadm commit -m "$commit_msg"

        yadm push
    )
}

y
