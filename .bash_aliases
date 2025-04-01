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

# pacman, yay & utilities
alias upacf='pacfiles --update-db *'
alias pacf='pacfiles -l'
alias upgrady='yay -Syu --devel; yadm_update'

# git
alias gitGraph='git --no-pager log --oneline --graph --all --decorate --stat --color --pretty=format:"%h %d %s %an %ar"'
alias gss='git status'

# yadm
alias yadm_update='~/.config/yadm/bin/yadm_update.sh'

# some more aliases
alias sc='sesh clone'
alias ksee='kitty +kitten icat'
alias killzoom='killall ZoomWebviewHost zoom'
alias chgra='chmod +x gradlew'
alias y='yazi'
alias python='python3'
alias c='bat --paging=never'
alias renderMarkdown='grip'
