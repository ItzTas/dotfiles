---
description: Install/sync the tool versions pinned in the repo's .prototools via proto
argument-hint: [tool]
allowed-tools: Bash(proto*), Read, Glob, WebFetch
---

Sync the development tools to the versions pinned in this repository using [proto](https://moonrepo.dev/proto).
Per my `CLAUDE.md`, a `.prototools` file at the repo root holds the versions of some of the tools used.

Optional argument (a single tool to target): `$ARGUMENTS`

## 0. Read proto docs for context
Before acting, fetch these pages to ground yourself on proto's behavior and flags (read only the
ones relevant to what you need):
- Overview — https://moonrepo.dev/docs/proto
- Configuration (`.prototools`) — https://moonrepo.dev/docs/proto/config
- Tool specification (version syntax) — https://moonrepo.dev/docs/proto/tool-spec
- Version detection — https://moonrepo.dev/docs/proto/detection
- `proto install` — https://moonrepo.dev/docs/proto/commands/install
- `proto status` — https://moonrepo.dev/docs/proto/commands/status
- `proto outdated` — https://moonrepo.dev/docs/proto/commands/outdated
- `proto pin` — https://moonrepo.dev/docs/proto/commands/pin

## 1. Locate and read `.prototools`
- Find the `.prototools` at the repository root (and any parent `.prototools` proto would inherit).
- Read it and note which tools/versions are pinned. If none exists, tell me and stop.

## 2. Install the pinned versions
- If an argument was given, install just that tool: `proto install <tool>`.
- Otherwise install everything configured: `proto install` (with no args installs all tools from
  the parent `.prototools` files plus any versions detected in the cwd). Note: `proto use` is the
  older alias for this — prefer `proto install`.
- Add `--force` only if I ask for a clean reinstall.

## 3. Report
- Run `proto status` to confirm the active tools and their resolved versions.
- Run `proto outdated` and summarize anything newer available than what's pinned (do **not** bump
  versions unless I ask — the pins in `.prototools` are the source of truth).
- Show me a short summary: which tools were installed and at what versions.
