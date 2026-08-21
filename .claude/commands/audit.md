---
description: Scan the repo for leaked secrets (working tree, --staged, or full --history) plus a dependency/misconfig pass; findings always redacted
argument-hint: [path | --staged | --history]
allowed-tools: Bash(gitleaks*), Bash(trufflehog*), Bash(trivy*), Bash(git*), Bash(cargo*), Bash(npm*), Bash(rg*), Grep, Glob, Read
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
- **Never read or scan `$HOME/.config/zsh/secrets`** (per my `CLAUDE.md`). Exclude that directory
  explicitly from every tool invocation and never open a file inside it.
- **Never print a found secret's value in plaintext.** Echoing it re-leaks it into the terminal and
  shell history. Report only: the secret **type**, the **`file:line`**, and a **masked preview**
  (e.g. first/last 4 chars, rest as `•`). If in doubt, redact more.

Follow exactly these steps:

## 0. Handle any extra requests first
- If I asked for other changes in the same message (before or after `/audit`), carry those out and
  get them working before auditing.

## 1. Determine the scope
- Resolve the argument into one of: working tree (default), a specific path, staged changes
  (`git diff --cached`), or full history (`--history`).
- Confirm you're inside a git repo (`git rev-parse --is-inside-work-tree`); if not, scan the given
  path as a plain directory.

## 2. Pick the best available scanner
Detect which tools are installed and prefer the most specialized (report which you used):
- `gitleaks` is best for secrets, and the only one that scans full git **history** well
  (`gitleaks detect` for history, `gitleaks dir` / `--no-git` for the working tree).
- `trufflehog` is good for **verified** secrets (`trufflehog filesystem <path>` or
  `trufflehog git file://.`).
- `trivy fs --scanners secret`: I already use trivy elsewhere; solid fallback for secrets.
- If none is installed, fall back to `rg`/`grep` heuristics for common patterns: AWS keys
  (`AKIA…`), private-key headers (`-----BEGIN … PRIVATE KEY-----`), `password=`/`token=`/`secret=`
  assignments, JWTs, and high-entropy strings. Say clearly that this fallback is weaker.

## 3. Secret scan (primary)
- Run the chosen scanner over the resolved scope, excluding the guardrail directory above.
- Also flag **sensitive files that are tracked but probably shouldn't be**, via `git ls-files`:
  `.env`, `*.pem`, `*.key`, `id_rsa*`, `*credentials*.json`, service-account JSONs, `*.p12`.
- For `--history`, scan the full history. A secret removed from HEAD is still recoverable from old
  commits and must be treated as leaked.

## 4. Vulnerability pass (secondary)
Only if it applies to the repo, and keep it brief:
- `trivy fs --scanners vuln,misconfig <path>` for dependency CVEs and misconfigurations.
- `cargo audit` for Rust, `npm audit` for Node, whichever lockfiles exist.

## 5. Report, redacted
- List **leaked secrets first**, most severe first. For each: type, `file:line`, masked preview, and
  whether it lives in the **working tree** vs **git history** (history = higher urgency).
- Then the tracked-sensitive-files list, then any vulnerability findings.
- If nothing is found, say so plainly and note which scanners ran.

## 6. Remediation guidance
For every real secret found:
- **Treat it as compromised and recommend rotating/revoking it immediately**, regardless of removal.
- Remove it from tracking and history: `git rm --cached`, add the pattern to `.gitignore`, and for
  history use `git filter-repo` or BFG. **Do not rewrite history automatically**; it's destructive,
  so only do it after my explicit confirmation.
- Prefer moving the value to **runtime retrieval** (fetch from `gh`/keyring/secret manager at
  runtime) instead of any plaintext config, which matches how I like to handle secrets.
- You may apply the safe, non-destructive fixes for me (untrack + `.gitignore`) after showing the
  plan; leave rotation and history rewriting for me to confirm.

## 7. Summary
- End with a one-line verdict: **clean**, or **N secret(s) + M vulnerability finding(s)**, plus the
  single most urgent action to take next.
