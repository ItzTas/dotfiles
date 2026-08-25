---
description: Check a target (file, dir, glob, or diff) with given or auto-detected tools; report and fix findings
---

Run quality/lint/validation checks against a target and **fix** what they report.

Arguments: the first is **what** to check, the rest (optional) are **which tools** to use:
`$ARGUMENTS`

- **First argument = the target.** It can be:
  - a **file** (`Dockerfile`, `src/main.go`),
  - a **directory** (`src`),
  - a **file type / language**: a bare extension or language name like `js`, `ts`, `py`, `go`,
    `lua`, `php`, `vue`, `sh`, `yaml` → every file of that type in the project,
  - a **glob / pattern** like `*.js`, `**/*.ts`, `src/**/*.py`,
  - or a **keyword**: `.` (whole project) or `diff`/`staged`/`changes` (only what changed).
- **Remaining arguments = the tools** to run (e.g. `eslint`, `hadolint`, `trivy`, `ruff`, `tsc`,
  `shellcheck`). There may be **zero or more**; more than one is fine and they all run.

Separately, I may include **other requests** in the same message, before or after `/check`. Those
are not arguments; handle them as normal work.

## Steps

### 0. Handle any extra requests first
- If I asked for other changes in the same message (beyond the target and tools), do those first.

### 1. Parse the arguments
- First token → the **target**. Resolve it to the concrete set of files to check:
  - `diff`/`staged`/`changes` → the changed files via `git diff --name-only` (or `--staged`).
  - A **bare file type / language** (`js`, `ts`, `py`, `go`, `lua`, `php`, `vue`, `sh`, `yaml`, …)
    → expand to all matching files in the repo, e.g. `git ls-files '*.js'` (map `python`→`py`,
    `golang`→`go`, `shell`→`sh`, etc.).
  - A **glob / pattern** (`*.js`, `**/*.ts`, `src/**/*.py`) → expand it yourself (Glob tool or
    `git ls-files`); **quote it** in any shell command so the shell doesn't pre-expand it.
  - A plain file or directory → use as-is.
- Remaining tokens → the **explicit tool list**.

### 2. Decide which tools to run
- **If tools were given, use exactly those** (don't second-guess or add others).
- **If none were given, auto-detect** sensible checkers from the target's type / the project's
  config. Prefer tools the repo already configures (look for config files) and honor
  `.prototools` for versions, running through `proto` when the tool is pinned there. Examples:
  - Dockerfile → `hadolint`, `trivy config`
  - JS/TS → `eslint`, `tsc --noEmit`, `prettier --check`
  - Vue → `eslint`, `vue-tsc --noEmit`
  - Python → `ruff`, `mypy`
  - Go → `go vet`, `golangci-lint`, `gofmt -l`
  - Rust → `cargo clippy`, `cargo fmt --check`
  - Lua → `luacheck`, `selene`, `stylua --check`
  - PHP → `phpstan`, `php-cs-fixer`
  - Shell → `shellcheck`, `shfmt -d`
  - YAML → `yamllint`
- If you can't confidently detect any tool for the target, **ask me** which to use instead of
  guessing wildly.

### 3. Verify availability
- Before running each tool, confirm it's available (respecting `.prototools`/`proto`). If a
  requested tool isn't installed, tell me clearly; don't silently skip it.

### 4. Run the checks
- Run each selected tool against the target and capture its output.

### 5. Report
- Summarize the findings per tool: what passed clean and what has issues (with the key messages).

### 6. Fix
- Fix the issues the tools reported, following my code style rules in `~/.claude/rules/code-style.md` (guard clauses over
  nesting, a map over `switch`/`if-else` for simple key→value, and any per-project conventions).
- For safe auto-fixers (e.g. `eslint --fix`, `prettier -w`, `ruff --fix`, `gofmt -w`, `stylua`),
  apply them; for findings that need judgement (e.g. `trivy` security issues, type errors), fix
  them deliberately in the code.

### 7. Confirm
- **Re-run the same tools** to confirm the target is now clean. Report anything still failing.
