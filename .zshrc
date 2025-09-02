#!/usr/bin/env zsh

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

__source_zsh_files() {
    local zsh_home="$HOME/.zsh"

    local files=(
        "exports"
        "aliases"
        "functions"
        "binds"
        "evals"
        "sources"
        "fzf"
        "shopt"
    )

    local path
    for file in "${files[@]}"; do
        path="$zsh_home/$file"
        if [[ -f $path ]]; then
            source "$path"
        fi
    done
}

__source_zsh_files
unset __source_zsh_files

