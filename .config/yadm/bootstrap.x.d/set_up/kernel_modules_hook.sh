#!/usr/bin/env bash

_install_kernel_modules_hook() {
    if pacman -Q kernel-modules-hook &>/dev/null; then
        return
    fi
    yes | paru -S --needed kernel-modules-hook
}

_set_up() {
    _install_kernel_modules_hook
    sudo systemctl enable linux-modules-cleanup.service
}

_set_up
