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
export XDG_DATA_DIRS="/var/lib/flatpak/exports/share:$HOME/.local/share/flatpak/exports/share:/usr/local/share:/usr/share:$XDG_DATA_DIRS"
for d in "$HOME/.virtualenvs"/*/share/applications; do
	if [ -d "$d" ]; then
		XDG_DATA_DIRS="$d:$XDG_DATA_DIRS"
	fi
done
export XDG_DATA_DIRS

# PATH
export PATH="$HOME/.local/bin:$PATH"
