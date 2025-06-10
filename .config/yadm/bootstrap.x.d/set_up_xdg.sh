_create_symlinks() {
    [ ! -d ~/.local/bin ] && mkdir -p ~/.local/bin
    [ ! -L ~/.local/bin/x-www-browser ] && ln -sf "$(which zen-browser)" ~/.local/bin/x-www-browser
    [ ! -L ~/.local/bin/x-terminal-emulator ] && ln -s "$(which ghostty)" ~/.local/bin/x-terminal-emulator
}

_set_up() {
    xdg-mime default mpv.desktop video/mp4
    xdg-mime default mpv.desktop video/x-matroska
    xdg-mime default mpv.desktop video/webm
    # xdg-mime default ghostty.desktop x-scheme-handler/terminal
    xdg-mime default nemo.desktop inode/directory application/x-gnome-saved-search
    xdg-mime default nemo.desktop inode/directory

    _create_symlinks
}

_set_up
