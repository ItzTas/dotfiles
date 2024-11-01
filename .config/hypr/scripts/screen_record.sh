DIR=~/Videos/.recordings
mkdir -p "$DIR"

FILENAME="$DIR/recording_$(date '+%Y-%m-%d_%H-%M-%S').mp4"
BASENAME=$(basename "$FILENAME")

ACTION=$(dunstify "Gravação Iniciada" "Gravando para $FILENAME")

wf-recorder -f "$FILENAME"

THUMBNAIL="$DIR/thumbnail_$(date '+%Y-%m-%d_%H-%M-%S').png"
ffmpeg -y -i "$FILENAME" -vframes 1 "$THUMBNAIL"

ACTION=$(dunstify -i "$THUMBNAIL" --action="default,VLC" "Gravação Terminada" "A gravação foi salva como $BASENAME")

rm "$THUMBNAIL"

case "$ACTION" in
"default")
    dunstify "Abrindo $BASENAME com vlc"
    vlc "$FILENAME" &
    ;;
esac
