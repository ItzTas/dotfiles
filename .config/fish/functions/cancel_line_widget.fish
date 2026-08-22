function cancel_line_widget
    # an empty buffer expands to two elements under `string collect --allow-empty`,
    # and a quoted list joins with a space, so the emptiness test below would never
    # be false; plain `string collect` keeps it a single empty string
    set -l buffer (commandline --current-buffer | string collect)

    if test -n "$buffer"
        # something to cancel: oh-my-posh handles it, transient prompt included
        if functions -q _omp_ctrl_c_key_handler
            _omp_ctrl_c_key_handler
            return
        end

        commandline -f cancel-commandline
        commandline -f repaint
        return
    end

    # nothing to cancel, and `cancel-commandline` draws no new prompt in fish 4;
    # executing the empty buffer is what opens a fresh line, same as enter does
    if functions -q _omp_enter_key_handler
        _omp_enter_key_handler
        return
    end

    commandline -f execute
end
