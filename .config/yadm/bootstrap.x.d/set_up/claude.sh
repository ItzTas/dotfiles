#!/usr/bin/env bash
# Claude Code setup that can't live in a tracked config file.
#
# - Plugins: settings.json (tracked) only declares marketplaces and enabled
#   plugins; the plugins themselves are downloaded into ~/.claude/plugins,
#   which is not tracked. Install whatever settings.json declares.
# - Skills from the `skills` CLI: their files are tracked, but the CLI's own
#   record of where each one came from is not, so `skills update` can't
#   refresh them on a fresh machine. Re-adding them restores that record.

set -euo pipefail

settings="$HOME/.claude/settings.json"
plugins_dir="$HOME/.claude/plugins"

add_marketplaces() {
    local name source
    while IFS=$'\t' read -r name source; do
        if jq -e --arg n "$name" 'has($n)' "$plugins_dir/known_marketplaces.json" >/dev/null 2>&1; then
            echo "[claude] marketplace already present: $name"
            continue
        fi
        echo "[claude] adding marketplace $name ($source)"
        claude plugin marketplace add "$source" || echo "[claude] failed to add marketplace $name" >&2
    done < <(jq -r '.extraKnownMarketplaces // {} | to_entries[]
        | [.key, (.value.source | .repo // .path // .url)] | @tsv' "$settings")
}

install_plugins() {
    local plugin
    while read -r plugin; do
        if jq -e --arg p "$plugin" '.plugins | has($p)' "$plugins_dir/installed_plugins.json" >/dev/null 2>&1; then
            echo "[claude] plugin already installed: $plugin"
            continue
        fi
        echo "[claude] installing plugin $plugin"
        claude plugin install "$plugin" || echo "[claude] failed to install $plugin" >&2
    done < <(jq -r '.enabledPlugins // {} | to_entries[] | select(.value) | .key' "$settings")
}

add_cli_skills() {
    # skill name -> repository it was installed from
    declare -A skills=(
        ["security-audit"]="https://github.com/cloudflare/security-audit-skill"
    )
    local name
    for name in "${!skills[@]}"; do
        echo "[claude] adding skill $name from ${skills[$name]}"
        npx --yes skills add "${skills[$name]}" --skill "$name" -g -a claude-code --copy -y ||
            echo "[claude] failed to add skill $name" >&2
    done
}

_set_up() {
    if ! command -v jq >/dev/null; then
        echo "[claude] jq not found, skipping" >&2
        return 0
    fi

    if command -v claude >/dev/null && [[ -f "$settings" ]]; then
        add_marketplaces
        install_plugins
    else
        echo "[claude] claude CLI or $settings missing, skipping plugins" >&2
    fi

    if ! command -v npx >/dev/null; then
        echo "[claude] npx not found, skipping skills" >&2
        return 0
    fi
    add_cli_skills
}

_set_up
