#!/bin/bash

CONTROL_CENTER_CONFIG_DIR="$HOME/.config/eww/Control-Center"

eww --config "$CONTROL_CENTER_CONFIG_DIR" daemon

_is_control_center_open() {
    eww --config "$CONTROL_CENTER_CONFIG_DIR" active-windows | grep -q "control-center"
}

_is_rofi_in_active_workspace() {
    local id="$1"
    hyprctl clients -j | jq -e ".[] | select(.workspace.id == $id and (.class == \"Rofi\" or .class == \"rofi\"))" >/dev/null
}

_check_workspace() {
    local id="$1"
    local windows_count="$2"
    if ((windows_count == 0)); then
        _on_no_windows
        return
    fi
    if ((windows_count == 1)) && _is_rofi_in_active_workspace "$id"; then
        _on_no_windows
        return
    fi
    _on_windows
}

_on_windows() {
    _kill_window
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

_open_control_center() {
    if _is_control_center_open; then
        return
    fi
    eww --config "$CONTROL_CENTER_CONFIG_DIR" open control-center
}

_on_no_windows() {
    _open_control_center
}

_handle_event() {
    local event="$1"

    case "$event" in
    openwindow* | closewindow* | workspace* | createworkspace*)
        local workspace_json
        workspace_json=$(hyprctl activeworkspace -j)

        local windows_count current_id
        windows_count=$(echo "$workspace_json" | jq '.windows')
        current_id=$(echo "$workspace_json" | jq '.id')

        _check_workspace "$current_id" "$windows_count"
        ;;
    esac
}

_watch() {
    socat - "UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" | while read -r line; do
        _handle_event "$line"
    done
}

_watch
