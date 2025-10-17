export XDG_DATA_DIRS="/var/lib/flatpak/exports/share:$HOME/.local/share/flatpak/exports/share:/usr/local/share:/usr/share:$XDG_DATA_DIRS"
export QT_QPA_PLATFORMTHEME=qt6ct

# Initializes gnome-keyring-daemon
if command -v gnome-keyring-daemon >/dev/null 2>&1; then
	eval "$(gnome-keyring-daemon --start --components=pkcs11,secrets,ssh)" || true
	export SSH_AUTH_SOCK="${SSH_AUTH_SOCK:-}"
fi

# Config home
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

# Zsh home
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"

# Browser
export BROWSER='zen-browser'

# Editor
export EDITOR='nvim'

# Terminal
export TERMINAL="ghostty"

# PATH
export PATH="$HOME/.local/bin:$PATH"
