#!/usr/bin/env bash

_set_up() {
    sudo snapper -c root set-config \
        TIMELINE_LIMIT_HOURLY="4" \
        TIMELINE_LIMIT_DAILY="7" \
        TIMELINE_LIMIT_WEEKLY="4" \
        TIMELINE_LIMIT_MONTHLY="3" \
        TIMELINE_LIMIT_YEARLY="0" \
        TIMELINE_LIMIT_QUARTERLY="0" \
        NUMBER_LIMIT="3" \
        NUMBER_LIMIT_IMPORTANT="2"

    sudo snapper -c home set-config \
        TIMELINE_LIMIT_HOURLY="2" \
        TIMELINE_LIMIT_DAILY="2" \
        TIMELINE_LIMIT_WEEKLY="0" \
        TIMELINE_LIMIT_MONTHLY="0" \
        TIMELINE_LIMIT_YEARLY="0" \
        TIMELINE_LIMIT_QUARTERLY="0" \
        NUMBER_LIMIT="2" \
        NUMBER_LIMIT_IMPORTANT="1"

}

if command -v snapper &>/dev/null; then
    _set_up
fi
