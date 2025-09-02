#!/usr/bin/env zsh

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# ---------------- oh-my-zsh ----------------
export PATH="$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH"

export ZSH="$HOME/.oh-my-zsh"
export ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"

# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

plugins=(
    "zsh-syntax-highlighting"
    "zsh-autosuggestions"
)

ZSH_CACHE_DIR="$HOME/.cache/oh-my-zsh"
if [[ ! -d "$ZSH_CACHE_DIR" ]]; then
  mkdir "$ZSH_CACHE_DIR"
fi

if [[ -f "$ZSH/oh-my-zsh.sh" ]]; then
    source "$ZSH/oh-my-zsh.sh"
fi
# -------------------------------------------

__source_zsh_files() {
    local zsh_home="$HOME/.zsh"

    local zsh_settings="$zsh_home/settings"
    local setting_files=(
        "exports"
        "aliases"
        "completions"
        "functions"
        "binds"
        "evals"
        "sources"
        "fzf"
        "shopt"
        "zstyle"
    )

    local zsh_plugins_settings="$zsh_home/plugins"
    local plugins_setting_files=(
        "zsh-syntax-highlighting"
    )

    local path
    for file in "${setting_files[@]}"; do
        path="$zsh_settings/$file"
        if [[ -f $path ]]; then
            source "$path"
        fi
    done
    local path
    for file in "${plugins_setting_files[@]}"; do
        path="$zsh_plugins_settings/$file"
        if [[ -f $path ]]; then
            source "$path"
        fi
    done
}

__source_zsh_files
unset -f __source_zsh_files
unset -f upgrade_oh_my_zsh

