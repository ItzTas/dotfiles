#!/usr/bin/env bash

_ask_query() {
    local selected="$1"
    local type="$2"
    local query response

    while true; do
        read -r -p "($selected) query: " query

        if [[ "$type" == "language" ]]; then
            query=$(echo "$query" | tr ' ' '+')
            response=$(curl -s -w "%{http_code}" "cht.sh/$selected/$query" -o /tmp/cht_response.txt)
        elif [[ "$type" == "core" ]]; then
            response=$(curl -s -w "%{http_code}" "cht.sh/$selected~$query" -o /tmp/cht_response.txt)
        fi

        if [[ "$response" -ge 200 && "$response" -lt 400 ]]; then
            if [ "$PAGER" != "" ]; then
                cat /tmp/cht_response.txt | "$PAGER"
                break
            fi
            cat /tmp/cht_response.txt | less -R
            break
        fi

        echo "Server error or invalid query, try another."
    done
}

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

    if [[ ${languages_list[*]} =~ $selected ]]; then
        _ask_query "$selected" "language"
    elif [[ ${core_utilts_list[*]} =~ $selected ]]; then
        _ask_query "$selected" "core"
    fi
}

_cht
