_find() {
    local dir fifo

    fifo=$(mktemp -u)
    mkfifo "$fifo"

    (zoxide query -l && find "$HOME" -type d) >"$fifo" &

    dir=$(fzf --preview 'eza -A --git --icons --tree --level 3 -F {}' --bind 'ctrl-y:accept' <"$fifo")

    rm "$fifo"

    if [[ -n "$dir" ]]; then
        xdg-open "$dir"
    fi
}

_find
