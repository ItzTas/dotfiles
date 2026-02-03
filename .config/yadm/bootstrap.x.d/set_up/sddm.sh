#!/usr/bin/env bash

BASE="$HOME/.config/sddm"
TARGET="/etc/sddm.conf.d"

_prepare_target() {
    sudo mkdir -p "$TARGET"
    sudo find "$TARGET" -maxdepth 1 -type l -delete
}

_link_configs() {
    for src in "$BASE"/*.conf "$BASE"/*/*.conf; do
        if [[ "$(basename "$src")" == *"##"* ]]; then
            continue
        fi

        [[ -e "$src" ]] || continue

        sudo ln -fs "$src" "$TARGET/$(basename "$src")"
    done
}

_log_summary() {
    echo "✅ Symlinks created from '$BASE' to '$TARGET' (excluding templates)"
}

_prepare_target
_link_configs
_log_summary
