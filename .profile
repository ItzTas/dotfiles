export XDG_DATA_DIRS="/var/lib/flatpak/exports/share:\"$HOME\"/.local/share/flatpak/exports/share:/usr/local/share:/usr/share"

# browser
export BROWSER='zen-browser'

# editor
export EDITOR='nvim'

# terminal
export TERMINAL="ghostty"

. "$HOME/.cargo/env"

export PATH="$HOME/.local/bin:$PATH"
