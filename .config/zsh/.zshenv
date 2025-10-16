#!/usr/bin/env zsh
# ~/.config/zsh/.zshenv

# ZDOTDIR
export ZDOTDIR="$HOME/.config/zsh"

# PATH essencial
export PATH="$HOME/.local/bin:/usr/local/bin:/usr/bin:$PATH"

# Virtualenv home
export VENV_HOME="$HOME/.virtualenvs"
[[ -d $VENV_HOME ]] || mkdir -p $VENV_HOME

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
