#!/usr/bin/env bash

fd_mixed() {
    local excludes=( ".Trash" ".zen" "GLCache" "ferdium/Partitions" ".virtualenvs" "npm/_cacache" )
    local exc_args=()
    for e in "${excludes[@]}"; do
        exc_args+=( -E "$e" )
    done

    fd -H -d 5 -t d "${exc_args[@]}" . "$HOME/Workspace/github.com" "$HOME/Workspace/github.com/ItzTas"

    fd -H -d 3 -t d "${exc_args[@]}" . "$HOME" .
}

_find() {
    sesh connect "$(
        sesh list --icons | fzf-tmux -p 90%,70% \
            --no-sort --ansi --border-label ' sesh ' --prompt '⚡  ' \
            --header '  ^a all ^t tmux ^g configs ^x zoxide ^d tmux kill ^f find' \
            --bind 'tab:down,btab:up' \
            --bind 'ctrl-a:change-prompt(⚡  )+reload(sesh list --icons)' \
            --bind 'ctrl-t:change-prompt(🪟  )+reload(sesh list -t --icons)' \
            --bind 'ctrl-g:change-prompt(⚙️  )+reload(sesh list -c --icons)' \
            --bind 'ctrl-x:change-prompt(📁  )+reload(sesh list -z --icons)' \
            --bind 'ctrl-f:change-prompt(🔎  )+reload(fd -H -d 3 -t d -E .Trash -E .zen -E GLCache -E ferdium/Partitions -E .virtualenvs -E npm/_cacache . ~ ~/Workspace/github.com ~/Workspace/github.com/ItzTas)' \
            --bind 'ctrl-d:execute(chmod +x ~/.config/sesh/scripts/kill_safe.sh && ~/.config/sesh/scripts/kill_safe.sh {2..})+change-prompt(⚡  )+reload(sesh list --icons)' \
            --bind 'ctrl-i:preview-up,ctrl-u:preview-down' \
            --bind 'ctrl-y:accept' \
            --preview-window 'right:50%' \
            --preview 'sesh preview {}'
    )"
}

_find
