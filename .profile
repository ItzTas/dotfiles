export XDG_DATA_DIRS="/var/lib/flatpak/exports/share:$HOME/.local/share/flatpak/exports/share:/usr/local/share:/usr/share:$XDG_DATA_DIRS"
export QT_QPA_PLATFORMTHEME=qt6ct

# config home
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

# zsh home
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"

# browser
export BROWSER='zen-browser'

# editor
export EDITOR='nvim'

# terminal
export TERMINAL="ghostty"

# PATH
export PATH="$HOME/.local/bin:$PATH"
