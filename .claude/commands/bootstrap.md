---
description: Get a fresh or stale clone ready to develop — proto tools, deps, env files, documented setup, verify
argument-hint: [up]
allowed-tools: Bash, Read, Glob, Grep
---

Prepare this project for development in one shot: install the pinned tools, install dependencies
for every ecosystem it uses, set up local env files, run any documented setup, and confirm it
builds.

This command takes an optional flag: `$ARGUMENTS`
- **`up`** — also start local services (e.g. `docker compose up -d`) if the repo defines them.
  Without it, don't start any long-running services — just report that they exist.

Separately, I may include **other requests** in the same message, before or after `/bootstrap`.
Those are not the flag — handle them as normal work.

## Steps

### 0. Handle any extra requests first
- If I asked for other changes in the same message, do those first.

### 1. Survey the project
- Look at the repo root for manifests, lockfiles, `.prototools`, `Makefile`/`justfile`/`Taskfile`,
  `docker-compose*.yml`, env examples, and the README's setup section. The repo may use **more
  than one** ecosystem — handle each found.

### 2. Pin the tools (proto)
- If a `.prototools` exists, install the pinned versions (`proto install` / `proto use`) so the
  right tool versions are active before anything else.

### 3. Install dependencies (per ecosystem)
- JS/TS: pick the PM from the lockfile — `pnpm install` (`pnpm-lock.yaml`), `yarn install`,
  `npm install` (`package-lock.json`), `bun install`.
- PHP: `composer install`. Go: `go mod download`. Rust: `cargo fetch`.
  Python: poetry/uv/`pip install -r requirements.txt`. Lua: `luarocks install`.
- If a required tool isn't available, say so clearly instead of skipping silently.

### 4. Set up env files
- For each `*.example`/`*.sample`/`*.dist` env template (e.g. `.env.example`, `.env.local.example`,
  `config.example.*`), **create the target only if it doesn't already exist** (e.g. copy
  `.env.example` → `.env`).
- **Never overwrite an existing env file** — it may hold real secrets. Do not print the contents
  of any env file; just report which ones you created and which already existed.
- After creating one, point out any placeholder values I still need to fill in.

### 5. Run documented setup
- Run project-defined setup if present: a `setup`/`bootstrap`/`install` target in
  `Makefile`/`justfile`/`Taskfile`, or `package.json` scripts like `setup`/`prepare` (note that
  `postinstall`/`prepare` may have run already during install). Follow the README's setup steps
  when they add anything not covered above.
- Install git hooks if the repo configures them (husky, lefthook, pre-commit).

### 6. Services (only with `up`)
- If `up` was passed and a `docker-compose*.yml` exists, start services with
  `docker compose up -d`. Run documented DB migrations/seeds if the setup docs call for them.
- Without `up`, just list the services the repo defines and how to start them.

### 7. Verify
- Run a quick build/typecheck (or the fastest available check) to confirm the project is actually
  ready. Report anything that fails.

### 8. Summary
- Show what was installed (tools + deps per ecosystem), which env files were created vs already
  present (and any placeholders to fill), whether services were started, and the verify result.
