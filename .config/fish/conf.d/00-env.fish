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

set -gx WGETRC "$XDG_CONFIG_HOME/wget/wgetrc"
set -gx CURL_HOME "$XDG_CONFIG_HOME/curl"

set -gx BUILDKIT 1

set -gx PTPYTHON_CONFIG_HOME "$XDG_CONFIG_HOME/ptpython"

set -gx ANDROID_HOME "$HOME/Android/Sdk"
set -gx ANDROID_AVD_HOME "$HOME/.config/.android/avd"

set -gx PNPM_HOME "$HOME/.local/share/pnpm"

set -gx CLAUDE_TELEMETRY_DISABLED 1
set -gx CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY 1
set -gx CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY 1

set -gx DISABLE_TELEMETRY 1
set -gx DISABLE_ERROR_REPORTING 1
set -gx DISABLE_FEEDBACK_COMMAND 1
set -gx DO_NOT_TRACK 1

set -gx GLAB_SEND_TELEMETRY false

set -gx STREAMLIT_BROWSER_GATHER_USAGE_STATS false

set -gx STORYBOOK_DISABLE_TELEMETRY 1

set -gx SSH_ASKPASS /usr/lib/seahorse/ssh-askpas

set -gx SEARXNG_URL http://10.66.66.1:8888

set -gx NODE_OPTIONS --max-old-space-size=8192

fish_add_path -g -p "$HOME/.local/bin" /usr/local/bin /usr/bin

if command -q yarn
    fish_add_path -g -p "$HOME/.yarn/bin"
end

fish_add_path -g -p "$ANDROID_HOME/tools" "$ANDROID_HOME/platform-tools"
fish_add_path -g -p "$HOME/.phpenv/bin"
fish_add_path -g -p "$PNPM_HOME"

fish_add_path -g -a "$HOME/.dotnet/tools"
fish_add_path -g -a "$HOME/go/bin"
fish_add_path -g -a /var/lib/snapd/snap/bin
fish_add_path -g -a "$HOME/.config/yadm/bin"
fish_add_path -g -a "$HOME/.local/share/nvim/mason/bin"
fish_add_path -g -a "$ANDROID_HOME/emulator"
fish_add_path -g -a "$HOME/.cargo/bin"
