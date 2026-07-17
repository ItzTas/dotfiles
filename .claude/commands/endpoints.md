---
description: Generate an API client collection (Bruno, Insomnia, or Postman) from the endpoints this project's API actually exposes
argument-hint: <bruno|insomnia|postman> [more targets ...] [--filter <prefix|tag>] [--dry-run] [--out <dir>] [--check]
allowed-tools: Read, Glob, Grep, Bash(rg*), Bash(git*), Write, Edit
---

Generate ready-to-import request collections for my API client(s), based on the endpoints this
project's API **actually exposes** — never invented ones.

Arguments (`$ARGUMENTS`) — one or more **targets**. For now only these three are supported:

- `bruno` — a Bruno collection: a `bruno/` folder in the repository with the endpoints as **YAML**
  request files (Bruno's YAML format, not `.bru`) + `bruno.json` + environment files.
- `insomnia` — an Insomnia export file (importable JSON/YAML).
- `postman` — a Postman Collection v2.1 JSON (+ a Postman environment file).

More than one target is fine — generate all of them from the same discovered endpoints. If **no
target** is given, or a non-flag token isn't one of the three, **ask me** which target(s) to use
instead of guessing.

**Flags** (single-dash forms like `-dry-run` mean the same thing):

- `--filter <prefix|tag>` — only include the endpoints matching that path prefix or tag
  (e.g. `--filter /users`); useful in large APIs.
- `--dry-run` — only discover and **list** the endpoints (method + path + params + auth) so I can
  review them; **write nothing**.
- `--out <dir>` — write the output under `<dir>` instead of the repo-root defaults.
- `--check` — CI/drift mode: **write nothing**; compare the existing collection(s) against the
  code and report the drift — endpoints in the code that are missing from the collection, orphan
  requests that no longer exist in the code, and outdated bodies/params/auth. Report clean vs
  drifted per target; if there's no existing collection for a target, say so instead of failing.

Separately, I may include **other requests** in the same message, before or after `/endpoints`.
Those are not arguments — handle them as normal work.

## Steps

### 0. Handle any extra requests first
- If I asked for other changes in the same message, do those and get them working first.

### 1. Parse the arguments
- **Pull the flags out first** (`--filter <prefix|tag>`, `--dry-run`, `--out <dir>`, `--check`,
  including their single-dash forms).
- Every remaining token → a **target** (`bruno`, `insomnia`, `postman`). Validate every token; on
  an unknown target or flag, ask me — don't silently drop it or guess.
- `--dry-run` and `--check` change the flow: do step 2 (discovery) normally, then follow the
  flag's behavior instead of steps 3–4 — **no files are written** in either mode.

### 2. Discover the real endpoints
- **Prefer an existing spec**: if the repo has an OpenAPI/Swagger file (`openapi.*`, `swagger.*`,
  or a generated one), use it as the source of truth.
- Otherwise **read the routes from the code** — router registrations, controllers/handlers,
  decorators — whatever the framework uses (Express/Fastify/NestJS, Go `net/http`/chi/gin/echo,
  Laravel, Django/FastAPI, Rails, etc.).
- For each endpoint collect: **method, path, path/query params, request body shape** (from
  DTOs/validators/serializers when available), **auth requirements**, and expected content type.
- **Ground everything in the code** — don't invent endpoints, params, or fields. If you infer a
  body shape, say so.
- With `--filter <prefix|tag>`, keep only the matching endpoints from here on.

### 3. Build the collection(s)
- **Group requests by resource/router** so the collection mirrors the API's structure.
- Use an environment variable for the base URL (`{{base_url}}` or the target's equivalent) — never
  hardcode host/port into each request. Derive the default value from the project's config
  (`.env*`, config files, server setup); include a sensible local default (e.g.
  `http://localhost:<port>`).
- **Name every collection/environment variable in snake_case** (Python style: `base_url`,
  `api_key`, `token`) — never camelCase, in every target.
- **Always create at least a `local` environment** — it's the mandatory minimum, meant for testing
  against the locally running app: `base_url` pointing at localhost with the project's real port
  (from `.env*`/config/server setup), plus whatever other variables local requests need. If the
  repo makes **other environments** detectable (staging/production URLs in config or deploy
  files), create those too — great to have — using placeholders for anything unknown or secret;
  but never skip `local`.
- Put **auth** (bearer token, API key, etc.) in collection-level auth / environment variables, not
  repeated per request. Use placeholder values — **never copy real secrets** into the collection.
- Include a realistic **example body** for endpoints that take one, matching the actual fields.
- **Leave the collection ready to fire requests immediately** — I shouldn't need any extra setup
  after importing/opening it in the app. Whenever the target app supports it: pre-fill the
  environment with the project's real local values (base URL, port), make the local environment
  the default/selected one, and **wire the auth chain** — if the API has a login/token endpoint,
  add that request with a post-response script that stores the token into the environment variable
  the other requests already reference, so authenticated calls work right after logging in once.
  Only leave a placeholder when a value genuinely can't be known from the repo (e.g. an external
  API key) — and call those out in the report.

### 4. Write the output
- **Check for an existing collection first** (a `bruno.json`/`.bru` folder, an Insomnia export, a
  Postman collection already in the repo) — **update it in place** rather than creating a
  duplicate, preserving anything I added by hand.
- With `--out <dir>`, put everything under that directory instead of the defaults below.
- Otherwise use these defaults, telling me where things went:
  - `bruno` → a `bruno/` directory at the repo root, with each endpoint as a YAML request file
    (set the collection's format to YAML in `bruno.json`).
  - `insomnia` → `insomnia.json` at the repo root.
  - `postman` → `postman_collection.json` (+ `postman_environment.json`) at the repo root.

### 5. Verify and report
- Validate the output: JSON files must parse; Bruno's YAML request files must be valid YAML in
  Bruno's schema; if the target's CLI is available (e.g. `bru`), use it to sanity-check.
- **Check that the files actually integrate with the app without errors**: make sure each output
  matches what the target app can really import/open — the collection loads as a whole (folder
  structure, `bruno.json`, environments), the export/schema version is one the app accepts, and
  no request would fail to load (bad references, malformed variables, wrong field names). Use the
  target's CLI when available to actually exercise the collection; if you can't run the app,
  validate against its import schema and say so. **Fix any integration error found** before
  considering the task complete.
- Report a summary: how many endpoints per group, which target files were written/updated, and
  anything you had to infer or leave out.
