#!/usr/bin/env bash
#
# PostToolUse hook — lint Dockerfiles after Write/Edit/MultiEdit.
#
# Claude Code pipes the tool payload (JSON) to this script on stdin. When the
# edited file is a Dockerfile, hadolint and trivy are run against it. Any
# findings are printed to stderr and the script exits 2, which feeds the output
# back to Claude Code so the issues can be fixed. Linters that aren't installed
# are skipped, so the hook is a harmless no-op until they are present.

# jq is needed to read the payload; without it there is nothing to do.
command -v jq >/dev/null 2>&1 || exit 0

file=$(jq -r '.tool_input.file_path // empty')
[ -n "$file" ] || exit 0

# Only Dockerfiles are linted.
case "$(basename "$file")" in
    Dockerfile | Dockerfile.* | *.Dockerfile | Containerfile | containerfile) ;;
    *) exit 0 ;;
esac

status=0

if command -v hadolint >/dev/null 2>&1; then
    if ! report=$(hadolint "$file" 2>&1); then
        printf 'hadolint reported issues in %s:\n%s\n' "$file" "$report" >&2
        status=2
    fi
fi

if command -v trivy >/dev/null 2>&1; then
    if ! report=$(trivy config --quiet --exit-code 1 "$file" 2>&1); then
        printf 'trivy config reported issues in %s:\n%s\n' "$file" "$report" >&2
        status=2
    fi
fi

exit "$status"
