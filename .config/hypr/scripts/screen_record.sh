#!/bin/bash

DIR=~/Videos/.recordings
mkdir -p "$DIR"

FILENAME="$DIR/recording_$(date '+%Y-%m-%d_%H-%M-%S').mp4"
BASENAME=$(basename "$FILENAME")

dunstify "Recording Started" "Recording to $FILENAME" || exit 1

if ! wf-recorder -f "$FILENAME"; then
    dunstify "Error" "Failed to start recording" && exit 1
fi

THUMBNAIL="$DIR/thumbnail_$(date '+%Y-%m-%d_%H-%M-%S').png"
if ! ffmpeg -y -i "$FILENAME" -vframes 1 "$THUMBNAIL"; then
    dunstify "Error" "Failed to generate thumbnail" && rm "$FILENAME" && exit 1
fi

ACTION=$(dunstify -i "$THUMBNAIL" --action="default,VLC" "Recording Finished" "The recording has been saved as $BASENAME")

rm "$THUMBNAIL"

case "$ACTION" in
"default")
    dunstify "Opening $BASENAME"
    vlc "$FILENAME" &
    ;;
esac
