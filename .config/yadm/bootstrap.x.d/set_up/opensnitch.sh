create_symlinks() {
    local dir = "$HOME/.config/opensnitch"
    mkdir -p "$dir/rules"

    sudo ln -s "$dir/rules" /etc/opensnitchd/rules
}

_set_up() {
    sudo systemctl enable --now opensnitchd
    create_symlinks
}

if command -v opensnitchd &>/dev/null; then
    _set_up
fi
