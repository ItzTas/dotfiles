#!/usr/bin/env zsh

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

source_zsh_files() {
    local zsh_home="$HOME/.zsh"

    local files=(
        "aliases"
        "functions"
        "binds"
        "exports"
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

source_zsh_files
unset source_zsh_files

