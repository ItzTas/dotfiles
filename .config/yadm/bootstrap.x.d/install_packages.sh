#!/bin/env bash

[ -d "$HOME/Downloads" ] || mkdir "$HOME/Downloads"

cd "$HOME/Downloads" || exit 1

_install_paru() {
    echo ""
    echo "Iniciating paru installation"
    echo ""

    set -e
    if command -v paru &>/dev/null; then
        echo "paru is already installed. Skipping installation."
        return
    fi

    echo "Downloading and installing paru"
    sudo pacman -S --needed base-devel
    git clone https://aur.archlinux.org/paru.git
    cd paru || exit 1
    makepkg -si --noconfirm
    cd ..
    rm -rf paru
}

_install_pacman_packages() {
    echo ""
    echo "Iniciating pacman installations"
    echo ""

    local packages=(
        # Terminals
        "ghostty"
        "kitty"

        # Themes & Looks
        "waybar"
        "sddm-sugar-candy-git"
        "oh-my-posh"
        "swayosd-gtk3"
        "kando-bin"
        "spicetify-cli"
        "eww"

        # Hyprland ecosystem
        "xdg-desktop-portal-hyprland"
        "hyprpicker"
        "hyprpaper"
        "hyprshade"
        "hyprshot"
        "hyprlock"
        "hypridle"

        # System utils
        "xdg-user-dirs"
        "cronie"
        "socat"
        "inetutils"
        "os-prober"
        "xorg-xrandr"
        "arch-update"
        "xorg-xhost"

        # Process Manegement
        "stacer-git"
        "btop"

        # Package managers
        "flatpak"
        "proto"
        "paru"

        # Package manager helpers
        "pacfiles"

        # Cli tools
        "yq"
        "zip"
        "unrar"
        "jq"
        "fzf"
        "wget"
        "qman"
        "man-db"
        "ripgrep"
        "curl"
        "miru-go-bin"
        "ddcutil"
        "brightnessctl"
        "fastfetch"
        "pay-respects"

        # Cli file utils
        "unzip"
        "eza"
        "lsd"
        "fd"
        "zoxide"
        "bat"

        # Apps
        "zsa-keymapp-bin"
        "spotify"
        "vesktop-git"
        "ferdium"
        "clamtk"

        # Docker
        "lazydocker"
        "docker-compose"
        "docker"

        # Cursor & Fonts
        "ttf-jetbrains-mono-nerd"
        "bibata-cursor-theme"
        "ttf-nerd-fonts-symbols"

        # Git
        "lazygit"
        "github-cli"
        "git-bug"

        # Tui
        "ncdu"
        "gping"

        # Compositors
        "weston"
        "hyprland"

        # Notifications
        "dunst"
        "inotify-tools"

        # Displayers
        "gthumb"
        "mpv"

        # Capture
        "flameshot-git"
        "slurp"
        "wf-recorder"
        "grim"

        # Clipboard
        "wl-clipboard"
        "wl-clip-persist"
        "clipse"
        "clipse-gui"

        # File managers & extensions
        "yazi"
        "nemo"
        "nemo-fileroller"
        "nemo-terminal"
        "nemo-image-converter"
        "nemo-media-columns"

        # Terminal session management
        "tmux"
        "sesh-bin"

        # Sound
        "easyeffects"
        "lsp-plugins"
        "calf"

        # Languages
        "dotnet-sdk"

        # Browsers & Emails
        "zen-browser-bin"
        "thunderbird"

        # Editors
        "neovim"
        "vim"

        # App lanchers & utils
        "rofi-wayland"
        "rofi-emoji"

        # Others
        "timeshift"
        "termpicker"

        # Essentials
        "cmake"
        "polkit-gnome"
    )

    local installed=()
    local faileds=()

    for package in "${packages[@]}"; do
        if paru -Q "$package" &>/dev/null; then
            echo "Package '$package' is already installed, skipping..."
        else
            echo "Installing package: $package"
            if paru -S "$package" --noconfirm; then
                installed+=("$package")
            else
                echo "❌ Failed to install '$package', skipping..."
                faileds+=("$package")
            fi
        fi
    done

    if [ ${#installed[@]} -gt 0 ]; then
        echo "✅ The following packages were installed: ${installed[*]}"
    else
        echo "No new packages were installed"
    fi

    if [ ${#faileds[@]} -gt 0 ]; then
        echo "⚠️ The following packages failed to install: ${faileds[*]}"
    fi

    echo ""
}

_install_rustup() {
    set -e
    if command -v rustup &>/dev/null; then
        echo "Rustup is already installed. Skipping installation."
        return
    fi

    sudo pacman -Rns rust --noconfirm

    echo "Installing rustup"
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
}

_install_tpm() {
    set -e
    local tpm_dir="$HOME/.config/tmux/plugins/tpm"

    if [ -d "$tpm_dir" ]; then
        echo "TPM already installed. Skipping installation."
    else
        echo "Installing TPM..."
        git clone https://github.com/tmux-plugins/tpm "$tpm_dir"
    fi

    tmux source "$HOME/.config/tmux/tmux.conf"
}

_install_jackhack96_ef_presets() {
    local dest="$HOME/.config/easyeffects/output/"
    local files=(
        "Advanced Auto Gain.json"
        "Bass Boosted.json"
        "Bass Enhancing + Perfect EQ.json"
        "Boosted.json"
        "Loudness+Autogain.json"
        "Perfect EQ.json"
    )

    echo "Checking if any required files are missing..."

    for file in "${files[@]}"; do
        if [[ ! -f "$dest$file" ]]; then
            echo "$file is missing. Installing presets..."
            echo 1 | bash -c "$(curl -fsSL https://raw.githubusercontent.com/JackHack96/PulseEffects-Presets/master/install.sh)"
            break
        else
            echo "$file already exists. Skipping download."
        fi
    done
}

_curl_and_wget_installations() {
    echo "Iniciating http/https installations"

    echo ""
    _install_jackhack96_ef_presets
    echo ""
}

_install_p-chan_ef_presets() {
    local dest="$HOME/.config/easyeffects/output"
    local tmpdir
    tmpdir=$(mktemp -d)

    echo "Cloning EasyPulse repository temporarily..."
    git clone --depth=1 "https://github.com/p-chan5/EasyPulse" "$tmpdir"

    echo "Files in the cloned output directory:"
    ls "$tmpdir/output/"

    echo "Checking if files already exist in the destination directory..."
    mkdir -p "$dest"
    for file in "$tmpdir/output/"*; do
        filename=$(basename "$file")
        dest_file="$dest/$filename"

        if [[ -f "$dest_file" ]]; then
            if cmp -s "$file" "$dest_file"; then
                echo "$filename already exists and is identical. Skipping..."
            else
                echo "$filename exists but differs. Updating..."
                cp "$file" "$dest_file"
            fi
        else
            echo "$filename does not exist in $dest. Copying..."
            cp "$file" "$dest_file"
        fi
    done

    echo "Presets installed at: $dest"

    rm -rf "$tmpdir"
}

_install_rabcor_ef_presets() {
    local dest="$HOME/.config/easyeffects/output"
    local tmpdir
    tmpdir=$(mktemp -d)

    echo "Cloning Heavy-Bass-EE repository temporarily..."
    git clone --depth=1 "https://github.com/Rabcor/Heavy-Bass-EE" "$tmpdir"

    rm -rf "$tmpdir/.git" "$tmpdir/LICENSE" "$tmpdir/README.md"

    echo "Files in the cloned output directory:"
    ls "$tmpdir/"

    echo "Checking if files already exist in the destination directory..."
    mkdir -p "$dest"
    for file in "$tmpdir/"*; do
        filename=$(basename "$file")
        dest_file="$dest/$filename"

        if [[ -f "$dest_file" ]]; then
            if cmp -s "$file" "$dest_file"; then
                echo "$filename already exists and is identical. Skipping..."
            else
                echo "$filename exists but differs. Updating..."
                cp "$file" "$dest_file"
            fi
        else
            echo "$filename does not exist in $dest. Copying..."
            cp "$file" "$dest_file"
        fi
    done

    echo "Presets installed at: $dest"

    rm -rf "$tmpdir"
}

_install_crachecode_ef_presets() {
    local dest="$HOME/.config/easyeffects/output"
    local tmpdir
    tmpdir=$(mktemp -d)

    echo "Cloning crachecode repository temporarily..."
    git clone --depth=1 "https://gitlab.com/crachecode/easyeffects-eq-presets" "$tmpdir"

    rm -rf "$tmpdir/.git" "$tmpdir/LICENSE" "$tmpdir/README.md"

    echo "Files in the cloned output directory:"
    ls "$tmpdir/"

    echo "Checking if files already exist in the destination directory..."
    mkdir -p "$dest"
    for file in "$tmpdir/"*; do
        filename=$(basename "$file")
        dest_file="$dest/$filename"

        if [[ -f "$dest_file" ]]; then
            if cmp -s "$file" "$dest_file"; then
                echo "$filename already exists and is identical. Skipping..."
            else
                echo "$filename exists but differs. Updating..."
                cp "$file" "$dest_file"
            fi
        else
            echo "$filename does not exist in $dest. Copying..."
            cp "$file" "$dest_file"
        fi
    done

    echo "Presets installed at: $dest"

    rm -rf "$tmpdir"
}

_install_loudness_equalizer_ef_preset() {
    local dest="$HOME/.config/easyeffects/output/LoudnessEqualizer.json"
    local tmpdir
    tmpdir=$(mktemp -d)

    echo "Cloning loudness equalizer repository temporarily..."
    git clone --depth=1 "https://github.com/Digitalone1/EasyEffects-Presets" "$tmpdir"

    if [[ -f "$dest" ]]; then
        if cmp -s "$tmpdir/LoudnessEqualizer.json" "$dest"; then
            echo "Preset already exists and is identical. Skipping installation."
            rm -rf "$tmpdir"
            return
        else
            echo "Preset exists but differs. Updating..."
        fi
    else
        echo "Preset does not exist. Installing..."
    fi

    mkdir -p "$(dirname "$dest")"
    cp "$tmpdir/LoudnessEqualizer.json" "$dest"

    echo "Preset installed at: $dest"

    rm -rf "$tmpdir"
}

_install_flatpak_packages() {

    if ! command -v flatpak &>/dev/null; then
        echo "Flatpak is not installed. Installing..."
        sudo pacman -Sy --noconfirm flatpak
    fi

    if ! command -v flatpak &>/dev/null; then
        echo "Failed to install flatpak. Skipping"
        return
    fi

    local sources=(
        "https://flathub.org/repo/flathub.flatpakrepo"
    )

    echo "Iniciating flatpak installations"

    for source in "${sources[@]}"; do
        flatpak remote-add --if-not-exists "$(basename "$source" .flatpakrepo)" "$source"
    done

    local flathub_packages=(
        "com.stremio.Stremio"
        "com.protonvpn.www"
        # "surf.deckr.deckr"
    )

    for package in "${flathub_packages[@]}"; do
        flatpak install --assumeyes --noninteractive flathub "$package"
    done
}

_install_oficial_kando_themes() {
    local dest="$HOME/.config/kando/menu-themes"
    local tmpdir
    tmpdir=$(mktemp -d)

    echo "Cloning oficial themes from kando temporarily..."
    git clone --depth=1 "https://github.com/kando-menu/menu-themes" "$tmpdir"

    mkdir -p "$dest"

    for theme_path in "$tmpdir"/themes/*; do
        theme_name=$(basename "$theme_path")
        dest_path="$dest/$theme_name"

        if [[ -d "$dest_path" ]]; then
            if diff -qr "$theme_path" "$dest_path" >/dev/null; then
                echo "Theme '$theme_name' already exists and is identical. Skipping."
                continue
            else
                echo "Theme '$theme_name' exists but differs. Updating..."
                rm -rf "$dest_path"
            fi
        else
            echo "Installing new theme '$theme_name'..."
        fi

        cp -r "$theme_path" "$dest_path"
    done

    rm -rf "$tmpdir"
    echo "Themes installation complete."
}

_install_kando_themes() {
    _install_oficial_kando_themes
}

_source_installations() {
    echo "Iniciating source installations"

    echo ""
    _install_loudness_equalizer_ef_preset

    echo ""
    _install_rabcor_ef_presets

    # echo ""
    # _install_p-chan_ef_presets

    echo ""
    _install_crachecode_ef_presets

    echo ""
    _install_kando_themes
}

_install_paru || true
_install_pacman_packages || true
_install_rustup || true
_install_tpm || true
_curl_and_wget_installations || true
_source_installations || true
_install_flatpak_packages || true
