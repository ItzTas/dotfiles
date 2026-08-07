---
description: Spellcheck comments, docs, strings, and identifiers; --fix applies safe corrections, allowlisting domain terms
argument-hint: [--fix] [path]
allowed-tools: Bash(typos*), Bash(codespell*), Bash(rg*), Bash(git*), Read, Edit, Glob
---

Catch spelling mistakes across the codebase — in comments, docs, string literals, and identifiers.
In report mode, list them with the suggested correction. With `--fix`, apply the safe ones and
allowlist the false positives.

Argument (`$ARGUMENTS`):
- **no argument** → report only.
- **`--fix`** (or `fix`) → apply corrections.
- an optional **path** → limit the scan to that path (default: whole repo).

Separately, I may include **other requests** in the same message; those are not arguments — do them
first, then run this.

Follow exactly these steps:

## 0. Handle any extra requests first
- If I asked for other changes in the same message (before or after `/typos`), do those and get them
  working before running this.

## 1. Determine mode and scope
- Parse the argument into **report** (default) vs **fix**, plus an optional path (default: repo).

## 2. Pick the spellchecker
- Prefer **`typos`** (typos-cli) — fast and code-aware (understands identifiers/camelCase). Fall back
  to **`codespell`** if `typos` isn't installed.
- Note the config file for allowlisting: `typos` reads `_typos.toml`/`.typos.toml`; `codespell` uses
  an ignore list. Skip vendored/generated dirs; both respect `.gitignore` by default.

## 3. Run the scan and report
- Run over the scope and list findings grouped by file: `file:line`, the flagged word, and the
  suggested correction. Note when a word is in a **comment/doc/string** vs an **identifier** — the
  latter is riskier to change.
- If report-only, stop here.

## 4. Fix mode — correct carefully
Only when `--fix` was given (per my `~/.claude/rules/git-conventions.md`, create a new branch first if I'm on a protected
branch: `main`/`master`/`dev`/`develop`/`pre-homolog`):
- **Safe to auto-apply**: typos in comments, docs, and string literals — apply them (`typos
  --write-changes` or targeted edits).
- **Riskier — confirm first**: a misspelled **identifier** (variable/function/type/API name) is only
  safe to rename if every reference changes together and it isn't a public/serialized name. Show me
  these before touching them; don't blindly rename.
- **Genuine domain terms / acronyms / names** flagged as typos are false positives — **add them to
  the `_typos.toml` allowlist** instead of "correcting" them.

## 5. Verify and report
- After fixing, run the build/tests — a bad identifier "correction" can break code, so confirm it
  still compiles and passes.
- Summarize: corrections applied, terms allowlisted, and anything left for me to decide.
