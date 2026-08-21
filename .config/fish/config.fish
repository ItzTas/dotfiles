#!/usr/bin/env fish
# ~/.config/fish/config.fish
#
# Entry point for interactive shells. Anything not specific to this file lives
# in config/ and is sourced by the loops below; environment and PATH setup that
# must reach non-interactive shells too lives in conf.d/, which fish sources on
# its own before this file.

# If not running interactively, don't do anything
if ! status is-interactive
    return
end

# Free Ctrl-Z: the terminal's suspend character shadows the key binding
stty susp undef

# --------------------- Prompt ---------------------

# Load the prompt before everything else, so a slow init further down never
# leaves the shell promptless
source "$__fish_config_dir/config/prompt.fish"

# --------------------- Plugins ---------------------

# What zsh needs antidote and five plugins for (autosuggestions, syntax
# highlighting, vi mode, abbreviations, history search) fish ships built in, so
# there is no plugin manager here: only the settings those plugins would carry
source "$__fish_config_dir/config/plugins.fish"

# ---------------------------------------------------

# config/binds.fish is deliberately absent from this list: fish re-runs
# fish_user_key_bindings on every mode change, and that function sources it
function __source_fish_config_files
    set -l files \
        envs \
        aliases \
        abbreviations \
        completions \
        sources \
        setopt \
        fzf \
        evals \
        pager

    for file in $files
        set -l config_file "$__fish_config_dir/config/$file.fish"
        test -f "$config_file"; and source "$config_file"
    end
end

__source_fish_config_files
functions --erase __source_fish_config_files

# Untracked files holding credentials, absent on a fresh clone
function __source_fish_secrets
    set -l files tokens

    for file in $files
        set -l secret_file "$__fish_config_dir/secrets/$file.fish"
        test -f "$secret_file"; and source "$secret_file"
    end
end

__source_fish_secrets
functions --erase __source_fish_secrets

# -------------------- Main file specifics --------------------

# Read by functions/nvm.fish, which loads nvm itself on first use
set -gx NVM_DIR "$HOME/.config/nvm"

# proto activation needs to be on main file
if command -q proto
    proto activate fish | source
end

# -------------------------------------------------------------
