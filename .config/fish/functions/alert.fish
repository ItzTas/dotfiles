function alert --description "Notify about the previous command, one status per pipeline stage"
    set -l stages $pipestatus

    argparse -X 0 h/help -- $argv
    or return 1

    if set -q _flag_help
        printf '%s\n' "Usage: <command>; "(status current-function) \
            "  sends a notification with the previous command and one exit status per pipeline stage"
        return 0
    end

    if not command -q notify-send
        echo "notify-send is not installed" >&2
        return 1
    end

    set -l failed
    for i in (seq (count $stages))
        test $stages[$i] -eq 0; and continue
        set -a failed "$i:$stages[$i]"
    end

    set -l icon terminal
    set -l urgency low

    if test (count $failed) -gt 0
        set icon error
        set urgency normal
    end

    set -l last_command (history --max 1 | string replace -r '[;&|]\s*alert$' '' | string trim | string collect)
    set -l title (string shorten -m 72 -- "$last_command")
    set -l body "exit "(string join ' | ' -- $stages)

    test (count $failed) -gt 0; and set body "failed stage "(string join ', ' -- $failed)

    notify-send --urgency=$urgency -i "$icon" "$title" "$body"
end
