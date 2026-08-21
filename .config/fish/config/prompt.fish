#!/usr/bin/env fish
# ~/.config/fish/config/prompt.fish
#
# oh-my-posh, sharing the my_amro_colors theme with zsh.

if not command -q oh-my-posh
    return
end

set -l omp_root "$HOME/.config/ohmyposh/my_amro_colors"

# First match wins: the fish-specific theme, then the shell-agnostic one, then
# zsh's copy as a last resort
for candidate in \
    "$omp_root/fish/my_amro_colors_2.toml" \
    "$omp_root/general/my_amro_colors_1.toml" \
    "$omp_root/zsh/my_amro_colors_2.toml"

    if test -f "$candidate"
        oh-my-posh init fish --config "$candidate" | source
        return
    end
end
