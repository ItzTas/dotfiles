#!/usr/bin/env bash

fd_mixed() {
    local excludes=(".Trash" ".zen" "GLCache" "ferdium/Partitions" ".virtualenvs" "npm/_cacache")
    local exc_args=()
    for e in "${excludes[@]}"; do
        exc_args+=(-E "$e")
    done

    fd -H -d 5 -t d "${exc_args[@]}" . "$HOME/Workspace/github.com" "$HOME/Workspace/github.com/ItzTas"

    fd -H -d 3 -t d "${exc_args[@]}" . "$HOME" .
}

fd_mixed
