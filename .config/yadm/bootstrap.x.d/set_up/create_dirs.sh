#!/bin/env bash

_create() {
    local workspace_dir
    workspace_dir="$HOME/workspace/github.com/ItzTas"
    mkdir -p "$workspace_dir"
    mkdir -p "$HOME/Docs"
    mkdir -p "$HOME/Downloads"
    mkdir -p "$HOME/Videos"
    mkdir -p "$HOME/Pictures"
    mkdir -p "$HOME/Desktop"
}

_create
