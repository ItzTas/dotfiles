#!/bin/bash

t() {
    local current_brightness
    current_brightness=$(ddcutil getvcp 10 | awk -F'= ' '/current value/ {gsub(/^[ \t]+|[ \t]+$/, "", $2); gsub(/,/, "", $2); print $2}' | awk '{print $1}')

    increase=true

    local new_brightness
    if [ "$increase" = true ]; then
        new_brightness=$((current_brightness + 10))
    else
        new_brightness=$((current_brightness - 10))
    fi

    if [ $new_brightness -gt 100 ]; then
        new_brightness=100
    elif [ $new_brightness -lt 0 ]; then
        new_brightness=0
    fi

    ddcutil setvcp 10 "$new_brightness"
}

t
