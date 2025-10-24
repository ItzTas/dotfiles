#!/usr/bin/env zsh

# ZDOTDIR
export ZDOTDIR="$HOME/.config/zsh"

# PATH essencial
export PATH="$HOME/.local/bin:/usr/local/bin:/usr/bin:$PATH"

# XDG base directories
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_DESKTOP_DIR="$HOME/Desktop"
export XDG_DOWNLOAD_DIR="$HOME/Downloads"
export XDG_TEMPLATES_DIR="$HOME/Templates"
export XDG_PUBLICSHARE_DIR="$HOME/Public"
export XDG_DOCUMENTS_DIR="$HOME/Docs"
export XDG_MUSIC_DIR="$HOME/Musics"
export XDG_PICTURES_DIR="$HOME/Pictures"
export XDG_VIDEOS_DIR="$HOME/Videos"

# Wget and Curl config paths
export WGETRC="${XDG_CONFIG_HOME}/wget/wgetrc"
export CURL_HOME="${XDG_CONFIG_HOME}/curl"

# BuildKit for Docker/Podman
export BUILDKIT=1

# PTPython config path
export PTPYTHON_CONFIG_HOME="${XDG_CONFIG_HOME}/ptpython"

# HOMES
export ANDROID_HOME="$HOME/.AndroidS/Sdk"
export PNPM_HOME="/home/talinux/.local/share/pnpm"

# ---- PATH EXPORTS ----
if (( ${+commands[yarn]} )); then
    export PATH="$HOME/.yarn/bin:$PATH"
fi
export PATH="$HOME/.local/bin:$PATH"
export PATH="$PATH:/home/talinux/.dotnet/tools"
export PATH="$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools:$PATH"
export PATH="$PATH:$HOME/go/bin"
export PATH="$HOME/.phpenv/bin:$PATH"
export PATH="$PATH:$HOME/.cargo/env"
export PATH="$PATH:/var/lib/snapd/snap/bin"
export PATH="$PATH:$HOME/.config/yadm/bin"
export PATH="$HOME/.config/yadm/bin:$PATH"

# pnpm
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
