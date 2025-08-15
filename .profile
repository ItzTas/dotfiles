export XDG_DATA_DIRS="/var/lib/flatpak/exports/share:\"$HOME\"/.local/share/flatpak/exports/share:/usr/local/share:/usr/share"
export QT_QPA_PLATFORMTHEME=qt6ct

# PATH
export PATH="$HOME/.local/bin:$PATH"

# browser
export BROWSER='zen-browser'

# editor
export EDITOR='nvim'

# terminal
export TERMINAL="ghostty"

. "$HOME/.cargo/env"
