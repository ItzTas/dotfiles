#!/bin/env bash

y() {
    set -e

    pacman -Q >"$HOME"/.pacmanlist

    yadm --no-pager diff

    yadm add "$HOME/.pacmanlist"

    yadm add "$HOME/.config/yadm/misc/zen-browser/symlinks/chrome"
    yadm add "$HOME/Pictures/.backgrounds"
    yadm add "$HOME/.config/hypr/config"

    yadm commit -am 'updates'

    yadm push
}

y
