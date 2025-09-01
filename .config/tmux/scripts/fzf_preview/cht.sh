#!/usr/bin/env bash

_preview() {
    local topic="$1"
    local response
    response=$(curl -s "cht.sh/$topic")

    local first_line
    first_line=$(echo "$response" | head -n1 | xargs)
    if [[ "$first_line" == "Unknown topic." ]]; then
        echo ""
        return
    fi
    echo "$response"
}

_preview "$@"
