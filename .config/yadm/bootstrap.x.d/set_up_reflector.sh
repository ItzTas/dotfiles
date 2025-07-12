_set_up() {
    local reflector_config_file="$HOME/.config/reflector/reflector.conf"
    local system_config_dir="/etc/xdg/reflector"

    if [ ! -d "$system_config_dir" ]; then
        echo "Creating directory $system_config_dir"
        sudo mkdir -p "$system_config_dir"
    fi

    echo "Copying $reflector_config_file to $system_config_dir/"
    sudo cp -f "$reflector_config_file" "$system_config_dir/reflector.conf"

    sudo chmod 644 /etc/xdg/reflector/reflector.conf

    sudo systemctl enable --now reflector.timer
}

_set_up
