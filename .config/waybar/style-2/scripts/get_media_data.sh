_get_tooltip() {
    local title
    title=$(playerctl metadata title 2>/dev/null)
    local artist
    artist=$(playerctl metadata artist 2>/dev/null)

    if [ "$title" == "" ]; then
        echo ""
        return
    fi

    local tooltip=""
    if [ "$artist" != "" ]; then
        tooltip="$title - $artist"
    else
        tooltip="$title"
    fi

    echo "$tooltip"
}

_get_text() {
    local option="$1"

    local text=""
    if [ "$option" == "next" ]; then
        text=""
    elif [ "$option" == "prev" ]; then
        text=""
    fi

    echo "$text"
}

_get_media() {
    local tooltip
    tooltip="$(_get_tooltip)"

    local text
    text="$(_get_text "$1")"

    local class
    class='["media"]'

    jq -c -n \
        --arg tooltip "$tooltip" \
        --arg text "$text" \
        --arg class "$class" \
        --arg percentage 0 \
        '{tooltip: $tooltip, text: $text, class: $class, percentage: $percentage}'
}

_get_media "$@"
