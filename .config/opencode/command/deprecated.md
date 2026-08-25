---
description: Find deprecated code, APIs, and libraries; --fix migrates to the recommended equivalents preserving behavior
---

Find everything **deprecated** the project depends on: deprecated APIs/functions/language features
in my own code, and deprecated libraries/dependencies. In report mode, list them. In fix mode,
rewrite the code onto the recommended non-deprecated equivalents **without changing behavior**.

Argument (`$ARGUMENTS`):
- **no argument** → report only: scan and list the deprecations, with the suggested replacement for
  each. Change nothing.
- **`--fix`** (or `fix`) → migrate the code to remove the deprecations, keeping the same logic.
- an optional **lib or path** after the flag → scope the work to that library or that path only.
- **Flag forms**, all equivalent: `--fix` = `-fix` = `-f` = bare `fix`.

Separately, I may include **other requests** in the same message; those are not arguments, so do
them first, then run this.

## Core rule for fix mode
- **Preserve behavior exactly.** The migrated code must do the same thing as before, just without the
  deprecated construct. Same inputs → same outputs and side effects. When a replacement isn't a
  drop-in, match the old semantics deliberately, and say so.

Follow exactly these steps:

## 0. Handle any extra requests first
- If I asked for other changes in the same message (before or after `/deprecated`), do those and get
  them working before running this.

## 1. Determine mode and scope
- Parse the argument into: **report** (default) vs **fix** (`--fix`/`fix`), plus an optional
  library/path scope. Default scope is the whole repo.

## 2. Detect the toolchain
- Identify the stack from the repo (respect `.prototools`/proto for tool versions): Rust
  (`Cargo.toml`), Node/TS (`package.json`, `tsconfig.json`), etc.

## 3. Find the deprecations
Gather from every source that applies:
- **Compiler/linter warnings** (most reliable, since they carry the suggested replacement):
  - Rust: `cargo build` / `cargo clippy` → capture `use of deprecated …` warnings.
  - TS/JS: `tsc --noEmit` and, if configured, ESLint's `deprecation` rule → capture `@deprecated`
    usages.
- **Annotations in the codebase**: `rg` for `@deprecated`, `#[deprecated]`, `@Deprecated`,
  `DeprecationWarning`, `Obsolete`.
- **Deprecated dependencies**: `npm outdated` / deprecated-package warnings (`npm ls`), and for Rust
  `cargo audit` (yanked / unmaintained crates from the advisory DB).

## 4. Report the findings (always, since this is the plan in fix mode too)
- Split into two groups:
  - **Deprecated usages in my code** → `file:line`, what's deprecated, and the recommended
    replacement (from the warning message).
  - **Deprecated libraries/dependencies** → the package and its suggested successor, if any.
- If report-only, stop here.

## 5. Fix mode: migrate, preserving behavior
Only when `--fix` was given:
- **Branch safety** (per my `~/.claude/rules/git-conventions.md`): if I'm on a protected branch (`main`, `master`, `dev`,
  `develop`, `pre-homolog`), create a new branch first before editing.
- **Deprecated API/function/feature usage** → rewrite it to the recommended non-deprecated equivalent
  in place, keeping identical behavior. Use the warning's guidance; if it's unclear, look up the
  library's migration path (context7 `resolve-library-id` + `query-docs`, or WebFetch its
  changelog/docs) before editing.
- **A whole deprecated library** → this is a larger swap that can change behavior. **Flag it and ask
  before replacing the dependency**; don't silently switch libraries.
- **Work incrementally**: migrate one deprecation (or one logical group) at a time, and after each,
  re-run the build/tests to confirm behavior is preserved. If a change breaks something, fix or
  revert just that change and tell me.

## 6. Verify and report
- Re-run the build + tests, and re-scan for deprecation warnings. Confirm none remain, or list what's
  left and why (e.g. a library swap I declined, or one with no non-deprecated equivalent yet).
- Summarize what changed. Leave committing to me (or `/commit`); if I ask, make it atomic per
  migration following my commit rules (`~/.claude/rules/git-conventions.md`).
