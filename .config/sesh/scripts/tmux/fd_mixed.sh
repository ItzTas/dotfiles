#!/usr/bin/env bash

_fd_mixed() {
    local excludes=(
        ".Trash"
        ".zen"
        "GLCache"
        "ferdium/Partitions"
        ".virtualenvs"
        "npm/_cacache"
    )
    local exc_args=()
    for e in "${excludes[@]}"; do
        exc_args+=(-E "$e")
    done

    # path/depth
    local includes=(
        ". 2"
        "$HOME 3"
        "$HOME/Workspace 4"
        "$HOME/Workspace/github.com/ItzTas/facul 2"
    )

    for entry in "${includes[@]}"; do
        local path="${entry% *}"
        local depth="${entry##* }"

        fd -H -d "$depth" -t d "${exc_args[@]}" . "$path"
    done
}

_fd_mixed
