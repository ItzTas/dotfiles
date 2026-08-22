#!/usr/bin/env fish

if not command -q proto
    return
end

set -g __proto_bin (command -v proto)
set -g __proto_cache_dir "$XDG_CACHE_HOME/proto-activate"

function __proto_cache_key
    set -l parts (path mtime -- $__proto_bin)
    set -l dir $PWD

    while true
        test -f "$dir/.prototools"
        and set -a parts "$dir/.prototools" (path mtime -- "$dir/.prototools")

        test "$dir" = /; and break
        set dir (path dirname -- $dir)
    end

    string join -- : $parts | string replace -ra '[^A-Za-z0-9._-]' _
end

function __proto_apply
    set -l key (__proto_cache_key)
    test "$key" = "$__proto_last_key"; and return
    set -g __proto_last_key $key

    set -l cache "$__proto_cache_dir/$key.fish"

    if not test -f "$cache"
        mkdir -p "$__proto_cache_dir"
        proto activate fish --export >"$cache.tmp$fish_pid"
        and mv -f "$cache.tmp$fish_pid" "$cache"
        or rm -f "$cache.tmp$fish_pid"
    end

    test -f "$cache"; and source "$cache"
end

set -gx __ORIG_PATH $PATH

function _proto_activate_hook --on-variable PWD
    __proto_apply
end

__proto_apply
