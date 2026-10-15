---
name: perms-check
description: Find sensitive files with loose permissions (keys, .env, credentials) and report current vs recommended mode, metadata only
argument-hint: [path]
allowed-tools: Bash(~/.claude/skills/perms-check/scripts/*), Bash(find*), Bash(stat*), Bash(ls*), Bash(git*), Bash(chmod*), Glob
---

Check a directory tree for files whose **permissions are too loose**: private keys, `.env` files,
credentials, and other secrets that are readable or writable by group/other, or writable by anyone.
Report what's wrong and how to fix it.

Optional argument (`$ARGUMENTS`): a path to scan (default: the current directory / repo root).

Separately, I may include **other requests** in the same message; those are not arguments, so do
them first, then scan.

## Non-negotiable guardrails
- This command inspects **permissions only**, meaning metadata via `stat`, `ls -l`, `find`. **Never
  open or read the contents** of any file it examines (the script only reads mode bits).
- **Never scan, list, or touch `$HOME/.config/zsh/secrets`** (per my `CLAUDE.md`). The script prunes
  it from every walk; exclude it from any manual command too.

Follow exactly these steps:

## 0. Handle any extra requests first
- If I asked for other changes in the same message (before or after `/perms-check`), carry those out
  and get them working before scanning.

## 1. Run the scan
```
~/.claude/skills/perms-check/scripts/perms.sh [path]
```
- `path` defaults to the repo root (else the current dir). It walks with `find` (mode bits only,
  never chmods) and flags: files writable by group/other; private keys (`id_rsa*`, `id_ed25519*`,
  `*.pem`, `*.key`, `*.p12`, `*.pfx`, `*.gpg`, not `*.pub`) that aren't `600`/`400`; credential
  files (`.env`, `.env.*` minus templates, `*credentials*` minus source files, `.netrc`, `.pgpass`,
  `.npmrc`, `.git-credentials`, service-account JSONs) accessible by group/other; `.ssh`/`.gnupg`
  dirs not `700`.
- stdout JSON: `{scope, clean, summary: {critical, high, medium, low}, issues: [{severity, type,
  path, mode, recommended, reason, tracked}], truncated?}`, most dangerous first (`critical`
  world-writable, `high` private keys and `.ssh`/`.gnupg`, `medium` other secrets, `low`
  group-writable). `path` is relative to `scope`; `tracked` is `null` outside a git work tree. At
  most 200 issues are listed; `summary` counts all.
- Exit `0` clean, `1` issues, `2` usage/environment error (bad path, scope inside the secrets dir).

## 2. Report: current vs recommended
- List each issue as: `path` · current mode · **recommended** mode · why it matters, in the script's
  order. Flag the `tracked: true` ones: tracked secrets are a double problem (see `/audit`).
- Name patterns can over-match (a public `*.pem` cert); say so when the path makes it obvious.
- **Never print file contents**, only paths and modes. If `clean` is true, say so plainly.

## 3. Remediation
- Give the exact `chmod` for each fix, from `recommended` (`600` for secret files, `400` for keys,
  `700` for `.ssh`/`.gnupg`, write bits dropped for other files).
- You may **apply the fixes for me after showing the plan and getting my confirmation**, but never
  `chmod` automatically without asking.
- End with a one-line verdict: clean, or N issue(s) and the single most urgent one.
