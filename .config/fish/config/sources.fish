#!/usr/bin/env fish

# cargo
if command -q cargo
    if test -f "$HOME/.cargo/env.fish"
        source "$HOME/.cargo/env.fish"
    else if test -d "$HOME/.cargo/bin"
        fish_add_path -g -p "$HOME/.cargo/bin"
    end
end

# less
if test -x /usr/bin/lesspipe
    set -l lessopen (SHELL=/bin/sh lesspipe | string match -r "LESSOPEN='([^']*)'" | tail -n1)
    test -n "$lessopen"; and set -gx LESSOPEN "$lessopen"
end

__cached_init pay-respects fish --alias f
__cached_init zoxide init fish --cmd cd
__cached_init direnv hook fish
__cached_init phpenv init - fish

if command -q keychain
    set -l kcenv "$HOME/.keychain/$hostname-fish"
    test -f "$kcenv"; and source "$kcenv"

    if not test -S "$SSH_AUTH_SOCK"
        ssh-add -l >/dev/null 2>&1
        test $status -eq 2; and keychain -q env --shell fish | source
    end
end

if command -q dircolors
    set -l dcfile "$__fish_config_dir/.dircolors"
    test -f "$dcfile"; or dircolors -p >"$dcfile"

    set -l cache "$XDG_CACHE_HOME/dircolors/"(path mtime -- "$dcfile")".fish"

    if not test -f "$cache"
        mkdir -p (path dirname -- "$cache")
        echo "set -gx LS_COLORS "(string escape -- (dircolors -b "$dcfile" | head -n1 | string replace -r "^LS_COLORS='" "" | string replace -r "';?\$" "")) >"$cache.tmp$fish_pid"
        and mv -f "$cache.tmp$fish_pid" "$cache"
        or rm -f "$cache.tmp$fish_pid"
    end

    test -f "$cache"; and source "$cache"
end
