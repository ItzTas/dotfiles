---
name: dupes
description: Find duplicated-code clusters; optionally refactor each into a shared abstraction, preserving behavior
argument-hint: [--fix] [path]
allowed-tools: Bash(jscpd*), Bash(npx*), Bash(rg*), Bash(git*), Read, Edit, Glob, Grep, Bash(~/.claude/skills/dupes/scripts/*)
---

Find copy-pasted / near-duplicate code across the codebase so I can DRY it up. In report mode, list
the duplicate clusters with locations. With `--fix`, refactor them into a shared abstraction,
carefully, preserving behavior.

Argument (`$ARGUMENTS`):
- **no argument** → report only.
- **`--fix`** (or `fix`) → propose and (after I confirm) apply refactors.
- an optional **path** → limit the scan to that path (default: whole repo).
- **Flag forms**, all equivalent: `--fix` = `-fix` = `-f` = bare `fix`.

Separately, I may include **other requests** in the same message; those are not arguments, so do
them first, then run this.

Follow exactly these steps:

## 0. Handle any extra requests first
- If I asked for other changes in the same message (before or after `/dupes`), do those and get them
  working before running this.

## 1. Determine mode and scope
- Parse the argument into **report** (default) vs **fix**, plus an optional path (default: repo).

## 2. Run the duplication detector

```
~/.claude/skills/dupes/scripts/scan.sh [path] [--min-lines N]
→ {"runner", "path", "min_lines", "stats": {"files", "lines", "duplicated_lines", "percentage"},
   "clusters": [{"format", "lines", "tokens", "occurrences", "impact",
                 "locations": [{"file", "start", "end"}]}]}
```

It runs **`jscpd`** (multi-language: Rust, TS/JS, Python and more; a pinned `npx jscpd` when it
isn't installed), skips `node_modules`, `target`, `dist`, `build`, `vendor`, `.git` and anything
in `.gitignore`, and merges jscpd's pairs into clusters (every place one block appears), sorted by
`impact` = lines × occurrences. The default minimum block is jscpd's 5 lines / 50 tokens; raise
`--min-lines` if trivial matches swamp the report. Exit `0` none, `1` clusters found, `2` error with
`{"error", "detail"}` on stdout.

## 3. Report the clusters
- For each duplicate cluster: the repeated block's size (lines/tokens), and **every** `file:line`
  range where it appears, biggest/most-repeated first (the script's order).
- Note likely **false positives** (generated code, intentionally-parallel test cases, boilerplate a
  framework requires) and don't push to refactor those. Some duplication is fine.
- If report-only, stop here.

## 4. Fix mode: refactor, preserving behavior
Only when `--fix` was given (per my `~/.claude/rules/git-conventions.md`, create a new branch first if I'm on a protected
branch: `main`/`master`/`dev`/`develop`/`pre-homolog`):
- For each worthwhile cluster, propose the abstraction (extract a function / shared module / generic)
  and **show me the plan before editing**.
- Apply **one cluster at a time**: extract the shared code, update every call site, and keep behavior
  identical. After each, run the build/tests before moving on. If something breaks, fix or revert
  that cluster and tell me.
- Don't over-abstract; skip clusters where a shared helper would be more confusing than the
  duplication.

## 5. Report
- Rerun the scan to confirm the refactored clusters are gone.
- Summarize: clusters found, which were refactored (and into what), and which were left as-is (with
  the reason). Leave committing to me (or `/commit`).
