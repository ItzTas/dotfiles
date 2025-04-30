#!/usr/bin/env bash

DUNST_CACHE_DIR="$HOME/.cache/dunst"
DUNST_LOG="$DUNST_CACHE_DIR/notifications.txt"
LOCKFILE="/tmp/dunst_lockfile.lock"

mkdir -p "$DUNST_CACHE_DIR" 2>/dev/null
touch "$DUNST_LOG"

LOG_FILE="$HOME/.cache/eww/control-center.log"
HISTORY_HASH=""

echo_to_log() {
    echo "$@" >"$LOG_FILE"
}

with_lock() {
    exec 200>"$LOCKFILE"
    flock 200
    "$@"
    flock -u 200
}

create_cache_lock() {
    with_lock create_cache
}

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
            create_cache_lock
        fi
    done
}

trim() {
    local trimmed_string
    trimmed_string=${trimmed_string##*( )}
    trimmed_string=${trimmed_string%%*( )}
    print "$trimmed_string"
}

process_notification() {
    local notif="$1"

    local summary body appname id urgency
    summary=$(echo "$notif" | jq -r '.summary.data')
    body=$(echo "$notif" | jq -r '.body.data' | recode html)
    appname=$(echo "$notif" | jq -r '.appname.data')
    id=$(echo "$notif" | jq -r '.id.data')
    urgency=$(echo "$notif" | jq -r '.urgency.data')

    summary="$(trim summary)"
    body="$(trim body)"

    if [[ -z "$summary" ]] && [[ -z "$body" ]]; then
        return
    fi

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

    echo "(card :class \"control-center-card control-center-card-$urgency control-center-card-$appname\" :glyph_class \"control-center-$urgency control-center-$appname\" :SL \"$id\" :L \"dunstctl history-pop $id\" :body \"$body\" :summary \"$summary\" :glyph \"$glyph\")"
}

create_cache() {
    local notifications output=""
    notifications="$(get_notifications)"

    while read -r data_array; do
        while read -r notif; do
            output+=$(process_notification "$notif" "$urgency")
            output+=$'\n'
        done <<<"$(echo "$data_array" | jq -c '.[]')"
    done <<<"$(echo "$notifications" | jq -c '.[]')"

    echo "$output" >"$DUNST_LOG"
}

get_notifications() {
    dunstctl history | jq -c '.data'
}

compile_caches() {
    tr '\n' ' ' <"$DUNST_LOG"
}

remove_empty_lines() {
    local content="$1"
    while IFS= read -r line; do
        [[ -n "$line" ]] && printf '%s\n' "$line"
    done <<<"$content"
}

make_literal() {
    local caches
    # caches="$(compile_caches)"
    local quote
    quote="$("$HOME/.config/eww/Control-Center/scripts/quotes.sh" rand)"
    local trimmed_string
    trimmed_string="$(remove_empty_lines caches)"
    trimmed_string=${trimmed_string##*( )}
    trimmed_string=${trimmed_string%%*( )}

    # if [[ -z "$caches" ]] || [[ -z "$trimmed_string" ]]; then
    # else
    #     echo_to_log "$trimmed_string"
    #     echo "(scroll :height 590 :vscroll true (box :orientation 'vertical' :class 'control-center-scroll-box' :spacing 15 :space-evenly false $caches))"
    # fi
    echo "(box :class \"control-center-empty-box\" :height 590 :orientation \"vertical\" :space-evenly false (image :class \"control-center-empty-banner\" :valign \"end\" :vexpand true :path \"assets/empty-notification.svg\" :image-width 200 :image-height 200) (label :vexpand true :valign \"start\" :wrap true :class \"control-center-empty-label\" :text \"$quote\"))"
}

clear_logs() {
    dunstctl history-clear
    : >"$DUNST_LOG"
}

pop() {
    sed -i '$d' "$DUNST_LOG"
}

drop() {
    sed -i '$d' "$DUNST_LOG"
}

remove_line() {
    dunstctl history-rm "$1"
    sed -i "/:SL \"$1\" /d" "$DUNST_LOG"
}

critical_count() {
    local crits
    crits=$(grep -c CRITICAL "$DUNST_LOG")

    local total
    total=$(wc -l <"$DUNST_LOG")

    echo $(((crits * 100) / (total == 0 ? 1 : total)))
}

subscribe() {
    make_literal
    while inotifywait -e modify "$DUNST_LOG" &>/dev/null; do
        make_literal
    done
}

case "$1" in
"pop") pop ;;
"drop") drop ;;
"clear") clear_logs ;;
"subscribe") subscribe ;;
"rm_id")
    with_lock remove_line "$2"
    ;;
"crits") critical_count ;;
*) create_cache_loop ;;
esac

sed -i '/^$/d' "$DUNST_LOG"
