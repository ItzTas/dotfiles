#!/bin/bash

mkdir -p "$HOME/Downloads/"

cd "$HOME/Downloads/" || exit 1

_install_yay() {
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
        "cmake"
        "ferdium"
        "discord"
        "dotnet-sdk"
        "easyeffects"
        "fd"
        "fzf"
        "sesh-bin"
        "github-cli"
        "glues"
        "grim"
        "hyprpaper"
        "hyprshot"
        "kitty"
        "lazygit"
        "lsd"
        "man-db"
        "nemo"
        "neovim"
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
        "zsa-keymap-bin"
        "sddm-sugar-candy-git"
    )

    for package in "${packages[@]}"; do
        echo "Installing package: $package"
        yay -S "$package" --noconfirm
    done
}

_install_nvm() {
    if command -v nvm &>/dev/null; then
        echo "nvm is already installed. Skipping installation."
        return
    fi
    echo "Installing nvm"
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.2/install.sh | bash
    nvm install node
}

_install_rustup() {
    if command -v rustup &>/dev/null; then
        echo "Rustup is already installed. Skipping installation."
        return
    fi

    echo "Installing rustup"
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
}

_install_tpm() {
    git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
    tmux source "$HOME/.config/tmux/tmux.conf"
}

_install_yay
_install_nvm
_install_pacman_packages
_install_rustup
_install_tpm
