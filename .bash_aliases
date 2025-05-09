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

# nvim
alias vim='nvim'
alias v='nvim .'

# grep
alias grep='grep --color=always'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# tmux
alias tattach='tmux attach'
alias tds='tmux new-session -s default'

# miru
alias mjs='miru npm'
alias mgo='miru go'
alias mrs='miru rs'

# pacman, paru & utilities
alias upacf='pacfiles --update-db *'
alias pacf='pacfiles -l'
alias upgrady='arch-update --check & paru -Syu --noconfirm --devel; flatpak update; sudo freshclam; paru -Fy; yadm_update; arch-update --check'
alias premove='paru -Qq | fzf --multi --preview "paru -Qi {}" | xargs -r paru -Rns --noconfirm'

# git
alias gitGraph='git --no-pager log --oneline --graph --all --decorate --stat --color --pretty=format:"%h %d %s %an %ar"'
alias gss='git status'

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
alias renderMarkdown='grip'
