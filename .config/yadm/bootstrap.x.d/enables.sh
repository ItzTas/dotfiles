#!/bin/env bash

_start_enables() {
    local enables=(
        "cronie"
        "docker"
        "minidlna"
        "swayosd-libinput-backend.service"
    )

    for enable in "${enables[@]}"; do
        if ! systemctl list-unit-files | grep -q "^$enable"; then
            echo "service \"$enable\" does not exist, skipping..."
            continue
        fi

        echo "enabling service: \"$enable\""
        sudo systemctl enable --now "$enable"
    done
}

_start_enables
