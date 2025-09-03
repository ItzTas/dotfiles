#!/usr/bin/env zsh

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

export PATH="$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH"

# --------------------- Plugins ---------------------
# zsh-syntax-highlighting
autoload -U compinit
compinit

source "$HOME/.config/zsh/plugins/settings/zsh-syntax-highlighting/plugin"
source "$HOME/.config/zsh/plugins/repos/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
source "$HOME/.config/zsh/plugins/settings/zsh-autosuggestions/plugin"
source "$HOME/.config/zsh/plugins/repos/zsh-autosuggestions/zsh-autosuggestions.zsh"
# ---------------------------------------------------

__source_zsh_config_files() {
    local zsh_home="$HOME/.config/zsh"
    local files=(
        "exports"
        "aliases"
        "completions"
        "functions"
        "evals"
        "sources"
        "setopt"
        "zstyle"
        "vi-mode"
        "binds"
    )

    local path
    for file in "${files[@]}"; do
        path="$zsh_home/config/$file"
        if [[ -f $path ]]; then
            source "$path"
        fi
    done
}

__source_zsh_config_files
unset -f __source_zsh_config_files
