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

        workspace_id=$(echo "$workspace_json" | jq '.id')

        if _has_workspace_changed; then
            _kill_rofi
            current_id="$workspace_id"
            continue
        fi

        windows_count=$(echo "$workspace_json" | jq '.windows')
        if ((windows_count >= 2)) && _is_rofi_in_active_workspace && _is_powermenu_open; then
            _kill_rofi
        fi
        _check_to_open "$windows_count"
    done
}

_is_rofi_open() {
    if pgrep -x rofi >/dev/null; then
        return 1
    fi
    return 0
}

_has_workspace_changed() {
    if [[ "$workspace_id" != "$current_id" ]]; then
        return 0
    fi
    return 1
}

_check_to_open() {
    local windows_count="$1"
    if ((windows_count != 0)); then
        _on_windows_open "$windows_count"
        return
    fi
    sleep 10
    if _has_workspace_changed; then
        return
    fi
    _open_rofi
    return
}

_on_windows_open() {
    local windows_count="$1"
    if ((windows_count == 1)) && _is_rofi_in_active_workspace && _is_powermenu_open; then
        return
    fi
    if _is_rofi_in_active_workspace && ! _is_powermenu_open; then
        sleep 3
        return
    fi

    _kill_rofi
}

_is_rofi_in_active_workspace() {
    local id
    id="$current_id"
    hyprctl clients -j | jq -e ".[] | select(.workspace.id == $id and (.class == \"Rofi\" or .class == \"rofi\"))" >/dev/null
}

_is_powermenu_open() {
    if pgrep -f "rofi.*rofi-pwmenuauto" >/dev/null; then
        return 1
    else
        return 0
    fi
}

_kill_rofi() {
    if _is_powermenu_open; then
        pkill -f "rofi.*rofi-pwmenuauto"
    fi
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
