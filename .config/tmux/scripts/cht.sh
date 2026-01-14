#!/usr/bin/env bash

CACHE_DIR="/tmp/cht_response_cache"
mkdir -p "$CACHE_DIR"

_get_from_cache() {
    local cache_name
    cache_name=$(_get_cache_path "$1" "$2")
    if [[ -f "$cache_name" ]]; then
        cat "$cache_name"
        return 0
    else
        return 1
    fi
}

_get_cache_path() {
    local topic="$1"
    topic=$(echo "$topic" | tr '/' '_')

    local query="$2"
    query=$(echo "$query" | tr '/' '_')
    echo "$CACHE_DIR/$topic%$query"
}

_save_to_cache() {
    local cache_name
    cache_name=$(_get_cache_path "$1" "$2")
    echo "$3" >"$cache_name"
}

_get_request() {
    local topic="$1"
    local query="$2"
    local type="$3"
    local url response response_body response_code

    if [[ "$type" == "language" ]]; then
        query=$(echo "$query" | tr ' ' '+')
        url="cht.sh/$topic/$query"
    elif [[ "$type" == "core" ]]; then
        url="cht.sh/$topic~$query"
    fi

    response=$(curl -s -w "\n%{http_code}" "$url")
    response_code=$(echo "$response" | tail -n1)
    response_body=$(echo "$response" | head -n -1)

    if _is_not_found "$response_body"; then
        response_code=404
    fi

    if ((response_code >= 200 && response_code < 400)); then
        _save_to_cache "$topic" "$query" "$response_body"
    fi

    echo -e "$response_codeµµµ$response_body"
}

_is_not_found() {
    local response="$1"
    if echo "$response" | head -n5 | grep -q "404 NOT FOUND"; then
        return 0
    else
        return 1
    fi
}

_ask_query() {
    local topic="$1"
    local type="$2"

    while true; do
        local query response response_code response_body cache_content
        read -r -p "($topic) query: " query
        [[ -z "$query" ]] && continue

        if cache_content=$(_get_from_cache "$topic" "$query"); then
            response_code=200
            response_body="$cache_content"
        else
            response=$(_get_request "$topic" "$query" "$type")
            response_code="${response%%µµµ*}"
            response_body="${response#*µµµ}"
        fi

        if ((response_code >= 200 && response_code < 400)); then
            if [ "$PAGER" != "" ]; then
                echo "$response_body" | "$PAGER"
            else
                echo "$response_body" | less -R
            fi
            break
        fi

        echo "Response code: $response_code"
        echo "Server error or invalid query: $query, try again"
    done
}

_cht() {
    local languages_list=(
        "golang"
        "python"
        "lua"
        "cpp"
        "c"
        "typescript"
        "nodejs"
        "css"
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
