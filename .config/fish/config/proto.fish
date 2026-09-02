#!/usr/bin/env fish

if not command -q proto
    return
end

set -g __proto_bin (command -v proto)
set -g __proto_cache_dir "$XDG_CACHE_HOME/proto-activate"

function __proto_cache_id
    set -l dirs
    set -l parts (path mtime -- $__proto_bin)
    set -l dir $PWD

    while true
        if path is -f -- "$dir/.prototools"
            set -a dirs "$dir"
            set -a parts "$dir/.prototools" (path mtime -- "$dir/.prototools")

            for envfile in (string replace -rf '^\s*file\s*=\s*"?([^"]+)"?\s*$' '$1' <"$dir/.prototools")
                path is -f -- "$dir/$envfile"
                and set -a parts "$envfile" (path mtime -- "$dir/$envfile")
            end
        end

        test "$dir" = /; and break
        set dir (path dirname -- $dir)
    end

    string join -- : $__proto_bin $dirs | string replace -ra '[^A-Za-z0-9._-]' _
    string join -- : $parts
end

function __proto_apply
    set -l id (__proto_cache_id)
    set -l slug $id[1]
    set -l key $id[2]

    test "$key" = "$__proto_last_key"; and return
    set -g __proto_last_key $key

    set -l cache "$__proto_cache_dir/$slug.fish"

    set -l stamp
    path is -f -- "$cache"; and read stamp <"$cache"

    if test "$stamp" != "# $key"
        mkdir -p "$__proto_cache_dir"
        begin
            echo "# $key"
            proto activate fish --export
        end >"$cache.tmp$fish_pid"
        and mv -f "$cache.tmp$fish_pid" "$cache"
        or rm -f "$cache.tmp$fish_pid"
    end

    path is -f -- "$cache"; and source "$cache"
end

set -gx __ORIG_PATH $PATH

function _proto_activate_hook --on-variable PWD
    __proto_apply
end

__proto_apply
