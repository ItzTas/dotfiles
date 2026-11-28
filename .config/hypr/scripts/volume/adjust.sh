#!/usr/bin/env bash
# Changes the default sink volume by $1 percent (e.g. 5 or -5), capped at 100%.

step="$1"

if ((step < 0)); then
	wpctl set-volume @DEFAULT_AUDIO_SINK@ "${step#-}%-"
	exit 0
fi
wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ "${step}%+"
