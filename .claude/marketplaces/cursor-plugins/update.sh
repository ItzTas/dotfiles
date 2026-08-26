#!/usr/bin/env bash

set -euo pipefail

KEEP_SKILLS=(unslop)

here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
tarball="https://codeload.github.com/cursor/plugins/tar.gz/refs/heads/main"
staging=$(mktemp -d)
trap 'rm -rf "$staging"' EXIT

echo "Downloading pstack from cursor/plugins…"
curl -fsSL "$tarball" | tar xz -C "$staging" --strip-components=1 --wildcards '*/pstack/*'

src="$staging/pstack"
rm -rf "$src/agents" "$src/automations" "$src/docs" "$src/README.md"

for skill in "$src"/skills/*/; do
	name=$(basename "$skill")
	keep=no
	for wanted in "${KEEP_SKILLS[@]}"; do
		[ "$name" = "$wanted" ] && keep=yes
	done
	[ "$keep" = yes ] || rm -rf "$skill"
done

for wanted in "${KEEP_SKILLS[@]}"; do
	if [ ! -f "$src/skills/$wanted/SKILL.md" ]; then
		echo "error: upstream no longer ships skill '$wanted'" >&2
		exit 1
	fi
done

cp "$here/pstack/.claude-plugin/plugin.json" "$staging/plugin.json.keep"
rm -rf "$here/pstack"
mv "$src" "$here/pstack"
mkdir -p "$here/pstack/.claude-plugin"
mv "$staging/plugin.json.keep" "$here/pstack/.claude-plugin/plugin.json"

echo "Kept: ${KEEP_SKILLS[*]}"
echo "Updated. Now run:"
echo "  claude plugin marketplace update cursor-plugins"
