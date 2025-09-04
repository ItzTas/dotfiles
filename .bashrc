#!/usr/bin/env bash

# If not running interactively, don't do anything
case $- in
*i*) ;;
*) return ;;
esac

__source_bash_files() {
    local bash_home="$HOME/.config/bash/config"

    local files=(
        "aliases"
        "functions"
        "completions"
        "binds"
        "exports"
        "evals"
        "sources"
        "shopt"
        "oh-my-zsh"
    )

    local file path
    for file in "${files[@]}"; do
        path="$bash_home/$file"
        if [ -f "$path" ]; then
            # shellcheck disable=SC1090
            source "$path"
        fi
    done
}
__source_bash_files
unset __source_bash_files
