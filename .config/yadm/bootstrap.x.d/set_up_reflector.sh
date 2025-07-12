_set_up() {
    local reflector_config_file="$HOME/.config/reflector/reflector.conf"
    local system_config_dir="/etc/xdg/reflector"

    if [ ! -d "$system_config_dir" ]; then
        echo "Creating directory $system_config_dir"
        sudo mkdir -p "$system_config_dir"
    fi

    echo "Creating symlink from $reflector_config_file to /etc/xdg/reflector/reflector.conf"
    sudo ln -fs "$reflector_config_file" "$system_config_dir/reflector.conf"
}

_set_up
