function setgtktheme
    if not command -q gsettings
        echo "gsettings is not installed" >&2
        return 1
    end

    gsettings set org.gnome.desktop.interface gtk-theme "$argv[1]"
end
