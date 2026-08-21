#!/usr/bin/env fish
# ~/.config/fish/config/sources.fish
#
# Environment files shipped by other tools.

# Recent rustup writes a fish-native env file; older layouts only leave the
# bin directory behind, so add it by hand
if command -q cargo
    if test -f "$HOME/.cargo/env.fish"
        source "$HOME/.cargo/env.fish"
    else if test -d "$HOME/.cargo/bin"
        fish_add_path -g -p "$HOME/.cargo/bin"
    end
end
