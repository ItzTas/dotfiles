---
description: Find sensitive files with loose permissions (keys, .env, credentials) and report current vs recommended mode — metadata only
argument-hint: [path]
allowed-tools: Bash(find*), Bash(stat*), Bash(ls*), Bash(git*), Bash(chmod*), Glob
---

Check a directory tree for files whose **permissions are too loose** — private keys, `.env` files,
credentials, and other secrets that are readable or writable by group/other, or writable by anyone.
Report what's wrong and how to fix it.

Optional argument (`$ARGUMENTS`): a path to scan (default: the current directory / repo root).

Separately, I may include **other requests** in the same message; those are not arguments — do them
first, then scan.

## Non-negotiable guardrails
- This command inspects **permissions only** — metadata via `stat`, `ls -l`, `find`. **Never open or
  read the contents** of any file it examines.
- **Never scan, list, or touch `$HOME/.config/zsh/secrets`** (per my `CLAUDE.md`). Exclude that path
  entirely from every command.

Follow exactly these steps:

## 0. Handle any extra requests first
- If I asked for other changes in the same message (before or after `/perms-check`), carry those out
  and get them working before scanning.

## 1. Determine the scope
- Resolve the argument to a path (default: current dir / repo root). Prune the guardrail directory
  above from every `find` (e.g. `-path "$HOME/.config/zsh/secrets" -prune`).

## 2. Define what counts as sensitive
Treat these as secrets that must not be group/other readable:
- Private keys: `id_rsa*`, `id_ed25519*`, `*.pem`, `*.key`, `*.p12`, `*.pfx`, `*.gpg`.
- Credential/config files: `.env`, `.env.*`, `*credentials*`, `.netrc`, `.pgpass`, `.npmrc`,
  `.git-credentials`, service-account JSONs.
- Sensitive dirs: `.ssh` (should be `700`), `.gnupg` (should be `700`).

## 3. Run the checks (metadata only)
- **World/group writable** — anything writable by group or other: `find <scope> -type f \( -perm -g+w -o -perm -o+w \)`.
- **Over-exposed secrets** — sensitive files (step 2) readable by group or other; they should be `600`
  (or `400` for keys). Use `stat -c '%a %n'` to read the mode.
- **Private keys** not `600`/`400`, and `.ssh`/`.gnupg` dirs not `700`.
- If inside a git repo, note any of these that are also **tracked** (`git ls-files`) — tracked
  secrets are a double problem (see `/audit`).

## 4. Report — current vs recommended
- List each issue as: `path` · current mode · **recommended** mode · why it matters. Most dangerous
  first (world-writable, then exposed private keys, then other readable secrets).
- **Never print file contents** — only paths and modes.
- If everything is tight, say so plainly.

## 5. Remediation
- Give the exact `chmod` for each fix (`600` for secret files, `400` for keys, `700` for `.ssh`/`.gnupg`).
- You may **apply the fixes for me after showing the plan and getting my confirmation** — never
  `chmod` automatically without asking.
- End with a one-line verdict: clean, or N issue(s) and the single most urgent one.
