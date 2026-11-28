#!/usr/bin/env bash

step="$1"

if ((step < 0)); then
	wpctl set-volume @DEFAULT_AUDIO_SINK@ "${step#-}%-"
	exit 0
fi
wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ "${step}%+"
