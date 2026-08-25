function ccb --wraps claude
    if not command -q claude
        echo "claude is not installed" >&2
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

    # Default Claude Code model picker (no gateway discovery), but every tier is
    # overridden to omniroute's own claude ("cc" provider) models.
    set -q CCB_OPUS_MODEL; or set -l CCB_OPUS_MODEL claude-opus-5
    set -q CCB_SONNET_MODEL; or set -l CCB_SONNET_MODEL claude-sonnet-5
    set -q CCB_HAIKU_MODEL; or set -l CCB_HAIKU_MODEL claude-haiku-4-5-20251001

    CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY=0 \
        ANTHROPIC_BASE_URL="http://localhost:20128" \
        ANTHROPIC_AUTH_TOKEN="$token_key" \
        ANTHROPIC_DEFAULT_OPUS_MODEL="$CCB_OPUS_MODEL" \
        ANTHROPIC_DEFAULT_SONNET_MODEL="$CCB_SONNET_MODEL" \
        ANTHROPIC_DEFAULT_HAIKU_MODEL="$CCB_HAIKU_MODEL" \
        ANTHROPIC_SMALL_FAST_MODEL="$CCB_HAIKU_MODEL" \
        command claude $argv
end
