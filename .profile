# qt
export QT_QPA_PLATFORMTHEME=qt6ct

# config home
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

# zsh home
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"

# browser
export BROWSER="zen-browser"

# editor
export EDITOR="nvim"

# terminal
export TERMINAL="ghostty"

# desktop dirs
export XDG_DATA_DIRS="$HOME/.local/share/flatpak/exports/share:/var/lib/flatpak/exports/share:/usr/local/share:/usr/share${XDG_DATA_DIRS:+:$XDG_DATA_DIRS}"

# PATH
export PATH="$HOME/.local/bin:$PATH"

if command -v yadm >/dev/null; then
	export PATH="$HOME/.config/yadm/bin:$PATH"
fi
