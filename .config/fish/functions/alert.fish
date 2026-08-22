function alert
    set -l last_status $status

    if not command -q notify-send
        echo "notify-send is not installed" >&2
        return 1
    end

    set -l icon error
    test $last_status -eq 0; and set icon terminal

    set -l last_command (history --max 1 | string replace -r '[;&|]\s*alert$' '')

    notify-send --urgency=low -i "$icon" "$last_command"
end
