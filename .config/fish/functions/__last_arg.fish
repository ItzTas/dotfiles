function __last_arg
    set -q history[1]; or return
    set -l tokens (string split -- ' ' $history[1])
    set -q tokens[1]; or return
    echo -- $tokens[-1]
end
