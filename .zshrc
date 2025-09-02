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

# zsh-syntax-highlighting
typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[default]='fg=250'
ZSH_HIGHLIGHT_STYLES[command]='fg=175'
ZSH_HIGHLIGHT_STYLES[alias]='fg=175'   
ZSH_HIGHLIGHT_STYLES[builtin]='fg=166'  
ZSH_HIGHLIGHT_STYLES[function]='fg=104'  
ZSH_HIGHLIGHT_STYLES[precommand]='fg=141' 
ZSH_HIGHLIGHT_STYLES[valid_path]='fg=109'  
ZSH_HIGHLIGHT_STYLES[error]='fg=160'         
ZSH_HIGHLIGHT_STYLES[comment]='fg=244'      
ZSH_HIGHLIGHT_STYLES[quote]='fg=221'          
ZSH_HIGHLIGHT_STYLES[commandseparator]='fg=248'
ZSH_HIGHLIGHT_STYLES[history]='fg=245'
ZSH_HIGHLIGHT_STYLES[unknown]='fg=252'
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

