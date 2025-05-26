# brightness controll
alias dcs='ddcutil setvcp 10'

# ls
alias ls='lsd'
alias ll='lsd -alF'
alias la='lsd -A'
alias l='lsd -F'

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
	alias v='nvim .'
fi

# grep
alias grep='grep --color=always'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# tmux
alias tattach='tmux attach'
alias tds='tmux new-session -s default'

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

# git
alias gitGraph='git --no-pager log --oneline --graph --all --decorate --stat --color --pretty=format:"%h %d %s %an %ar"'
alias gss='git status'
alias gc='git clone'

# yadm
alias yadm_update='chmod +x "$HOME/.config/yadm/bin/yadm_update.sh" && "$HOME/.config/yadm/bin/yadm_update.sh"'

# yazy
alias y='yazi'

# sesh
alias sc='sesh clone'

# kitty
alias icat='kitty +kitten icat'

# python
alias python='python3'

# cat | bat
alias cat='bat --paging=never'
alias c='command cat'

# man & utilities
alias man='qman'

# some more aliases
alias chgra='chmod +x gradlew'
if command -v grip &>/dev/null; then
	alias renderMarkdown='grip'
fi
