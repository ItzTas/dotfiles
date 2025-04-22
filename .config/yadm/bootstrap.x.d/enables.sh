#!/bin/bash

_start_enables() {
    local enables=(
        "cronie"
        "docker"
    )
    for enable in "${enables[@]}"; do
        sudo systemctl enable --now "$enable"
    done
}

_start_user_enables() {
    local enables=(
        "arch-update.timer"
    )
    for enable in "${enables[@]}"; do
        systemctl --user enable --now "$enable"
    done
}

_start_enables
_start_user_enables
