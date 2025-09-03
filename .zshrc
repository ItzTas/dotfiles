#!/usr/bin/env zsh

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

export PATH="$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH"

emulate -L zsh
zmodload zsh/complist
autoload -Uz promptinit; promptinit

# load prompt before everything
if [[ -f "$HOME/.config/zsh/config/prompt" ]]; then
    source "$HOME/.config/zsh/config/prompt"
fi

# --------------------- Plugins ---------------------

__source_zsh_plugins() {
    local plugins_base="$HOME/.config/zsh/plugins"
    local plugins=(
        "zsh-autosuggestions"
        "zsh-syntax-highlighting"
    )

    local plugin
    for plugin in "${plugins[@]}"; do
        if [[ -f "$plugins_base/settings/$plugin" ]]; then
            source "$plugins_base/settings/$plugin"
        elif [[ -f "$plugins_base/settings/$plugin/settings" ]]; then  
            source "$plugins_base/settings/$plugin/settings"
        fi

        local plugin_path="$plugins_base/repos/$plugin/$plugin.zsh"
        if [[ -f "$plugin_path" ]]; then  
            source "$plugin_path"
        fi
    done
}

autoload -U compinit
compinit
__source_zsh_plugins
unset -f __source_zsh_plugins

# ---------------------------------------------------

__source_zsh_config_files() {
    local zsh_home="$HOME/.config/zsh"
    local files=(
        "envs"
        "evals"
        "aliases"
        "completions"
        "functions"
        "sources"
        "setopt"
        "zstyle"
        "vi-mode"
        "binds"
        "fzf"
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
