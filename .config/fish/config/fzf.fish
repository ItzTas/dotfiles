#!/usr/bin/env fish

set -gx FZF_ALT_C_COMMAND ""

# Key bindings
if command -q fzf
    if not path is -f -- "$XDG_CACHE_HOME/fzf.fish"
        fzf --fish >"$XDG_CACHE_HOME/fzf.fish"
    end
    source "$XDG_CACHE_HOME/fzf.fish"
end

# Sources
set -gx FZF_DEFAULT_COMMAND "fd --hidden --strip-cwd-prefix --exclude .git"
set -gx FZF_CTRL_T_COMMAND "$FZF_DEFAULT_COMMAND"

# Catppuccin Mocha
set -gx FZF_DEFAULT_OPTS " \
    --ansi \
    --bind ctrl-y:accept \
    --color=spinner:#F5E0DC,hl:#F38BA8 \
    --color=fg:#CDD6F4,header:#F38BA8,info:#CBA6F7,pointer:#F5E0DC \
    --color=marker:#B4BEFE,fg+:#CDD6F4,prompt:#CBA6F7,hl+:#F38BA8 \
    --color=selected-bg:#45475A \
    --color=border:#6C7086,label:#CDD6F4
"

# Previews
set -gx FZF_CTRL_T_OPTS "--preview 'bat -n --color=always --line-range :500 {}'"
set -gx FZF_ALT_C_OPTS "--preview 'lsd --icon always --tree --depth 2 -F {}'"
