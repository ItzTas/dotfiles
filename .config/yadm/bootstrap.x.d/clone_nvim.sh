#!/bin/env bash

_clone_nvim() {
    if [ ! -d "$HOME/.config/nvim" ]; then
        git clone https://github.com/ItzTas/nvim-config-files "$HOME/.config/nvim"
    else
        echo "nvim config directory already exists. Skipping clone."
    fi
}

_clone_nvim
