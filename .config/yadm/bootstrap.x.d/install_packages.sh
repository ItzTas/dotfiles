#!/bin/bash

[ -d "$HOME/Downloads" ] || mkdir "$HOME/Downloads"

cd "$HOME/Downloads" || exit 1

_install_yay() {
    set -e
    if command -v yay &>/dev/null; then
        echo "yay is already installed. Skipping installation."
        return
    fi

    echo "Downloading and installing yay"
    git clone https://aur.archlinux.org/yay.git
    cd yay || exit 1
    makepkg -si --noconfirm
    cd ..
    rm -rf yay
}

_install_pacman_packages() {
    set -e
    local packages=(
        "os-prober"
        "arch-update"
        "miru-go-bin"
        "proto-bin"
        "brightnessctl"
        "docker"
        "docker-desktop"
        "ddcutil"
        "xorg-xhost"
        "cmake"
        "mpv"
        "wf-recorder"
        "ferdium"
        "discord"
        "dotnet-sdk"
        "easyeffects"
        "fd"
        "lsp-plugins"
        "paru"
        "fzf"
        "bash-completion"
        "sesh-bin"
        "github-cli"
        "glues"
        "pay-respects"
        "grim"
        "imfile"
        "hyprpaper"
        "clipse"
        "clipse-gui"
        "hyprshot"
        "kitty"
        "lazygit"
        "ghostty"
        "lsd"
        "man-db"
        "wget"
        "curl"
        "nemo"
        "cronie"
        "neovim"
        "wl-clip-persist"
        "oh-my-posh"
        "pacfiles"
        "ripgrep"
        "imv"
        "dunst"
        "zen-browser-bin"
        "bat"
        "bash-language-server"
        "rofi"
        "shellcheck"
        "shfmt"
        "slurp"
        "spotify"
        "stacer-bin"
        "termpicker"
        "thunderbird"
        "tmux"
        "ttf-jetbrains-mono-nerd"
        "unzip"
        "waybar"
        "wl-clipboard"
        "xdg-user-dirs"
        "yq"
        "zip"
        "zoxide"
        "zsa-keymapp-bin"
        "sddm-sugar-candy-git"
        "easyeffects-bundy01-presets"
        "calf"
        "yazi"
    )
    local installed=()

    for package in "${packages[@]}"; do
        if yay -Q "$package" &>/dev/null; then
            echo "Package '$package' is already installed, skipping..."
        else
            echo "Installing package: $package"
            yay -S "$package" --noconfirm
            installed+=("$package")
        fi
    done

    if [ ${#installed[@]} -gt 0 ]; then
        echo "The following packages were installed: ${installed[*]}"
    else
        echo "No new packages were installed."
    fi
}

_install_nvm() {
    if [ -d "$HOME/.nvm" ]; then
        echo "nvm is already installed. Skipping installation."
        return
    fi

    echo "Installing nvm..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.2/install.sh | bash

    export NVM_DIR="$HOME/.nvm"

    # shellcheck disable=SC1091
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    # shellcheck disable=SC1091
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

    nvm install node
}

_install_rustup() {
    set -e
    if command -v rustup &>/dev/null; then
        echo "Rustup is already installed. Skipping installation."
        return
    fi

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

_curl_and_wget_installations() {
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/JackHack96/PulseEffects-Presets/master/install.sh)"
}

_source_git_installations() {
    echo "Changing to Downloads directory..."
    cd "$HOME/Downloads" || (mkdir -p "$HOME/Downloads" && cd "$HOME/Downloads")

    echo "Cloning EasyEffects-Presets repository..."
    git clone "https://github.com/Digitalone1/EasyEffects-Presets" && cd EasyEffects-Presets

    echo "Copying LoudnessEqualizer.json to EasyEffects output directory..."
    cp LoudnessEqualizer.json "$HOME/.config/easyeffects/output/"

    echo "Returning to Downloads directory..."
    cd "$HOME/Downloads"

    echo "Cleaning up by removing the cloned EasyEffects-Presets directory..."
    rm -rf "$HOME/Downloads/EasyEffects-Presets"

    echo "Operation complete!"
}

_install_yay
_install_nvm
_install_pacman_packages
_install_rustup
_install_tpm
# _curl_and_wget_installations
_source_git_installations
