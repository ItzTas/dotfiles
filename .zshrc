#!/usr/bin/env zsh

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

export PATH="$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH"

# load oh-my-posh first
if command -v oh-my-posh >/dev/null 2>&1; then
    if [ -d "$HOME/.config/ohmyposh/my_amro_colors" ]; then
        eval "$(oh-my-posh init zsh --config "$HOME"/.config/ohmyposh/my_amro_colors/my_amro_colors_2.toml)"
    else
        if command -v brew >/dev/null 2>&1 && [ -f "$(brew --prefix oh-my-posh)/themes/amro.omp.json" ]; then
            eval "$(oh-my-posh init zsh --config "$(brew --prefix oh-my-posh)/themes/amro.omp.json")"
        fi
    fi
fi

if [[ -r ~/.zshrc ]]; then
  emulate -L zsh
  zmodload zsh/complist
  autoload -Uz promptinit; promptinit
fi

# --------------------- Plugins ---------------------

__source_zsh_plugins() {
    local plugins_base="$HOME/.config/zsh/plugins"
    local plugins=(
        "zsh-syntax-highlighting"
        "zsh-autosuggestions"
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

# fzf eval in main file for performance reasons
eval "$(fzf --zsh)"
