#!/bin/bash

sleep 10

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
            _kill_rofi
            continue
        fi
        if pgrep -x rofi >/dev/null; then
            sleep 2
            continue
        fi
        _check_to_open "$windows_count"
    done
}

_has_workspace_changed() {
    if [[ "$workspace_id" != "$current_id" ]]; then
        return 0
    fi
    return 1
}

_check_to_open() {
    sleep 0.2
    local windows_count="$1"
    if ((windows_count != 0)) && ! _is_rofi_in_active_workspace "$current_id"; then
        _kill_rofi
        return
    fi
    sleep 3
    if _has_workspace_changed; then
        return
    fi
    _open_rofi
    return
}

_is_rofi_in_active_workspace() {
    local id
    id="$1"
    hyprctl clients -j | jq -e ".[] | select(.workspace.id == $id and (.class == \"Rofi\" or .class == \"rofi\"))" >/dev/null
}

_kill_rofi() {
    pkill -f "rofi.*rofi-pwmenuauto"
}

_open_rofi() {
    if pgrep -x rofi >/dev/null; then
        return
    fi
    local path="$HOME/.config/rofi/powermenu/type-2/powermenu.sh"
    if [[ -x "$path" ]]; then
        hyprctl dispatch exec [workspace "$current_id" silent] "$path" &
    else
        echo "Error: Rofi script not found at $path" >&2
    fi
}

_watch
