#!/usr/bin/env fish

if not command -q oh-my-posh
    return
end

set -l omp_root "$HOME/.config/ohmyposh/my_amro_colors"

for candidate in \
    "$omp_root/fish/my_amro_colors_2.toml" \
    "$omp_root/general/my_amro_colors_1.toml" \
    "$omp_root/zsh/my_amro_colors_2.toml"

    path is -f -- "$candidate"; or continue

    __cached_init oh-my-posh init fish --config "$candidate"
    return
end
