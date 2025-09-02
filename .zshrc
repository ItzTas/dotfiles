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

# === Plugins section ===
# zsh-autosuggestions
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#8c8caa'

# zsh-syntax-highlighting
typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[default]='fg=#cdd6f4'
ZSH_HIGHLIGHT_STYLES[comment]='fg=#8c8caa'
ZSH_HIGHLIGHT_STYLES[command]='fg=#b4befe'
ZSH_HIGHLIGHT_STYLES[alias]='fg=#cba6f7'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=#9ccfd8'
ZSH_HIGHLIGHT_STYLES[function]='fg=#f5c2e7'
ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=#f38ba8'
ZSH_HIGHLIGHT_STYLES[operator]='fg=#89b4fa'
ZSH_HIGHLIGHT_STYLES[parameter]='fg=#f9e2af'
ZSH_HIGHLIGHT_STYLES[backtick]='fg=#b4befe'
ZSH_HIGHLIGHT_STYLES[single-quote]='fg=#f2cdcd'
ZSH_HIGHLIGHT_STYLES[double-quote]='fg=#f2cdcd'
ZSH_HIGHLIGHT_STYLES[exec]='fg=#89b4fa'
ZSH_HIGHLIGHT_STYLES[precommand]='fg=#d6a8c9'
ZSH_HIGHLIGHT_STYLES[commandseparator]='fg=#89b4fa'
ZSH_HIGHLIGHT_STYLES[hashed-command]='fg=#f5c2e7'
ZSH_HIGHLIGHT_STYLES[path]='fg=#cba6f7'
ZSH_HIGHLIGHT_STYLES[named-directory]='fg=#f9e2af'
ZSH_HIGHLIGHT_STYLES[numeric]='fg=#f5c2e7'
ZSH_HIGHLIGHT_STYLES[history-expansion]='fg=#f38ba8'
ZSH_HIGHLIGHT_STYLES[pattern]='fg=#9ccfd8'
ZSH_HIGHLIGHT_STYLES[redirection]='fg=#89b4fa'
ZSH_HIGHLIGHT_STYLES[globbing]='fg=#cba6f7'
ZSH_HIGHLIGHT_STYLES[error]='fg=#f38ba8'
# -------------------------------------------

__source_zsh_files() {
    local zsh_home="$HOME/.zsh"
    local files=(
        "exports"
        "aliases"
        "completions"
        "functions"
        "binds"
        "evals"
        "sources"
        "setopt"
        "zstyle"
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
unset -f __source_zsh_files
unset -f upgrade_oh_my_zsh

