#!/bin/bash

DIR=~/Videos/.recordings
mkdir -p "$DIR"

FILENAME="$DIR/recording_$(date '+%Y-%m-%d_%H-%M-%S').mp4"
BASENAME=$(basename "$FILENAME")

notify-send -i "audio-input-microphone" "Gravação Iniciada" "Gravando para $FILENAME"

wf-recorder -f "$FILENAME"

THUMBNAIL="$DIR/thumbnail_$(date '+%Y-%m-%d_%H-%M-%S').png"
ffmpeg -y -i "$FILENAME" -vframes 1 "$THUMBNAIL"

notify-send -i "$THUMBNAIL" "Gravação Terminada" "A gravação foi salva como $BASENAME"

rm "$THUMBNAIL"
