#!/usr/bin/env zsh

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

export PATH="$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH"

# --------------------- Plugins ---------------------
export ZSH="$HOME/.oh-my-zsh"
export ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"

# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

plugins=(
    "zsh-syntax-highlighting"
    "zsh-autosuggestions"
)

if [[ -f "$ZSH/oh-my-zsh.sh" ]]; then
    source "$ZSH/oh-my-zsh.sh"
fi

# === Plugins section ===
# zsh-autosuggestions

# zsh-syntax-highlighting
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main cursor)
typeset -gA ZSH_HIGHLIGHT_STYLES
source "$HOME/.config/zsh/config/zsh-syntax-highlighting"
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
unset -f upgrade_oh_my_zsh
