---
description: Find duplicated-code clusters; optionally refactor each into a shared abstraction, preserving behavior
argument-hint: [--fix] [path]
allowed-tools: Bash(jscpd*), Bash(npx*), Bash(rg*), Bash(git*), Read, Edit, Glob, Grep
---

Find copy-pasted / near-duplicate code across the codebase so I can DRY it up. In report mode, list
the duplicate clusters with locations. With `--fix`, refactor them into a shared abstraction —
carefully, preserving behavior.

Argument (`$ARGUMENTS`):
- **no argument** → report only.
- **`--fix`** (or `fix`) → propose and (after I confirm) apply refactors.
- an optional **path** → limit the scan to that path (default: whole repo).

Separately, I may include **other requests** in the same message; those are not arguments — do them
first, then run this.

Follow exactly these steps:

## 0. Handle any extra requests first
- If I asked for other changes in the same message (before or after `/dupes`), do those and get them
  working before running this.

## 1. Determine mode and scope
- Parse the argument into **report** (default) vs **fix**, plus an optional path (default: repo).

## 2. Run the duplication detector
- Use **`jscpd`** (via `npx jscpd` if not installed) — it's multi-language (Rust, TS/JS, and more).
- Exclude vendored/generated dirs (`node_modules`, `target`, `dist`, `build`, `vendor`) and respect
  `.gitignore`. Use a sensible minimum block size so trivial matches aren't reported as duplicates.

## 3. Report the clusters
- For each duplicate cluster: the repeated block's size (lines/tokens), and **every** `file:line`
  range where it appears. Order by impact (biggest/most-repeated first).
- Note likely **false positives** — generated code, intentionally-parallel test cases, boilerplate a
  framework requires — and don't push to refactor those. Some duplication is fine.
- If report-only, stop here.

## 4. Fix mode — refactor, preserving behavior
Only when `--fix` was given (per my `~/.claude/rules/git-conventions.md`, create a new branch first if I'm on a protected
branch: `main`/`master`/`dev`/`develop`/`pre-homolog`):
- For each worthwhile cluster, propose the abstraction (extract a function / shared module / generic)
  and **show me the plan before editing**.
- Apply **one cluster at a time**: extract the shared code, update every call site, and keep behavior
  identical. After each, run the build/tests before moving on. If something breaks, fix or revert
  that cluster and tell me.
- Don't over-abstract — skip clusters where a shared helper would be more confusing than the
  duplication.

## 5. Report
- Summarize: clusters found, which were refactored (and into what), and which were left as-is (with
  the reason). Leave committing to me (or `/commit`).
