#!/bin/env bash

_remove() {
    local icons_dir breeze_dir breeze_dark_dir papirus_dir

    icons_dir="/usr/share/icons"
    breeze_dir="$icons_dir/breeze"
    breeze_dark_dir="$icons_dir/breeze-dark"
    papirus_dir="$icons_dir/Papirus"

    sudo rm -rf "$breeze_dir" "$breeze_dark_dir" "$papirus_dir"
}

# _remove
