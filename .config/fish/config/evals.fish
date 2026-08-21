#!/usr/bin/env fish
# ~/.config/fish/config/evals.fish
#
# Tools that print shell code to be evaluated at startup. In fish that is a
# pipe into `source`, not an eval.

# make less more friendly for non-text input files. lesspipe only emits sh
# syntax, so pick LESSOPEN out of its output instead of sourcing it
if test -x /usr/bin/lesspipe
    set -l lessopen (SHELL=/bin/sh lesspipe | string match -r "LESSOPEN='([^']*)'" | tail -n1)
    test -n "$lessopen"; and set -gx LESSOPEN "$lessopen"
end

# pay-respects
if command -q pay-respects
    pay-respects fish --alias f | source
end

# zoxide
if command -q zoxide
    zoxide init fish --cmd cd | source
end

# direnv
if command -q direnv
    direnv hook fish | source
end

# phpenv
if command -q phpenv
    phpenv init - fish | source
end

# keychain: reuse the running agent, and only start one when ssh-add reports
# it can't reach any (status 2)
if command -q keychain
    set -l kcenv "$HOME/.keychain/"(hostname)"-fish"
    test -f "$kcenv"; and source "$kcenv"

    ssh-add -l >/dev/null 2>&1
    if test $status -eq 2
        keychain -q env --shell fish | source
    end
end

# dircolors: strips the `LS_COLORS='...';` wrapper from the sh snippet, since
# fish can't source it
if command -q dircolors
    set -l dcfile "$__fish_config_dir/.dircolors"
    test -f "$dcfile"; or dircolors -p >"$dcfile"
    set -gx LS_COLORS (dircolors -b "$dcfile" | head -n1 | string replace -r "^LS_COLORS='" "" | string replace -r "';?\$" "")
end
