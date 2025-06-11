#!/bin/env bash

MONITOR1="DP-2"
HYPRMONITOR_FILE="$HOME/.config/hypr/config/hyprmonitor.conf"

SATURATION_MONITOR1="1.45"
BRIGHTNESS_MONITOR1="1.12"

NO_HDR_TEXT=$(
    cat <<EOF
# 0
monitor = $MONITOR1, preferred, auto, 1, cm, auto, vrr, 1
EOF
)

HDR_TEXT=$(
    cat <<EOF
# 1
monitor = $MONITOR1, preferred, auto, 1, bitdepth, 10, cm, hdr, vrr, 1, sdrbrightness, $BRIGHTNESS_MONITOR1, sdrsaturation, $SATURATION_MONITOR1
EOF
)

_is_hdr_activated() {
    mode=$(awk 'NR==1 { print $2 }' "$HYPRMONITOR_FILE")
    [[ "$mode" == "1" ]]
}

_toggle() {
    if _is_hdr_activated; then
        echo "🔄 HDR is active – disabling..."
        printf "%s\n" "$NO_HDR_TEXT" >"$HYPRMONITOR_FILE"
    else
        echo "🔄 HDR is inactive – enabling..."
        printf "%s\n" "$HDR_TEXT" >"$HYPRMONITOR_FILE"
    fi
    hyprctl reload
}

_toggle
