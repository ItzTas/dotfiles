#!/bin/bash

if pgrep wf-recorder; then
    killall wf-recorder
    exit 0
fi

DIR=~/Videos/.recordings
mkdir -p "$DIR"

FILENAME="$DIR/recording_$(date '+%Y-%m-%d_%H-%M-%S').mp4"
BASENAME=$(basename "$FILENAME")

notify-send -a "sys_recording" "Recording Started" "Recording to $FILENAME" || exit 1

if ! wf-recorder -f "$FILENAME"; then
    dunstify "Error" "Failed to start recording"
    exit 1
fi

TMPDIR=$(mktemp -d)
THUMBNAIL="$TMPDIR/thumbnail.png"
rm -f "$THUMBNAIL"
if ! ffmpeg -y -i "$FILENAME" -vframes 1 "$THUMBNAIL"; then
    dunstify "Error" "Failed to generate thumbnail"
    rm -rf "$TMPDIR"
    exit 1
fi

ACTION=$(dunstify -a "sys_recording" -i "$THUMBNAIL" --action="default,open" "Recording Finished" "The recording has been saved as $BASENAME")

rm -rf "$TMPDIR"

case "$ACTION" in
"default")
    nemo "$FILENAME" &
    ;;
esac
