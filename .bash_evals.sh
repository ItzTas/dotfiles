# linuxbrew
# eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# oh my posh
if command -v oh-my-posh &>/dev/null; then
    if [ -f "$HOME/.config/ohmyposh/my_amro.toml" ]; then
        eval "$(oh-my-posh init bash --config "$HOME"/.config/ohmyposh/my_amro.toml)"
    else
        if command -v brew &>/dev/null && [ -f "$(brew --prefix oh-my-posh)/themes/amro.omp.json" ]; then
            eval "$(oh-my-posh init zsh --config "$(brew --prefix oh-my-posh)/themes/amro.omp.json")"
        fi
    fi
fi

# zoxide
eval "$(zoxide init --cmd cd bash)"

# pay-respects
eval "$(pay-respects bash --alias fk)"
