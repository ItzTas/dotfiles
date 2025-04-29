#!/usr/bin/env bash

DUNST_CACHE_DIR="$HOME/.cache/dunst"
DUNST_LOG="$DUNST_CACHE_DIR/notifications.txt"

mkdir -p "$DUNST_CACHE_DIR" 2>/dev/null
touch "$DUNST_LOG"

CACHE_HASH=""
HISTORY_HASH=""

create_cache_loop() {
    local history
    history="$(get_notifications)"
    HISTORY_HASH="$(echo "$history" | md5sum | awk '{print $1}')"

    while sleep 1; do
        local new_history
        new_history="$(get_notifications)"
        local new
        new="$(echo "$new_history" | md5sum | awk '{print $1}')"
        if [[ "$new" != "$HISTORY_HASH" ]]; then
            HISTORY_HASH="$new"
            create_cache
        fi
    done
}

process_notification() {
    echo "processing: $(jq . "$1")"
    local notif="$1"
    local urgency="$2"

    local summary body appname id
    summary=$(echo "$notif" | jq -r '.summary.data')
    body=$(echo "$notif" | jq -r '.body.data' | recode html)
    appname=$(echo "$notif" | jq -r '.appname.data')
    id=$(echo "$notif" | jq -r '.id.data')

    [[ -z "$summary" ]] && summary="Summary unavailable."
    [[ -z "$body" ]] && body="Body unavailable."

    local glyph
    case "$urgency" in
    "LOW") glyph="" ;;
    "NORMAL") glyph="" ;;
    "CRITICAL") glyph="" ;;
    *) glyph="" ;;
    esac

    case "$appname" in
    "spotify") glyph="" ;;
    "mpd") glyph="" ;;
    "picom") glyph="" ;;
    "sxhkd") glyph="" ;;
    "brightness") glyph="" ;;
    "nightmode") glyph="ﯦ" ;;
    "microphone") glyph="" ;;
    "volume") glyph="" ;;
    "screenshot") glyph="" ;;
    "firefox") glyph="" ;;
    esac

    echo "(card :class \"control-center-card control-center-card-$urgency control-center-card-$appname\" :glyph_class \"control-center-$urgency control-center-$appname\" :SL \"$id\" :L \"dunstctl history-rm $id\" :body \"$body\" :summary \"$summary\" :glyph \"$glyph\")" |
        cat - "$DUNST_LOG" |
        sponge "$DUNST_LOG"
}

create_cache() {
    local notifications
    notifications="$(get_notifications)"

    local urgency
    case "$DUNST_URGENCY" in
    "LOW" | "NORMAL" | "CRITICAL") urgency="$DUNST_URGENCY" ;;
    *) urgency="OTHER" ;;
    esac

    echo "$notifications" | jq -c '.[]' | while read -r data_array; do
        echo "$data_array" | jq -c '.[]' | while read -r notif; do
            process_notification "$notif" "$urgency"
        done
    done
}

get_notifications() {
    dunstctl history | jq -c '.data'
}

compile_caches() {
    tr '\n' ' ' <"$DUNST_LOG"
}

make_literal() {
    local caches
    caches="$(compile_caches)"
    local quote
    quote="$("$HOME/.config/eww/Control-Center/scripts/quotes.sh" rand)"
    if [[ -z "$caches" ]]; then
        echo "(box :class \"control-center-empty-box\" :height 590 :orientation \"vertical\" :space-evenly false (image :class \"control-center-empty-banner\" :valign \"end\" :vexpand true :path \"assets/empty-notification.svg\" :image-width 200 :image-height 200) (label :vexpand true :valign \"start\" :wrap true :class \"control-center-empty-label\" :text \"$quote\"))"
    else
        echo "(scroll :height 590 :vscroll true (box :orientation 'vertical' :class 'control-center-scroll-box' :spacing 15 :space-evenly false $caches))"
    fi
}

clear_logs() {
    dunstctl history-clear
    create_cache
}

pop() {
    sed -i '1d' "$DUNST_LOG"
}

drop() {
    sed -i '$d' "$DUNST_LOG"
}

remove_line() {
    dunstctl history-rm "$1"
    : >"$DUNST_LOG"
    cat "$DUNST_LOG"
    create_cache
}

critical_count() {
    local crits
    crits=$(grep -c CRITICAL "$DUNST_LOG")

    local total
    total=$(wc -l <"$DUNST_LOG")

    echo $(((crits * 100) / (total == 0 ? 1 : total)))
}

subscribe() {
    CACHE_HASH="$(md5sum "$DUNST_LOG" | awk '{print $1}')"
    make_literal
    while inotifywait -e modify "$DUNST_LOG" &>/dev/null; do
        local new
        new="$(md5sum "$DUNST_LOG" | awk '{print $1}')"
        if [[ "$CACHE_HASH" != "$new" ]]; then
            CACHE_HASH="$new"
            make_literal
        fi
    done
}

case "$1" in
"pop") pop ;;
"drop") drop ;;
"clear") clear_logs ;;
"subscribe") subscribe ;;
"rm_id") remove_line "$2" ;;
"crits") critical_count ;;
*) create_cache_loop ;;
esac

sed -i '/^$/d' "$DUNST_LOG"
