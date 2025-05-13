#!/bin/bash

TEMP_FILE="/tmp/rofi_opening"

_is_powermenu_open() {
    pgrep -f "rofi.*rofi-pwmenuauto" >/dev/null || pgrep -f "bash $HOME/.config/rofi/powermenu/type-2/powermenu.sh" >/dev/null
}

_is_rofi_in_active_workspace() {
    local id="$1"
    hyprctl clients -j | jq -e ".[] | select(.workspace.id == $id and (.class == \"Rofi\" or .class == \"rofi\"))" >/dev/null
}

_kill_rofi() {
    pkill -f "rofi.*rofi-pwmenuauto"
    pkill -f "bash $HOME/.config/rofi/powermenu/type-2/powermenu.sh"
    rm -f "$TEMP_FILE"
}

_open_rofi() {
    if _is_powermenu_open || [ -f "$TEMP_FILE" ]; then
        return
    fi

    touch "$TEMP_FILE"
    (
        local loops=60
        for ((i = 0; i < loops; i++)); do
            sleep 0.5
            if [ ! -f "$TEMP_FILE" ]; then
                return
            fi
        done

        local path="$HOME/.config/rofi/powermenu/type-2/powermenu.sh"
        local current_id="$1"
        if [[ -x "$path" ]]; then
            hyprctl dispatch exec "[workspace $current_id silent noinitialfocus] $path" &
        else
            echo "Erro: Script do Rofi não encontrado em $path" >&2
        fi
        rm -f "$TEMP_FILE"
    ) &
}

_check_wokspace() {
    rm -f "$TEMP_FILE"

    local workspace_json windows_count current_id

    workspace_json=$(hyprctl activeworkspace -j)
    windows_count=$(echo "$workspace_json" | jq '.windows')
    current_id=$(echo "$workspace_json" | jq '.id')

    if _is_rofi_in_active_workspace "$current_id"; then
        return
    fi
    if ((windows_count > 0)); then
        _on_windows "$windows_count" "$current_id"
        return
    fi
    _open_rofi "$current_id"
}

_on_windows() {
    local windows_count="$1"
    local id="$1"

    if ((windows_count == 1)) && _is_rofi_in_active_workspace "$id"; then
        return
    fi

    _kill_rofi
}

_handle_event() {
    local event="$1"
    case "$event" in
    workspace* | createworkspace*)
        _kill_rofi
        _check_wokspace
        ;;
    openwindow* | closewindow*)
        _check_wokspace
        ;;
    esac
}

_watch() {
    socat - "UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" | while read -r line; do
        _handle_event "$line"
    done
}

_watch
