y() {
    set -e

    pacman -Q >"$HOME"/.pacmanlist

    yadm --no-pager diff

    yadm add "$HOME"/.pacmanlist

    yadm commit -am 'updates'

    yadm push
}

y
