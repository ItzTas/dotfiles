alias clear 'clear -x'

if command -q ddcutil
    alias dcs 'ddcutil setvcp 10'
end

if command -q lsd
    alias ls 'lsd --icon=always'
    alias ll 'lsd -alF --icon=always'
    alias la 'lsd -A --icon=always'
    alias l 'lsd -F --icon=always'
else
    alias ll 'ls -alF'
    alias la 'ls -A'
    alias l 'ls -F'
end

alias dir 'dir --color=always'
alias vdir 'vdir --color=always'

if command -q nvim
    alias vim nvim
    alias nano nvim
    alias v 'nvim .'

    if command -q nano
        alias cnano 'command nano'
    end
end

if command -q ufw
    alias _ufw_config 'chmod +x "$HOME/.config/yadm/bootstrap.x.d/set_up_ufw.sh" && "$HOME/.config/yadm/bootstrap.x.d/set_up_ufw.sh"'
end

alias grep 'grep --color=always'
alias fgrep 'grep -F --color=always'
alias egrep 'grep -E --color=always'

if command -q tmux
    alias tattach 'tmux attach'
    alias tds 'tmux new-session -s default'
end

if command -q miru
    alias mjs 'miru npm'
    alias mgo 'miru go'
    alias mrs 'miru rs'
end

if command -q pacfiles
    alias upacf 'pacfiles --update-db "*"'
    alias pacf 'pacfiles -l'
end
if command -q paru
    alias yay paru
    alias premove 'paru -Qq | fzf --multi --preview "paru -Qi {}" | xargs -r paru -Rns --noconfirm'
else if command -q yay
    alias premove 'yay -Qq | fzf --multi --preview "yay -Qi {}" | xargs -r yay -Rns --noconfirm'
    alias paru yay
end

if command -q git
    alias gl 'git log'

    alias gb 'git branch'

    alias gmt 'git mergetool --tool=nvimdiff'

    alias gcl 'git clone'
    alias gcm 'git commit'

    alias gpp 'git push'
    alias gu 'git pull'

    alias ga 'git add'
    alias gap 'git add --patch'
    alias gr 'git restore'
    alias grs 'git restore --staged'

    alias gds 'git diff --staged'
    alias gd 'git diff | diff-so-fancy'
end

if command -q yadm
    if command -q git-bug
        alias yadm-bug 'yadm bug'
    end
end

if command -q yazi
    alias y yazi
end

if command -q kitty
    alias icat 'kitty +kitten icat'
end

if command -q python3
    alias python python3
    alias jmolten 'python -m ipykernel install --user --name=python3 --display-name "Python 3 (Molten)"'
end
if command -q direnv
    alias da 'direnv allow'
end

if command -q bat
    alias cat 'bat --paging=never --style=plain'
    alias c 'bat --paging=never'
end

if command -q qman
    alias man qman
    alias cman 'command man'
end

if command -q psql
    alias spsql 'sudo systemctl start postgresql && sudo -u postgres psql'
    alias kpsql 'sudo systemctl stop postgresql'
end

if command -q sqlite3
    alias sqlite sqlite3
end

if command -q steam
    if command -q mangohud
        alias steam 'mangohud steam'
    end
end

if command -q glow
    alias glow 'glow -s "$HOME/.config/glow/themes/catppuccin-macchiato.json"'
end

if command -q grex
    alias grex 'grex -c'
end

if command -q grip
    alias renderMarkdown grip
end
alias chgra 'chmod +x gradlew'
alias nlsplog 'cat ~/.local/state/nvim/lsp.log'
alias xroot 'xhost +SI:localuser:root'
alias xrootoff 'xhost -SI:localuser:root'
