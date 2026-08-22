#!/usr/bin/env fish

if not command -q pkgfile
    return
end

function fish_command_not_found
    set -l pkgs (pkgfile --binaries --verbose -- $argv[1] 2>/dev/null)

    if test -n "$pkgs"
        printf '%s: not installed, provided by:\n' $argv[1]
        printf '  %s\n' $pkgs
        return
    end

    if functions -q __pr_base
        eval (__pr_base cnf "$argv")
        return
    end

    __fish_default_command_not_found_handler $argv
end
