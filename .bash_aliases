# brightness controll
if command -v ddcutil &>/dev/null; then
    alias dcs='ddcutil setvcp 10'
fi

# ls && utils
if command -v lsd &>/dev/null; then
    alias ls='lsd'
    alias ll='lsd -alF'
    alias la='lsd -A'
    alias l='lsd -F'
else
    alias ll='ls -alF'
    alias la='ls -A'
    alias l='ls -F'
fi

# dir
alias dir='dir --color=auto'
alias vdir='vdir --color=auto'

# bitwarden
if command -v bw &>/dev/null; then
    alias ubw='export BW_SESSION=$(bw unlock --raw)'
fi

# nvim
if command -v nvim &>/dev/null; then
    alias vim='nvim'
    alias nano='nvim'
    alias v='nvim .'

    if command -v nano &>/dev/null; then
        alias cnano='command nano'
    fi
fi

# ufw
if command -v ufw &>/dev/null; then
    alias _ufw_config='chmod +x "$HOME/.config/yadm/bootstrap.x.d/set_up_ufw.sh" && "$HOME/.config/yadm/bootstrap.x.d/set_up_ufw.sh"'
fi

# grep
alias grep='grep --color=always'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# tmux
if command -v tmux &>/dev/null; then
    alias tattach='tmux attach'
    alias tds='tmux new-session -s default'
fi

# miru
if command -v miru &>/dev/null; then
    alias mjs='miru npm'
    alias mgo='miru go'
    alias mrs='miru rs'
fi

# pacman, paru & utilities
if command -v pacfiles &>/dev/null; then
    alias upacf='pacfiles --update-db *'
    alias pacf='pacfiles -l'
fi
alias premove='paru -Qq | fzf --multi --preview "paru -Qi {}" | xargs -r paru -Rns --noconfirm'
alias yay='paru'

# git
if command -v git &>/dev/null; then
    alias gitGraph='git --no-pager log --oneline --graph --all --decorate --stat --color --pretty=format:"%h %d %s %an %ar"'
    alias gss='git status'
    alias gc='git clone'
fi

# yadm
if command -v yadm &>/dev/null; then
    alias yadm_update='chmod +x "$HOME/.config/yadm/bin/yadm_update.sh" && "$HOME/.config/yadm/bin/yadm_update.sh"'
fi

# yazy
if command -v yazi &>/dev/null; then
    alias y='yazi'
fi

# sesh
if command -v sesh &>/dev/null; then
    alias sc='sesh clone'
fi

# kitty
if command -v kitty &>/dev/null; then
    alias icat='kitty +kitten icat'
fi

# python & utils
if command -v python3 &>/dev/null; then
    alias python='python3'
fi
if command -v direnv &>/dev/null; then
    alias da='direnv allow'
fi

# cat | bat
if command -v bat &>/dev/null; then
    alias cat='bat --paging=never --style=plain'
    alias c='bat --paging=never'
fi

# man & utilities
if command -v qman &>/dev/null; then
    alias man='qman'
    alias cman='command man'
fi

# some more aliases
if command -v grip &>/dev/null; then
    alias renderMarkdown='grip'
fi
alias chgra='chmod +x gradlew'
