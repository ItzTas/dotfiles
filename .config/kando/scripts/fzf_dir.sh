_find() {
    local dir z_dirs

    z_dirs=$(zoxide query -l | sed "s|$HOME|~|")

    dir=$(echo -e "$z_dirs\n$(find "$HOME" -type d)" | fzf --preview 'eza --icons --tree --level 3 -F {}')

    if [[ -n "$dir" ]]; then
        xdg-open "$dir"
    fi
}

_find
