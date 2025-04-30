#!/bin/bash

sleep 2

CONTROL_CENTER_CONFIG_DIR="$HOME/.config/eww/Control-Center"

eww --config "$CONTROL_CENTER_CONFIG_DIR" daemon

windows_count=""
workspace_id=""
current_id=""

_watch() {
    while true; do
        sleep 0.2
        local workspace_info
        workspace_info=$(hyprctl activeworkspace 2>/dev/null)

        if [[ -z "$workspace_info" ]]; then
            continue
        fi

        local workspace_json
        workspace_json="$(hyprctl activeworkspace -j)"

        windows_count=$(echo "$workspace_json" | jq '.windows')

        workspace_id=$(echo "$workspace_json" | jq '.id')

        if _has_workspace_changed; then
            current_id="$workspace_id"
            _kill_window
            continue
        fi
        _check_workspace "$windows_count"
    done
}

_has_workspace_changed() {
    if [[ "$workspace_id" != "$current_id" ]]; then
        return 0
    fi
    return 1
}

_is_control_center_open() {
    eww --config "$CONTROL_CENTER_CONFIG_DIR" active-windows | grep -q "control-center"
}

_check_workspace() {
    local windows_count="$1"
    if ((windows_count == 0)); then
        _on_no_windows
        return
    fi
    if ((windows_count == 1)) && _is_rofi_in_active_workspace; then
        _on_no_windows
        return
    fi
    _on_windows
}

_is_rofi_in_active_workspace() {
    local id
    id="$current_id"
    hyprctl clients -j | jq -e ".[] | select(.workspace.id == $id and (.class == \"Rofi\" or .class == \"rofi\"))" >/dev/null
}

_kill_waybar() {
    if _is_waybar_active; then
        killall waybar
    fi
}

_on_windows() {
    _kill_window
    _open_waybar
}

_kill_window() {
    if _is_control_center_open; then
        eww --config "$CONTROL_CENTER_CONFIG_DIR" close control-center
    fi
}

_is_waybar_active() {
    if pgrep -x "waybar" >/dev/null; then
        return 0
    else
        return 1
    fi
}

_open_waybar() {
    if _is_waybar_active; then
        return
    fi
    waybar >/dev/null 2>&1 &
}

_open_control_center() {
    if _is_control_center_open; then
        return
    fi
    eww --config "$CONTROL_CENTER_CONFIG_DIR" open control-center
}

_on_no_windows() {
    _open_control_center
    _kill_waybar
}

_watch
