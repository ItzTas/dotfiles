#!/bin/env bash

# Proto completions
if command -v proto >/dev/null 2>&1; then
    if [ ! -f "$HOME/.bash_completions/proto.sh" ]; then
        mkdir -p ~/.bash_completions
        proto completions --shell bash >~/.bash_completions/proto.sh
    fi
    # shellcheck disable=SC1090
    source "$HOME/.bash_completions/proto.sh"
fi

# Bootdev completions
if command -v bootdev >/dev/null 2>&1; then
    if [ ! -f "$HOME/.bash_completions/bootdev.sh" ]; then
        mkdir -p ~/.bash_completions
        bootdev completion bash >~/.bash_completions/bootdev.sh
    fi
    # shellcheck disable=SC1090
    source "$HOME/.bash_completions/bootdev.sh"
fi

# Eww completions
if command -v eww >/dev/null 2>&1; then
    if [ ! -f "$HOME/.bash_completions/eww.sh" ]; then
        mkdir -p ~/.bash_completions
        eww shell-completions --shell bash >"$HOME/.bash_completions/eww.sh"
    fi
    # shellcheck disable=SC1090
    source "$HOME/.bash_completions/eww.sh"
fi

# GitBug completions
if command -v git-bug >/dev/null 2>&1; then
    if [ ! -f "$HOME/.bash_completions/gitbug.sh" ]; then
        mkdir -p ~/.bash_completions
        git bug completion bash >"$HOME/.bash_completions/gitbug.sh"
    fi
    # shellcheck disable=SC1090
    source "$HOME/.bash_completions/gitbug.sh"
fi

# bash completion
if [ -f /usr/share/bash-completion/bash_completion ]; then
    source /usr/share/bash-completion/bash_completion
elif [ -f /etc/bash_completion ]; then
    # shellcheck disable=SC1091
    source /etc/bash_completion
fi
