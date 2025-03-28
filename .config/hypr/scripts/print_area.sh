print_selected_area() {
    local filename
    local path
    local fullpath

    filename="screenshot_$(date '+%Y-%m-%d_%H-%M-%S-%3N').png"
    path="$(xdg-user-dir PICTURES)/screenshots"
    fullpath="$path/$filename"

    mkdir -p "$path"

    grim -g "$(slurp)" "$fullpath"

    local ACTION
    ACTION=$(dunstify -I "$fullpath" --action="default,open" "Screenshot saved" "Image saved in $fullpath")

    case "$ACTION" in
    "default") imv "$fullpath" ;;
    esac
}

print_selected_area
