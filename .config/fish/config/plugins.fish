#!/usr/bin/env fish
# ~/.config/fish/config/plugins.fish
#
# The settings zsh keeps in plugins/*/settings. No plugin manager here: fish
# ships autosuggestions, syntax highlighting, vi mode and history search built
# in, so only their configuration is left.

# Syntax highlighting palette
source "$__fish_config_dir/themes/catppuccin-mocha.fish"

# Autosuggestions: dimmed enough to read as a suggestion, not as input
set -g fish_color_autosuggestion 8c8caa

# History search matches and visual-mode selection
set -g fish_color_search_match --background=45475a
set -g fish_color_selection cdd6f4 --bold --background=45475a

# Vi mode. The bindings themselves live in binds.fish, which
# functions/fish_user_key_bindings.fish sources on every mode change
set -g fish_key_bindings fish_vi_key_bindings

# Cursor shape per vi mode
set -g fish_cursor_default block
set -g fish_cursor_insert line
set -g fish_cursor_replace_one underscore
set -g fish_cursor_visual block
