#!/usr/bin/env bash

_cht() {
    local languages_list=(
        "golang"
        "lua"
        "cpp"
        "c"
        "typescript"
        "nodejs"
    )
    local core_utilts_list=(
        "xargs"
        "find"
        "mv"
        "sed"
        "awk"
        "jq"
    )

    local options
    options="$(printf "%s\n" "${languages_list[@]}" "${core_utilts_list[@]}")"

    local selected
    selected=$(
        echo "$options" |
            fzf \
                --preview "bash $HOME/.config/tmux/scripts/fzf_preview/cht.sh {}" \
                --bind 'ctrl-y:accept' \
                --ansi
    )

    if [ "$selected" = "" ]; then
        return
    fi
}

_cht
