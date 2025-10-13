#!/usr/bin/env zsh

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# load history file before everything
HISTFILE="${XDG_CONFIG_HOME:-$HOME/.config}/zsh/history"

# load prompt before everything
if [[ -f "$HOME/.config/zsh/config/prompt" ]]; then
    source "$HOME/.config/zsh/config/prompt"
fi

# load path before everything
if [[ -f "$HOME/.config/zsh/config/path" ]]; then
    source "$HOME/.config/zsh/config/path"
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
        "fzf"
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

autoload -Uz compinit
compinit 

# pnpm
export PNPM_HOME="/home/talinux/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
