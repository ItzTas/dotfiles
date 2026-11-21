#!/usr/bin/env bash

_set_up() {
    if ! command -v cargo-sweep &>/dev/null; then
        echo "cargo-sweep not installed, skipping its timer" >&2
        return
    fi
    systemctl --user daemon-reload
    systemctl --user enable --now cargo-sweep.timer
}

_set_up
