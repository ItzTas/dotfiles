#!/usr/bin/env bash

LOG="/tmp/swaync_debug.log"

if [ ! -f "$LOG" ]; then
    touch "$LOG"
fi

{
    echo "---- $(date) ----"
    echo "APP=$SWAYNC_APP_NAME"
    echo "DESKTOP=$SWAYNC_DESKTOP_ENTRY"
    echo "SUMMARY=$SWAYNC_SUMMARY"
    echo "BODY=$SWAYNC_BODY"
    echo "CATEGORY=$SWAYNC_CATEGORY"
    echo "URGENCY=$SWAYNC_URGENCY"
    echo "ID=$SWAYNC_ID"
    echo ""
} >>"$LOG"
