#!/bin/bash

windows_count=""
workspace_id=""
current_id=""

_watch() {
    while true; do
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
            _kill_rofi
            current_id="$workspace_id"
            continue
        fi
        _check_to_open "$windows_count"
        sleep 0.2
    done
}

_has_workspace_changed() {
    if [[ "$workspace_id" != "$current_id" ]]; then
        return 0
    fi
    return 1
}

_check_to_open() {
    local windows_count="$1"
    if ((windows_count != 0)) && ! _is_rofi_in_active_workspace "$current_id"; then
        _kill_rofi
        return
    fi
    sleep 1.5
    if _has_workspace_changed; then
        return
    fi
    sleep 0.5
    _open_rofi
    return
}

_is_rofi_in_active_workspace() {
    local id
    id="$1"
    hyprctl clients -j | jq -e ".[] | select(.workspace.id == $id and (.class == \"Rofi\" or .class == \"rofi\"))" >/dev/null
}

_kill_rofi() {
    if pgrep -x rofi >/dev/null; then
        killall rofi 2>/dev/null
    fi
}

_open_rofi() {
    if ! pgrep -x rofi >/dev/null; then
        local path="$HOME/.config/rofi/powermenu/type-2/powermenu.sh"
        if [[ -x "$path" ]]; then
            hyprctl dispatch exec [workspace "$current_id" silent] "$path" &
        else
            echo "Error: Rofi script not found at $path" >&2
        fi
    fi
}

_watch
