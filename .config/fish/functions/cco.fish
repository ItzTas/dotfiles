function cco --wraps openclaude
    if not command -q openclaude
        echo "openclaude is not installed" >&2
        return 1
    end

    set -l token_key (__omniroute_key); or return 1
    set -l base_url (__omniroute_url)

    if not __omniroute_up "$base_url"
        echo "❌ omniroute unreachable at $base_url" >&2
        return 1
    end

    CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY=1 \
        ANTHROPIC_BASE_URL="$base_url" \
        ANTHROPIC_AUTH_TOKEN="$token_key" \
        command openclaude $argv
end
