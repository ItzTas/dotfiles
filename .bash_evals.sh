# linuxbrew
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# oh my posh
eval "$(oh-my-posh init bash --config "$HOME"/.config/ohmyposh/my_amro.toml)"

# zoxide
eval "$(zoxide init --cmd cd bash)"

# pay-respects
eval "$(pay-respects bash --alias fk)"
