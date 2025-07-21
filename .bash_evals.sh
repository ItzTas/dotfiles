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

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# pay-respects
if command -v pay-respects &>/dev/null; then
    eval "$(pay-respects bash --alias f)"
fi

# proto
if command -v proto &>/dev/null; then
    eval "$(proto activate bash)"
fi

# zoxide
if command -v zoxide &>/dev/null; then
    eval "$(zoxide init bash --cmd cd)"
fi

if command -v direnv &>/dev/null; then
    eval "$(direnv hook bash)"
fi
