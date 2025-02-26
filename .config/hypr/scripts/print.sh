print_img() {
    local filename
    filename="screenshot_$(date '+%Y-%m-%d_%H-%M-%S-%3N').png"
    local path
    path="$(xdg-user-dir PICTURES)/screenshots"
    local fullpath="$path/$filename"

    mkdir -p "$path"

    grim "$fullpath"

    local ACTION
    ACTION=$(dunstify -i "$fullpath" --action="default,swappy" "Screenshot saved" "Image saved in $fullpath")

    case "$ACTION" in
    "default") swappy -f "$fullpath" ;;
    esac
}

print_img
