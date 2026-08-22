#!/usr/bin/env fish

function __cached_init
    set -l bin (command -v -- $argv[1])
    test -n "$bin"; or return

    set -l key $bin (path mtime -- $bin) $argv[2..]

    for arg in $argv[2..]
        path is -f -- "$arg"; and set -a key (path mtime -- "$arg")
    end

    set -l slug (string join -- : $key | string replace -ra '[^A-Za-z0-9._-]' _)
    set -l cache "$XDG_CACHE_HOME/fish-init/$slug.fish"

    if not path is -f -- "$cache"
        mkdir -p (path dirname -- "$cache")
        command $argv >"$cache.tmp$fish_pid"
        and mv -f "$cache.tmp$fish_pid" "$cache"
        or rm -f "$cache.tmp$fish_pid"
    end

    path is -f -- "$cache"; and source "$cache"
end
