#!/bin/bash

rofi_pid=""

_watch() {
    local current_id=""

    while true; do
        local workspace_info
        workspace_info=$(hyprctl activeworkspace 2>/dev/null)

        if [[ -z "$workspace_info" ]]; then
            continue
        fi

        local workspace_json
        workspace_json="$(hyprctl activeworkspace -j)"

        local windows_count
        windows_count=$(echo "$workspace_json" | jq '.windows')

        local workspace_id
        workspace_id=$(echo "$workspace_json" | jq '.id')

        if [[ "$workspace_id" != "$current_id" ]]; then
            _kill_rofi
            current_id="$workspace_id"
            continue
        fi
        _check_to_open "$windows_count" "$current_id"

        sleep 0.2
    done
}

_check_to_open() {
    local windows_count="$1"
    local id="$2"
    if ((windows_count == 0)); then
        _open_rofi
        return
    fi
    if ! _is_rofi_in_active_workspace "$id"; then
        _kill_rofi
    fi
}

_is_rofi_in_active_workspace() {
    local id
    id="$1"
    hyprctl clients -j | jq -e ".[] | select(.workspace.id == $id and (.class == \"Rofi\" or .class == \"rofi\"))" >/dev/null
}

_kill_rofi() {
    if [[ -n "$rofi_pid" ]] && kill -0 "$rofi_pid" 2>/dev/null; then
        kill "$rofi_pid"
        rofi_pid=""
    fi
    if pgrep -x rofi >/dev/null; then
        killall rofi 2>/dev/null
    fi
}

_open_rofi() {
    if ! pgrep -x rofi >/dev/null; then
        local path="$HOME/.config/rofi/powermenu/type-2/powermenu.sh"
        if [[ -x "$path" ]]; then
            "$path" &
            rofi_pid=$!
        else
            echo "Error: Rofi script not found at $path" >&2
        fi
    fi
}

_watch
