#!/usr/bin/env fish

if ! status is-interactive
    return
end

stty susp undef

# --------------------- Prompt ---------------------

source "$__fish_config_dir/config/prompt.fish"

# ---------------------------------------------------

function __source_fish_config_files
    set -l files \
        plugins \
        envs \
        aliases \
        abbr \
        completions \
        sources \
        setopt \
        fzf \
        pager

    for file in $files
        set -l config_file "$__fish_config_dir/config/$file.fish"
        test -f "$config_file"; and source "$config_file"
    end
end

__source_fish_config_files
functions --erase __source_fish_config_files

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

# nvm
set -gx NVM_DIR "$HOME/.config/nvm"

# proto
source "$__fish_config_dir/config/proto.fish"

# -------------------------------------------------------------
