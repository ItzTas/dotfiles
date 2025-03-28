print_window() {
    local filename
    local path
    local fullpath
    local ACTION

    filename="screenshot_$(date '+%Y-%m-%d_%H-%M-%S-%3N').png"
    path="$(xdg-user-dir PICTURES)/screenshots"
    fullpath="$path/$filename"

    mkdir -p "$path"

    hyprshot -m window -s -o "$path" -f "$filename"

    ACTION=$(dunstify -I "$fullpath" --action="default,open" "Screenshot saved" "Image saved in $fullpath")

    case "$ACTION" in
    "default") imv "$fullpath" ;;
    esac
}

print_window
