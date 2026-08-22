#!/usr/bin/env fish

# git
if command -q git
    abbr -a gl git log

    abbr -a gb git branch

    abbr -a gmt git mergetool --tool=nvimdiff

    abbr -a gcl git clone
    abbr -a gcm git commit

    abbr -a gpp git push
    abbr -a gu git pull

    abbr -a ga git add
    abbr -a gap git add --patch
    abbr -a gr git restore
    abbr -a grs git restore --staged

    abbr -a gds git diff --staged
    abbr -a gd 'git diff | diff-so-fancy'
end

# dotfiles
if command -q yadm; and command -q git-bug
    abbr -a yadm-bug yadm bug
end

# tmux
if command -q tmux
    abbr -a tattach tmux attach
    abbr -a tds tmux new-session -s default
end

# miru
if command -q miru
    abbr -a mjs miru npm
    abbr -a mgo miru go
    abbr -a mrs miru rs
end

# pacman file search
if command -q pacfiles
    abbr -a upacf pacfiles --update-db '*'
    abbr -a pacf pacfiles -l
end

# interactive package removal
if command -q paru
    abbr -a premove 'paru -Qq | fzf --multi --preview "paru -Qi {}" | xargs -r paru -Rns --noconfirm'
else if command -q yay
    abbr -a premove 'yay -Qq | fzf --multi --preview "yay -Qi {}" | xargs -r yay -Rns --noconfirm'
end

# brightness control
if command -q ddcutil
    abbr -a dcs ddcutil setvcp 10
end

# firewall
if command -q ufw
    abbr -a _ufw_config 'chmod +x "$HOME/.config/yadm/bootstrap.x.d/set_up_ufw.sh" && "$HOME/.config/yadm/bootstrap.x.d/set_up_ufw.sh"'
end

# direnv
if command -q direnv
    abbr -a da direnv allow
end

# python
if command -q python3
    abbr -a jmolten python -m ipykernel install --user --name=python3 --display-name '"Python 3 (Molten)"'
end

# postgres
if command -q psql
    abbr -a spsql 'sudo systemctl start postgresql && sudo -u postgres psql'
    abbr -a kpsql sudo systemctl stop postgresql
end

# odds and ends
abbr -a chgra chmod +x gradlew
abbr -a nlsplog cat ~/.local/state/nvim/lsp.log
abbr -a xroot xhost +SI:localuser:root
abbr -a xrootoff xhost -SI:localuser:root
