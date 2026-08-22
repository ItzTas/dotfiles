function __last_command
    set -q history[1]; or return
    echo -- $history[1]
end
