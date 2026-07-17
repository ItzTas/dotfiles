---
description: Load my mandatory linter rules per file type (Dockerfiles → hadolint + trivy config; Go → errcheck via golangci-lint)
---

These are my mandatory linter rules, per file type. Whenever you edit or create a file of one of
the types below — in any project — run the listed linters on it and fix any issues they report
before considering the task complete.

## Dockerfiles

- **Always run both `hadolint` and `trivy config` after editing or creating a Dockerfile.** Whenever you edit or create a Dockerfile, run `hadolint <file>` and `trivy config <file>` on it and fix any issues either one reports before considering the task complete.

## Go

- **Always run golangci-lint after editing or creating a `.go` file**, scoped to the packages you
  touched (use `./...` if the change is broad).

  - If the repo has a golangci-lint config (`.golangci.yml`/`.yaml`/`.toml`/`.json`), it is
    authoritative — run it as-is:

    ```bash
    golangci-lint run <pkg-dir>/...
    ```

  - Otherwise run the full standard set (errcheck, govet, ineffassign, staticcheck, unused):

    ```bash
    golangci-lint run --no-config --default=standard <pkg-dir>/...
    ```

  Fix every issue it reports in the code you touched before considering the task complete
  (pre-existing findings in unrelated packages don't block the task — just mention them).
  If `golangci-lint` is not installed, fall back to running `go vet <pkg>` plus the standalone
  `errcheck <pkg>` (and `staticcheck <pkg>` if available).
