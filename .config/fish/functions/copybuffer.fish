function copybuffer
    if not command -q wl-copy
        echo "wl-copy is not installed" >&2
        commandline -f repaint
        return 1
    end

    commandline | wl-copy
    commandline -f repaint
end
