#!/usr/bin/env fish

# Syntax highlighting
source "$__fish_config_dir/themes/catppuccin-mocha.fish"

# Autosuggestions
set -g fish_color_autosuggestion 8c8caa

# Search and selection
set -g fish_color_search_match --background=45475a
set -g fish_color_selection cdd6f4 --bold --background=45475a

# Vi mode
set -g fish_key_bindings fish_vi_key_bindings

# Cursor
set -g fish_cursor_default block
set -g fish_cursor_insert line
set -g fish_cursor_replace_one underscore
set -g fish_cursor_visual block
