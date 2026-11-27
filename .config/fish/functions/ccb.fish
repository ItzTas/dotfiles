function ccb --wraps claude
    if not command -q claude
        echo "claude is not installed" >&2
        return 1
    end

    set -l token_key (__omniroute_key); or return 1
    set -l base_url (__omniroute_url)

    if not __omniroute_up "$base_url"
        echo "❌ omniroute unreachable at $base_url" >&2
        return 1
    end

    # Default Claude Code model picker (no gateway discovery), but every tier is
    # overridden to omniroute's own claude ("cc" provider) models.
    set -q CCB_OPUS_MODEL; or set -l CCB_OPUS_MODEL claude-opus-5
    set -q CCB_SONNET_MODEL; or set -l CCB_SONNET_MODEL claude-sonnet-5
    set -q CCB_HAIKU_MODEL; or set -l CCB_HAIKU_MODEL claude-haiku-4-5-20251001

    CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY=0 \
        ANTHROPIC_BASE_URL="$base_url" \
        ANTHROPIC_AUTH_TOKEN="$token_key" \
        ANTHROPIC_DEFAULT_OPUS_MODEL="$CCB_OPUS_MODEL" \
        ANTHROPIC_DEFAULT_SONNET_MODEL="$CCB_SONNET_MODEL" \
        ANTHROPIC_DEFAULT_HAIKU_MODEL="$CCB_HAIKU_MODEL" \
        ANTHROPIC_SMALL_FAST_MODEL="$CCB_HAIKU_MODEL" \
        command claude $argv
end
