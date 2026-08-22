function yazi_widget
    if not command -q yazi
        echo "yazi is not installed" >&2
        commandline -f repaint
        return 1
    end

    yazi
    commandline -f repaint
end
