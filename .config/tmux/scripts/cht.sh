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

    local options=("${languages_list[@]}" "${core_utilts_list[@]}")
    local selected
    selected=$(printf "%s\n" "${options[@]}" | fzf)
}

_cht
