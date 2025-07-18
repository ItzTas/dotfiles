MY_PROJECT_PATH="$(pwd)"
export MY_PROJECT_PATH

# for not accidentally exiting with ctrl+d
export IGNOREEOF=999

# less
export LESS='-R'

# bat
export BAT_THEME="Catppuccin Mocha"

# browser
export BROWSER='zen browser'

# editor
export EDITOR='nvim'

# terminal
export TERMINAL="ghostty"

# colors in gcc
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
export HISTSIZE=1000
export HISTFILESIZE=2000
export HISTTIMEFORMAT='%m-%d %T '

# hyprcursor
export HYPRCURSOR_THEME="Bibata-Modern-Classic"

# hyprshot
export HYPRSHOT_DIR="$HOME/Pictures/screenshots/"

# XDG directories
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_DESKTOP_DIR="$HOME/Desktop"
export XDG_DOWNLOAD_DIR="$HOME/Downloads"
export XDG_TEMPLATES_DIR="$HOME/Templates"
export XDG_PUBLICSHARE_DIR="$HOME/Public"
export XDG_DOCUMENTS_DIR="$HOME/Docs"
export XDG_MUSIC_DIR="$HOME/Music"
export XDG_PICTURES_DIR="$HOME/Pictures"
export XDG_VIDEOS_DIR="$HOME/Videos"
