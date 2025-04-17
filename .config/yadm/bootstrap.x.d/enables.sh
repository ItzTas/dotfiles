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

_start_enables
