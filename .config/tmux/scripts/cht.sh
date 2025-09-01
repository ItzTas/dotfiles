#!/usr/bin/env bash

_ask_query() {
    local selected="$1"
    local type="$2"

    while true; do
        local query response_body response_code
        read -r -p "($selected) query: " query

        if [[ "$type" == "language" ]]; then
            query=$(echo "$query" | tr ' ' '+')
            response_body=$(curl -s "curl" -w "%{http_code}" "cht.sh/$selected/$query")
        elif [[ "$type" == "core" ]]; then
            response_body=$(curl -s "curl" -w "%{http_code}" "cht.sh/$selected~$query")
        fi

        response_code="${response_body: -3}"
        response_body="${response_body::-3}"

        if [[ "$response_code" -ge 200 && "$response_code" -lt 400 ]]; then
            if [ "$PAGER" != "" ]; then
                echo "$response_body" | "$PAGER"
                break
            fi
            echo "$response_body" | less -R
            break
        fi

        echo "Reponse code: $response_code"
        echo "Server error or invalid query: $query, try again"
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
