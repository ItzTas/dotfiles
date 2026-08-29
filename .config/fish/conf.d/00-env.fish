#!/usr/bin/env fish

# XDG base directories
set -gx XDG_CONFIG_HOME "$HOME/.config"
set -gx XDG_CACHE_HOME "$HOME/.cache"
set -gx XDG_DATA_HOME "$HOME/.local/share"
set -gx XDG_DESKTOP_DIR "$HOME/Desktop"
set -gx XDG_DOWNLOAD_DIR "$HOME/Downloads"
set -gx XDG_TEMPLATES_DIR "$HOME/Templates"
set -gx XDG_PUBLICSHARE_DIR "$HOME/Public"
set -gx XDG_DOCUMENTS_DIR "$HOME/Docs"
set -gx XDG_MUSIC_DIR "$HOME/Musics"
set -gx XDG_PICTURES_DIR "$HOME/Pictures"
set -gx XDG_VIDEOS_DIR "$HOME/Videos"

# Data dirs
test -n "$XDG_DATA_DIRS"; or set -gx XDG_DATA_DIRS /usr/local/share /usr/share
set -gx --path XDG_DATA_DIRS $XDG_DATA_DIRS
for dir in /var/lib/flatpak/exports/share "$HOME/.local/share/flatpak/exports/share"
    contains -- $dir $XDG_DATA_DIRS; or set -gx --path XDG_DATA_DIRS $dir $XDG_DATA_DIRS
end
set -e dir

# Qt platform theme
set -gx QT_QPA_PLATFORMTHEME qt6ct

# Zsh home
set -gx ZDOTDIR "$XDG_CONFIG_HOME/zsh"

# Wget and Curl config paths
set -gx WGETRC "$XDG_CONFIG_HOME/wget/wgetrc"
set -gx CURL_HOME "$XDG_CONFIG_HOME/curl"

# BuildKit for Docker/Podman
set -gx BUILDKIT 1

# PTPython config path
set -gx PTPYTHON_CONFIG_HOME "$XDG_CONFIG_HOME/ptpython"

# Android
set -gx ANDROID_HOME "$HOME/Android/Sdk"
set -gx ANDROID_AVD_HOME "$HOME/.config/.android/avd"

# Pnpm
set -gx PNPM_HOME "$HOME/.local/share/pnpm"

# Claude
set -gx CLAUDE_TELEMETRY_DISABLED 1
set -gx CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY 1
set -gx CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY 1

# Telemetry
set -gx DISABLE_TELEMETRY 1
set -gx DISABLE_ERROR_REPORTING 1
set -gx DISABLE_FEEDBACK_COMMAND 1
set -gx DO_NOT_TRACK 1

# Glab
set -gx GLAB_SEND_TELEMETRY false

# Streamlit
set -gx STREAMLIT_BROWSER_GATHER_USAGE_STATS false

# Storybook
set -gx STORYBOOK_DISABLE_TELEMETRY 1

# Ssh
set -gx SSH_ASKPASS /usr/lib/seahorse/ssh-askpass

# SearX
set -gx SEARXNG_URL http://10.66.66.1:8888

# OTHER
set -gx NODE_OPTIONS --max-old-space-size=8192

# ---- PATH EXPORTS ----

set -l prepend \
    "$PNPM_HOME" \
    "$HOME/.phpenv/bin" \
    "$ANDROID_HOME/tools" \
    "$ANDROID_HOME/platform-tools"

command -q yarn; and set -a prepend "$HOME/.yarn/bin"

set -a prepend \
    "$HOME/.local/bin" \
    /usr/local/bin \
    /usr/bin

set -l append \
    "$HOME/.dotnet/tools" \
    "$HOME/go/bin" \
    /var/lib/snapd/snap/bin \
    "$HOME/.config/yadm/bin" \
    "$HOME/.local/share/nvim/mason/bin" \
    "$ANDROID_HOME/emulator" \
    "$HOME/.cargo/bin"

fish_add_path -g -p $prepend
fish_add_path -g -a $append
