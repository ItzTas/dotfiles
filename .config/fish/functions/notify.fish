function notify --description "Run a command in the background and notify when the job exits"
    argparse --stop-nonopt w/wait -- $argv
    or return

    if not command -q notify-send
        echo "notify-send is not installed" >&2
        return 1
    end

    if test (count $argv) -eq 0
        echo "usage: notify [-w|--wait] COMMAND [ARG...]" >&2
        return 2
    end

    set -l label (string shorten -m 72 -- (string join ' ' -- $argv))
    set -l started (date +%s)

    if test (count $argv) -eq 1; and string match -qr '[|&;<>()`]|\$' -- $argv[1]
        eval "$argv[1] &"
    else
        $argv &
    end

    set -l pid $last_pid

    set -ga __notify_pids $pid
    set -ga __notify_codes 0
    set -ga __notify_labels $label
    set -ga __notify_starts $started

    function __notify_proc_$pid --on-process-exit $pid --inherit-variable pid
        set -l i (contains -i -- $pid $__notify_pids)
        or return
        set -g __notify_codes[$i] $argv[3]
    end

    function __notify_job_$pid --on-job-exit $pid --inherit-variable pid
        set -l i (contains -i -- $pid $__notify_pids)
        or return

        __notify_send $__notify_codes[$i] $__notify_starts[$i] $__notify_labels[$i]

        set -e __notify_pids[$i]
        set -e __notify_codes[$i]
        set -e __notify_labels[$i]
        set -e __notify_starts[$i]

        functions --erase __notify_proc_$pid __notify_job_$pid
    end

    set -q _flag_wait; and wait $pid
end

function __notify_send
    set -l code $argv[1]
    set -l started $argv[2]
    set -l label (string join ' ' -- $argv[3..])

    set -l elapsed (math (date +%s) - $started)
    set -l pretty "$elapsed"s

    if test $elapsed -ge 60
        set pretty (math --scale=0 $elapsed / 60)"m "(math $elapsed % 60)"s"
    end

    set -l icon terminal
    set -l urgency low
    set -l body "done in $pretty"

    if test $code -ne 0
        set icon error
        set urgency normal
        set body "exit $code after $pretty"
    end

    notify-send --urgency=$urgency -i "$icon" "$label" "$body"
end
