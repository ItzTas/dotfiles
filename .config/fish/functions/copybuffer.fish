function copybuffer
    if command -q wl-copy
        commandline | wl-copy
    else
        echo "wl-copy not found. Please make sure you have it installed"
    end
    commandline -f repaint
end
