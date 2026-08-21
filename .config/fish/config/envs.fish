#!/usr/bin/env fish
# ~/.config/fish/config/envs.fish
#
# Interactive-only environment. Everything non-interactive shells also need
# (XDG dirs, PATH, telemetry opt-outs) lives in conf.d/00-env.fish.

# Virtualenv home
set -gx VENV_HOME "$HOME/.virtualenvs"
test -d "$VENV_HOME"; or mkdir -p "$VENV_HOME"

# Prompt/Project
set -gx MY_PROJECT_PATH "$PWD"

# Pager
set -gx PAGER less
set -gx LESS -FRX
set -gx MANPAGER 'less -RX'

# Themes
set -gx BAT_THEME "Catppuccin Mocha"
set -gx HYPRCURSOR_THEME Bibata-Modern-Classic

# Hyprshot
set -gx HYPRSHOT_DIR "$HOME/Pictures/screenshots/"

# Browser
set -gx BROWSER zen-browser

# Editor
set -gx EDITOR nvim

# Terminal
set -gx TERMINAL kitty

# GCC colors
set -gx GCC_COLORS 'error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# Disable next telemetry
set -gx NEXT_TELEMETRY_DISABLED 1

# Askpass
set -gx SUDO_ASKPASS /usr/lib/seahorse/ssh-askpass
