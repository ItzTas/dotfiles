#!/usr/bin/env bash
# Refresh the pstack plugin from upstream cursor/plugins.
#
# This marketplace is a local bridge: upstream ships .cursor-plugin/marketplace.json,
# which Claude Code does not read, so the .claude-plugin manifests here are written by
# hand and must survive the refresh. There is no nested git clone (an embedded repo
# confuses yadm), so updating means re-downloading the subtree.

set -euo pipefail

here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
tarball="https://codeload.github.com/cursor/plugins/tar.gz/refs/heads/main"
staging=$(mktemp -d)
trap 'rm -rf "$staging"' EXIT

echo "Downloading pstack from cursor/plugins…"
curl -fsSL "$tarball" | tar xz -C "$staging" --strip-components=1 --wildcards '*/pstack/*'

# Doc images are ~2.2MB of JPEGs that only matter on GitHub; they stay out of the repo.
rm -rf "$staging/pstack/docs/guide/images"

# The hand-written Claude manifest is not upstream, so carry it across the swap.
cp "$here/pstack/.claude-plugin/plugin.json" "$staging/plugin.json.keep"
rm -rf "$here/pstack"
mv "$staging/pstack" "$here/pstack"
mkdir -p "$here/pstack/.claude-plugin"
mv "$staging/plugin.json.keep" "$here/pstack/.claude-plugin/plugin.json"

echo "Updated. Now run:"
echo "  claude plugin marketplace update cursor-plugins"
