#!/usr/bin/env bash
wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | awk '{print int($2*100)}'
