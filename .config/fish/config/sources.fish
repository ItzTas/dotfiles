#!/usr/bin/env fish

# cargo
if command -q cargo
    if path is -f -- "$HOME/.cargo/env.fish"
        source "$HOME/.cargo/env.fish"
    else if path is -d -- "$HOME/.cargo/bin"
        fish_add_path -g -p "$HOME/.cargo/bin"
    end
end

# less
if path is -x /usr/bin/lesspipe
    set -l lessopen (SHELL=/bin/sh lesspipe | string match -r "LESSOPEN='([^']*)'" | tail -n1)
    test -n "$lessopen"; and set -gx LESSOPEN "$lessopen"
end

# keychain
if command -q keychain
    ssh-add -l >/dev/null 2>&1

    if test $status -eq 2
        keychain -q agent start >/dev/null 2>&1

        for line in (keychain -q env --shell env 2>/dev/null)
            set -l pair (string split -m1 -- = $line)
            test (count $pair) -eq 2; and set -gx $pair[1] $pair[2]
        end
    end
end

# dircolors
if command -q dircolors
    set -l dcfile "$__fish_config_dir/.dircolors"
    path is -f -- "$dcfile"; or dircolors -p >"$dcfile"

    set -l cache "$XDG_CACHE_HOME/dircolors/"(path mtime -- "$dcfile")".fish"

    if not path is -f -- "$cache"
        mkdir -p (path dirname -- "$cache")
        echo "set -gx LS_COLORS "(string escape -- (dircolors -b "$dcfile" | head -n1 | string replace -r "^LS_COLORS='" "" | string replace -r "';?\$" "")) >"$cache.tmp$fish_pid"
        and mv -f "$cache.tmp$fish_pid" "$cache"
        or rm -f "$cache.tmp$fish_pid"
    end

    path is -f -- "$cache"; and source "$cache"
end

__cached_init iris init fish
__cached_init pay-respects fish --alias f
__cached_init zoxide init fish --cmd cd
__cached_init direnv hook fish
__cached_init phpenv init - fish
