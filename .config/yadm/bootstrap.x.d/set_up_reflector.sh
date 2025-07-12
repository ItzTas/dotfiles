_set_up() {
    local reflector_config_file="$HOME/.config/reflector/reflector.conf"

    sudo ln -sf "$reflector_config_file" "/etc/xdg/reflector/reflector.conf"
}

_set_up
