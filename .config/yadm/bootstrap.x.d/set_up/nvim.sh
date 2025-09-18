#!/bin/env bash

_clone_nvim() {
    if [ ! -d "$HOME/.config/nvim" ]; then
        git clone https://github.com/ItzTas/nvim-config-files "$HOME/.config/nvim"
    else
        echo "nvim config directory already exists. Skipping clone."
    fi
}

_set_up_python_molten() {
    (
        local packages=(
            "pynvim"
            "jupyter_client"
            "cairosvg"
            "plotly"
            "kaleido"
            "pnglatex"
            "pyperclip"
            "pyyaml"
            "nbformat"
            "nbclient"
        )
        mkdir -p ~/.virtualenvs
        python3 -m venv ~/.virtualenvs/neovim
        # shellcheck disable=SC1090
        source ~/.virtualenvs/neovim/bin/activate
        local package
        for package in "${packages[@]}"; do
            pip install "$package"
        done
    )
}

_set_up_python_nvim() {
    _set_up_python_molten
}

_set_up() {
    _clone_nvim
    _set_up_python_nvim
}

_set_up
