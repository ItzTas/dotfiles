#!/usr/bin/env bash

CACHE_DIR="/tmp/cht_cache"
mkdir -p "$CACHE_DIR"

get_from_cache() {
    local topic="$1"
    local cache_file
    cache_file="$CACHE_DIR/$(echo "$topic" | tr '/' '_')"

    if [[ -f "$cache_file" ]]; then
        cat "$cache_file"
        return 0
    else
        return 1
    fi
}

save_to_cache() {
    local topic="$1"
    local content="$2"
    local cache_file
    cache_file="$CACHE_DIR/$(echo "$topic" | tr '/' '_')"
    echo "$content" >"$cache_file"
}

_preview() {
    local topic="$1"
    local response

    if ! response=$(get_from_cache "$topic"); then
        response=$(curl -s "cht.sh/$topic")
        save_to_cache "$topic" "$response"
    fi

    local first_line
    first_line=$(echo "$response" | head -n1 | xargs)
    if [[ "$first_line" == "Unknown topic." ]]; then
        echo ""
        return
    fi

    echo "$response"
}

_preview "$@"
