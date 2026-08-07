#!/bin/bash
# Register the .claude/settings.json merge driver in this machine's yadm repo.
#
# .gitattributes is tracked and travels with the repo, but the driver command
# itself lives in the local repo config, so every machine has to register it
# once. Running this from bootstrap keeps the notebook in sync with the desktop.

set -euo pipefail

driver="$HOME/.local/bin/claude-settings-merge"

if [[ ! -x "$driver" ]]; then
    echo "[claude-settings-merge] $driver missing or not executable, skipping" >&2
    exit 0
fi

yadm gitconfig merge.claude-settings.name \
    "Claude Code settings merge (neutralises model/effortLevel churn)"
yadm gitconfig merge.claude-settings.driver \
    "$driver %O %A %B %L %P"

echo "[claude-settings-merge] merge driver registered"
