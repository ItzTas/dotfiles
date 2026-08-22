function lsd_widget
    if not command -q lsd
        echo "lsd is not installed" >&2
        commandline -f repaint
        return 1
    end

    lsd -F
    commandline -f repaint
end
