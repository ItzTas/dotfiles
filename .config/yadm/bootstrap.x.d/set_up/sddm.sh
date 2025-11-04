#!/bin/env bash

BASE="$HOME/.config/sddm"
TARGET="/etc/sddm.conf.d"

declare -A HOST_MAP=(
    ["talinux-desktop"]="desktop"
    ["talinux-notebook"]="notebook"
)

declare -A USER_MAP=(
)

_detect_mode() {
    local arg_mode="$1" hostname username mode=""
    hostname=$(hostname)
    username=$(whoami)

    if [[ -n "$arg_mode" ]]; then
        echo "$arg_mode"
        return
    fi

    if [[ -n "${HOST_MAP[$hostname]}" ]]; then
        mode="${HOST_MAP[$hostname]}"
    elif [[ -n "${USER_MAP[$username]}" ]]; then
        mode="${USER_MAP[$username]}"
    fi

    if [[ -z "$mode" ]]; then
        if ls /sys/class/power_supply/BAT* >/dev/null 2>&1; then
            mode="notebook"
        else
            mode="desktop"
        fi
    fi

    echo "$mode"
}

_prepare_target() {
    sudo mkdir -p "$TARGET"
    sudo find "$TARGET" -type l -delete
}

_link_configs() {
    local mode="$1"
    for src in "$BASE/general/"*.conf; do
        local name
        name=$(basename "$src")
        sudo ln -fs "$src" "$TARGET/$name"
    done
    if [[ -d "$BASE/$mode" ]]; then
        for src in "$BASE/$mode/"*.conf; do
            local name
            name=$(basename "$src")
            sudo ln -fs "$src" "$TARGET/$name"
        done
    fi
}

_log_summary() {
    local mode="$1" hostname username
    hostname=$(hostname)
    username=$(whoami)
    echo "✅ Mode: $mode | Hostname: $hostname | User: $username"
}

_main() {
    local mode
    mode=$(_detect_mode "$1")
    _prepare_target
    _link_configs "$mode"
    _log_summary "$mode"
}

_main "$@"
