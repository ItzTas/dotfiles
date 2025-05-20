#!/bin/env bash

get_release_profile_path() {
    local profiles_ini="$HOME/.zen/profiles.ini"
    awk '
        /^\[Profile/ {
            in_profile = 1
            path = ""
            is_release = 0
        }
        /^Name=Default \(release\)/ && in_profile {
            is_release = 1
        }
        /^Path=/ && in_profile {
            sub(/^Path=/, "", $0)
            path = $0
        }
        is_release && path {
            print path
            exit
        }
    ' "$profiles_ini"
}

create_symlinks() {
    local misc_zen_dir zen_dir profile_path

    misc_zen_dir="$HOME/.config/yadm/misc/zen-browser/symlinks"
    profile_path=$(get_release_profile_path)
    zen_dir="$HOME/.zen/$profile_path"

    echo "Symlinks will be created in: $zen_dir"

    for slink in "$misc_zen_dir"/*; do
        if [ -d "$slink" ]; then
            ln -sfd "$slink" "$zen_dir"
        fi
        ln -sf "$slink" "$zen_dir"
    done
}

create_symlinks
