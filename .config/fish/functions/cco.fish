function cco --wraps openclaude
    if not command -q openclaude
        echo "openclaude is not installed" >&2
        return 1
    end

    set -l key_file "$__fish_config_dir/secrets/omniroute-claude-key"
    if not path is -rf -- "$key_file"
        set key_file "$HOME/.config/zsh/secrets/omniroute-claude-key"
    end

    if not path is -rf -- "$key_file"
        echo "❌ omniroute key not readable: $key_file" >&2
        return 1
    end

    set -l token_key (cat "$key_file")

    if not __omniroute_up
        __omniroute_start; or return 1

        if not __omniroute_wait
            echo "❌ omniroute gateway did not come up on :20128" >&2
            __omniroute_dump_log
            return 1
        end

        test -n "$__omniroute_log"; and rm -f "$__omniroute_log"
    end

    CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY=1 \
        ANTHROPIC_BASE_URL="http://localhost:20128" \
        ANTHROPIC_AUTH_TOKEN="$token_key" \
        command openclaude $argv
end
