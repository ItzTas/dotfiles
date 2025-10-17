#!/bin/env bash

_set_up() {
    local workspace_dir
    workspace_dir="$HOME/Workspace/github.com/ItzTas"
    mkdir -p "$workspace_dir"
    mkdir -p "$HOME/Docs"
    mkdir -p "$HOME/Downloads"
    mkdir -p "$HOME/Videos"
    mkdir -p "$HOME/Pictures"
    mkdir -p "$HOME/Musics"
    mkdir -p "$HOME/Desktop"
}

_set_up
