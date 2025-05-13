#!/bin/bash

LEFTBAR_CONFIG_DIR="$HOME/.config/eww/leftbar"

eww --config "$LEFTBAR_CONFIG_DIR" daemon

_is_left_bar_open() {
    eww --config "$LEFTBAR_CONFIG_DIR" active-windows | grep -q "."
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
    _kill_left_bar
}

_kill_left_bar() {
    if ! _is_left_bar_open; then
        return
    fi

    eww --config "$LEFTBAR_CONFIG_DIR" close-all
}

_open_left_bar() {
    if _is_left_bar_open; then
        return
    fi

    # shellcheck disable=SC2046
    eww --config "$LEFTBAR_CONFIG_DIR" open-many $(eww --config "$LEFTBAR_CONFIG_DIR" list-windows | tr '\n' ' ')
}

_on_no_windows() {
    _open_left_bar
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
