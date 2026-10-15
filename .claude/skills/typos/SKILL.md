---
name: typos
description: Spellcheck comments, docs, strings, and identifiers; --fix applies safe corrections, allowlisting domain terms
argument-hint: [--fix] [path]
allowed-tools: Bash(typos*), Bash(codespell*), Bash(rg*), Bash(git*), Read, Edit, Glob, Bash(~/.claude/skills/typos/scripts/*)
---

Catch spelling mistakes across the codebase, in comments, docs, string literals, and identifiers.
In report mode, list them with the suggested correction. With `--fix`, apply the safe ones and
allowlist the false positives.

Argument (`$ARGUMENTS`):
- **no argument** → report only.
- **`--fix`** (or `fix`) → apply corrections.
- an optional **path** → limit the scan to that path (default: whole repo).
- **Flag forms**, all equivalent: `--fix` = `-fix` = `-f` = bare `fix`.

Separately, I may include **other requests** in the same message; those are not arguments, so do
them first, then run this.

Follow exactly these steps:

## 0. Handle any extra requests first
- If I asked for other changes in the same message (before or after `/typos`), do those and get them
  working before running this.

## 1. Determine mode and scope
- Parse the argument into **report** (default) vs **fix**, plus an optional path (default: repo).

## 2. Run the scan

```
~/.claude/skills/typos/scripts/scan.sh [path]
→ {"runner": "typos|codespell|uvx typos", "path", "count",
   "configs": {"typos": [files], "codespell": [files]},
   "findings": [{"file", "line", "column", "word", "corrections": […], "text"}]}
```

It picks **`typos`** (typos-cli: fast, code-aware, understands identifiers/camelCase), else
**`codespell`**, else a pinned `uvx typos`; respects `.gitignore`. `line`/`column` are 1-based
(`null` for a typo in a file name); `text` is the source line. `configs` lists the allowlist files
already present (`_typos.toml`/`.typos.toml`/`typos.toml`, `[tool.typos]`; `.codespellrc`,
`[codespell]`). Exit `0` clean, `1` findings, `2` error with `{"error", "detail"}` on stdout (e.g.
no spellchecker and `uvx` broken): tell me what's missing.

## 3. Report
- List findings grouped by file: `file:line`, the flagged word, and the suggested correction. Use
  `text` to say whether the word sits in a **comment/doc/string** or an **identifier**; the latter
  is riskier to change.
- If report-only, stop here.

## 4. Fix mode: correct carefully
Only when `--fix` was given (per my `~/.claude/rules/git-conventions.md`, create a new branch first if I'm on a protected
branch: `main`/`master`/`dev`/`develop`/`pre-homolog`):
- **Safe to auto-apply**: typos in comments, docs, and string literals. Apply them with targeted
  edits (`typos --write-changes` only when the runner is `typos` and every finding in scope is
  safe).
- **Riskier, so confirm first**: a misspelled **identifier** (variable/function/type/API name) is only
  safe to rename if every reference changes together and it isn't a public/serialized name. Show me
  these before touching them; don't blindly rename.
- **Genuine domain terms / acronyms / names** flagged as typos are false positives, so **add them to
  the allowlist** instead of "correcting" them: the `_typos.toml` from `configs` (create one at the
  repo root if there's none), under `[default.extend-words]` as `term = "term"`; for codespell, its
  ignore-words list.

## 5. Verify and report
- Rerun the scan: only the findings you deliberately left should remain.
- After fixing, run the build/tests. A bad identifier "correction" can break code, so confirm it
  still compiles and passes.
- Summarize: corrections applied, terms allowlisted, and anything left for me to decide.
