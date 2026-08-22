#!/usr/bin/env fish

# clear
alias clear 'clear -x'

# ls && utils
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

# editor
if command -q nvim
    alias vim nvim
    alias nano nvim
    alias v 'nvim .'

    if command -q nano
        alias cnano 'command nano'
    end
end

# grep
alias grep 'grep --color=always'
alias fgrep 'grep -F --color=always'
alias egrep 'grep -E --color=always'

# AUR helper
if command -q paru
    alias yay paru
else if command -q yay
    alias paru yay
end

# file manager
if command -q yazi
    alias y yazi
end

# images in the terminal
if command -q kitty
    alias icat 'kitty +kitten icat'
end

# python
if command -q python3
    alias python python3
end

# cat
if command -q bat
    alias cat 'bat --paging=never --style=plain'
    alias c 'bat --paging=never'
end

# man
if command -q qman
    alias man qman
    alias cman 'command man'
end

# sqlite
if command -q sqlite3
    alias sqlite sqlite3
end

# steam
if command -q steam
    if command -q mangohud
        alias steam 'mangohud steam'
    end
end

# markdown
if command -q glow
    alias glow 'glow -s "$HOME/.config/glow/themes/catppuccin-macchiato.json"'
end

if command -q grip
    alias renderMarkdown grip
end

# regex builder
if command -q grex
    alias grex 'grex -c'
end

