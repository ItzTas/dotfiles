_set_up() {
    sudo systemctl enable --now opensnitchd
}

if command -v opensnitchd &>/dev/null; then
    _set_up
fi
