#!/bin/env bash

MONITOR="DP-2"

_is_hdr_activated() {
    local hyprmonitor_file="$1"
    mode=$(awk 'NR==1 { print $2 }' "$hyprmonitor_file")
    [[ "$mode" == "1" ]]
}

_toggle() {
    local hyprmonitor_file="$HOME/.config/hypr/config/hyprmonitor.conf"

    local no_hdr_text
    no_hdr_text=$(
        cat <<EOF
# 0
monitor = $MONITOR, preferred, auto, 1, cm, auto, vrr, 1
EOF
    )

    local hdr_text
    hdr_text=$(
        cat <<EOF
# 1
monitor = $MONITOR, preferred, auto, 1, bitdepth, 10, cm, hdr, vrr, 1, sdrbrightness, 1.17, sdrsaturation, 1.45
EOF
    )

    if _is_hdr_activated "$hyprmonitor_file"; then
        echo "🔄 HDR is active – disabling..."
        printf "%s\n" "$no_hdr_text" >"$hyprmonitor_file"
    else
        echo "🔄 HDR is inactive – enabling..."
        printf "%s\n" "$hdr_text" >"$hyprmonitor_file"
    fi
    hyprctl reload
}

_toggle
