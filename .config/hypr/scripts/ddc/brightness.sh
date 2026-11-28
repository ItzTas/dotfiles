#!/usr/bin/env bash
# Changes the external monitor brightness (DDC/CI VCP 10) by $1, clamped to 0-100.

delta="$1"

current=$(ddcutil getvcp 10 | awk -F'= ' '/current value/ {gsub(/^[ \t]+|[ \t]+$/, "", $2); gsub(/,/, "", $2); print $2}' | awk '{print $1}')
new=$((current + delta))
((new > 100)) && new=100
((new < 0)) && new=0

ddcutil setvcp 10 "$new"
