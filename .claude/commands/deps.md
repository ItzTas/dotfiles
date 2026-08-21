---
description: Audit and/or update project dependencies across whatever package managers the repo uses, honoring .prototools/proto
argument-hint: [audit|update] [package ...] [major]
allowed-tools: Bash, Read, Glob, Grep, Edit
---

Audit and, when asked, update the project's dependencies across **every** package manager the
repo uses, reporting vulnerabilities and outdated packages.

Arguments (all optional): `$ARGUMENTS`

- **Mode**: the first token may be `audit` (default) or `update`.
  - `audit` (or no mode): report outdated packages and known vulnerabilities. **Change nothing.**
  - `update`: actually apply updates.
- **Package(s)**: after `update`, any further tokens (except `major`) name specific packages to
  update. If none are named, update all.
- **`major`** allows major-version bumps. Without it, `update` stays on **safe (minor/patch)**
  ranges only.

Separately, I may include **other requests** in the same message, before or after `/deps`. Those
are not arguments; handle them as normal work.

## Steps

### 0. Handle any extra requests first
- If I asked for other changes in the same message, do those first.

### 1. Parse the arguments
- Detect the mode (`audit` default), any named packages, and the `major` flag from `$ARGUMENTS`.

### 2. Detect the package manager(s)
- Look for manifests/lockfiles. The repo may use **more than one** ecosystem; handle each found.
  Honor `.prototools` and run the tools through `proto` when versions are pinned there.
  - JS/TS: `package.json` → pick the PM from the lockfile, `pnpm-lock.yaml`→pnpm,
    `yarn.lock`→yarn, `package-lock.json`→npm, `bun.lockb`→bun.
  - PHP: `composer.json` → composer.
  - Go: `go.mod` → go modules (+ `govulncheck` for vulns).
  - Rust: `Cargo.toml` → cargo (+ `cargo audit`).
  - Python: `pyproject.toml`/`requirements.txt` → poetry/uv/pip (+ `pip-audit`).
  - Lua: `*.rockspec` → luarocks.
- If a needed tool (e.g. `pnpm`, `govulncheck`, `cargo-audit`, `pip-audit`) isn't installed, say
  so; don't silently skip that check.

### 3. Audit (always, since this is the reporting part)
- For each ecosystem, list **outdated** packages and **known vulnerabilities**, e.g.
  `pnpm outdated` / `npm outdated`, `pnpm audit` / `npm audit`, `composer outdated` /
  `composer audit`, `go list -u -m all` + `govulncheck ./...`, `cargo outdated` + `cargo audit`,
  `pip list --outdated` + `pip-audit`.
- Report clearly, **grouped by ecosystem**, and sort vulnerabilities by severity (highest first).

### 4. Update (only in `update` mode)
- Apply updates with the detected PM:
  - Default (no `major`): safe minor/patch updates, `pnpm update` / `npm update`,
    `composer update`, `go get -u=patch ./...`, `cargo update`, etc.
  - With `major`: allow major bumps, e.g. `pnpm up --latest` / `npm-check-updates -u`,
    `composer require pkg:^X`, `go get -u ./...`, `cargo upgrade`.
  - If specific packages were named, update **only** those.
- Refresh lockfiles / tidy as the ecosystem requires (`go mod tidy`, install to regenerate locks).
- **After updating, run the project's tests/build** if a quick one exists, to confirm nothing broke.
  Report failures.

### 5. Summary
- Show what was audited, what was updated (from and to versions), the state of remaining
  vulnerabilities, and any test/build result.
- **Don't commit automatically.** Leave the changes in the working tree and suggest `/commit` (the
  lockfile/manifest bumps are a good atomic `chore(deps):` commit).
