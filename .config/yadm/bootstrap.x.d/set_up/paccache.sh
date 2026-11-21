#!/usr/bin/env bash

_install_pacman_contrib() {
    if pacman -Q pacman-contrib &>/dev/null; then
        return
    fi
    yes | paru -S --needed pacman-contrib
}

_set_keep_versions() {
    local config_file="/etc/conf.d/pacman-contrib"
    local args="PACCACHE_ARGS='-k2'"

    if grep -q '^PACCACHE_ARGS=' "$config_file" 2>/dev/null; then
        sudo sed -i "s/^PACCACHE_ARGS=.*/$args/" "$config_file"
        return
    fi
    echo "$args" | sudo tee -a "$config_file" >/dev/null
}

_set_up() {
    _install_pacman_contrib
    _set_keep_versions
    sudo systemctl enable --now paccache.timer
}

_set_up
