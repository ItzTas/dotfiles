function fish_user_key_bindings
    fish_vi_key_bindings

    # oh-my-posh installs its own bindings the first time fish_prompt runs,
    # which is after this function; trigger that bootstrap now so binds.fish
    # keeps the last word.
    if set -q POSH_SHELL; and not functions -q _omp_ctrl_c_key_handler
        fish_prompt >/dev/null
    end

    source "$__fish_config_dir/config/binds.fish"
end
