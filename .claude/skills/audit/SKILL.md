---
name: audit
description: Scan the repo for leaked secrets (working tree, --staged, or full --history) plus a dependency/misconfig pass; findings always redacted
argument-hint: [path | --staged | --history]
allowed-tools: Bash(~/.claude/skills/audit/scripts/*), Bash(gitleaks*), Bash(trufflehog*), Bash(trivy*), Bash(git*), Bash(cargo*), Bash(npm*), Bash(rg*), Grep, Glob, Read
---

Audit this repository for **leaked secrets and sensitive information**: passwords, API keys, tokens,
private keys, `.env` files, and anything that shouldn't be exposed. That is the primary purpose of
this command. A lighter dependency/misconfiguration vulnerability pass is secondary.

Optional argument (`$ARGUMENTS`): a path to scan, or a scope flag:
- no argument → scan the current repo's working tree.
- `<path>` → scan that path.
- `--staged` → scan only staged changes (use as a pre-commit gate).
- `--history` → include the full git history (secrets often survive in old commits even after being
  removed from HEAD).
- **Flag forms**, all equivalent: `--staged` = `-staged` = `-s`, `--history` = `-history` = `-h`.

Separately, I may include **other requests** in the same message; those are not arguments, so do
them first, then run the audit.

## Non-negotiable guardrails
- **Never read or scan `$HOME/.config/zsh/secrets`** (per my `CLAUDE.md`). The script keeps every
  scanner out of it (and refuses a path inside it); never open a file inside it yourself.
- **Never print a found secret's value in plaintext.** Echoing it re-leaks it into the terminal and
  shell history. Report only the **type**, **`file:line`** and the script's masked preview (first/last
  4 chars, rest `•`); never quote a value from a flagged file. If in doubt, redact more.

Follow exactly these steps:

## 0. Handle any extra requests first
- If I asked for other changes in the same message (before or after `/audit`), carry those out and
  get them working before auditing.

## 1. Run the scan
```
~/.claude/skills/audit/scripts/scan.sh [path | --staged | --history] [--vuln]
```
- Pass the scope argument through (same flag forms); add `--vuln` when the repo has lockfiles,
  Dockerfiles or IaC (step 2). `--history` covers the working tree too.
- Scanner per scope: `gitleaks` > `trufflehog` > `trivy fs --scanners secret` > a heuristic (`rg`,
  or `git log -p`/`git diff`, for AWS keys, private-key headers, GitHub/GitLab tokens, JWTs,
  `password=`/`token=`/`secret=` assignments); trivy can't read history. trivy and trufflehog lack
  a generic assignment rule, so the heuristic's assignment rule runs on top of them
  (`scanners.<scope>` reads e.g. `trivy+assignments`). `.gitignore`d files are skipped (an ignored
  `.env` isn't a leak; a tracked one is).
- It also lists sensitive files that shouldn't be in git (`.env`, `*.pem`, `*.key`, `id_rsa*`,
  `*credentials*.json`, service-account JSONs, `*.p12`): tracked, staged (`--staged`), or only in
  old commits (`--history`).
- stdout JSON: `{mode, target, repo, scanners, heuristic, findings: [{type, rule, severity, file,
  line, preview, where, commit, scanner}], sensitive_files: [{path, where}], vuln, summary}`,
  findings sorted by severity, then `history` > `staged` > `worktree`; `file` is repo-relative.
- Exit `0` clean, `1` secrets or sensitive files found, `2` usage/environment error (not a repo
  for `--staged`/`--history`, bad path, scanner crash; stderr is masked too).
- If `heuristic` is true, say clearly that this fallback is weaker (regexes, no verification, more
  false positives) and that installing gitleaks would improve it.

## 2. Vulnerability pass (secondary)
Only if it applies to the repo, and keep it brief. `vuln` has one entry per tool (`trivy fs
--scanners vuln,misconfig`, `npm audit` with a `package-lock.json`, `cargo audit` with a
`Cargo.lock`): `ok` with severity counts and the top 10 items, `skipped` with a reason, or `error`.

## 3. Report, redacted
- List **leaked secrets first**, most severe first. For each: type, `file:line`, masked preview, and
  **working tree** vs **git history** (history = higher urgency, name the commit; a secret removed
  from HEAD is still recoverable and must be treated as leaked).
- Discount obvious false positives (docs example keys, test fixtures) out loud, never silently.
- Then the sensitive-files list, then any vulnerability findings.
- If nothing is found, say so plainly and note which scanners ran.

## 4. Remediation guidance
For every real secret found:
- **Treat it as compromised and recommend rotating/revoking it immediately**, regardless of removal.
- Remove it from tracking and history: `git rm --cached`, add the pattern to `.gitignore`, and for
  history use `git filter-repo` or BFG. **Do not rewrite history automatically**; it's destructive,
  so only do it after my explicit confirmation.
- Prefer moving the value to **runtime retrieval** (fetch from `gh`/keyring/secret manager at
  runtime) instead of any plaintext config, which matches how I like to handle secrets.
- You may apply the safe, non-destructive fixes for me (untrack + `.gitignore`) after showing the
  plan; leave rotation and history rewriting for me to confirm.

## 5. Summary
- End with a one-line verdict: **clean**, or **N secret(s) + M vulnerability finding(s)**, plus the
  single most urgent action to take next.
