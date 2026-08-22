#!/usr/bin/env fish

# --------------- Completions Directories ---------------

set -l completions_dir "$__fish_config_dir/completions"
set -l generated_dir "$completions_dir/generated"
set -l manual_dir "$completions_dir/manual"

mkdir -p "$completions_dir" "$generated_dir" "$manual_dir"

# ---------------- Generated Completions ----------------

# bootdev completions
if command -q bootdev; and not path is -f -- "$generated_dir/bootdev.fish"
    bootdev completion fish >"$generated_dir/bootdev.fish"
end

# eww completions
if command -q eww; and not path is -f -- "$generated_dir/eww.fish"
    eww shell-completions --shell fish >"$generated_dir/eww.fish"
end

# mdcat completions
if command -q mdcat; and not path is -f -- "$generated_dir/mdcat.fish"
    mdcat --completions fish >"$generated_dir/mdcat.fish"
end

# git-bug completions
if command -q git-bug; and not path is -f -- "$generated_dir/git-bug.fish"
    git-bug completion fish >"$generated_dir/git-bug.fish"
end

# aws completions
if command -q aws_completer; and not path is -f -- "$generated_dir/aws.fish"
    echo 'complete -c aws -f -a "(begin; set -lx COMP_SHELL fish; set -lx COMP_LINE (commandline); aws_completer | string trim; end)"' >"$generated_dir/aws.fish"
end

# claude completions
if command -q claude; and not path is -f -- "$generated_dir/claude.fish"
    update_claude_completions
end

# -------------------------------------------------------

set -gp fish_complete_path "$manual_dir" "$generated_dir"
