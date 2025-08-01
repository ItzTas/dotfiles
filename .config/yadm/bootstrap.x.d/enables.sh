#!/bin/env bash

_start_enables() {
    local enables=(
        "cronie"
        "docker"
        "swayosd-libinput-backend.service"
        "ufw"
    )
    for enable in "${enables[@]}"; do
        sudo systemctl enable --now "$enable"
    done
}

_start_enables
