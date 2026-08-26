#!/usr/bin/env bash

set -euo pipefail

here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
tarball="https://codeload.github.com/cursor/plugins/tar.gz/refs/heads/main"
staging=$(mktemp -d)
trap 'rm -rf "$staging"' EXIT

echo "Downloading pstack from cursor/plugins…"
curl -fsSL "$tarball" | tar xz -C "$staging" --strip-components=1 --wildcards '*/pstack/*'

rm -rf "$staging/pstack/docs/guide/images"

cp "$here/pstack/.claude-plugin/plugin.json" "$staging/plugin.json.keep"
rm -rf "$here/pstack"
mv "$staging/pstack" "$here/pstack"
mkdir -p "$here/pstack/.claude-plugin"
mv "$staging/plugin.json.keep" "$here/pstack/.claude-plugin/plugin.json"

echo "Updated. Now run:"
echo "  claude plugin marketplace update cursor-plugins"
