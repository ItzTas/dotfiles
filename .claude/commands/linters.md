---
description: Load my mandatory linter rules per file type (Dockerfiles → hadolint + trivy config; Go → golangci-lint full standard set; Bash → shellcheck; Zsh → zsh -n)
---

These are my mandatory linter rules, per file type. Whenever you edit or create a file of one of
the types below — in any project — run the listed linters on it and fix any issues they report
before considering the task complete.

## Dockerfiles

- **Always run both `hadolint` and `trivy config` after editing or creating a Dockerfile.** Whenever you edit or create a Dockerfile, run `hadolint <file>` and `trivy config <file>` on it and fix any issues either one reports before considering the task complete.
- **`DL3018` (pin versions in `apk add`) is OK to ignore when pinning risks breaking things.** Alpine drops old package versions from its repos on every bump, so a pinned `apk add pkg=<version>` makes future rebuilds fail with a "no such package" error — and for security-sensitive packages like `ca-certificates` you actually want the newest bundle, not a frozen one. In those cases don't pin: suppress the rule inline with `# hadolint ignore=DL3018` on the line above the `RUN`, and leave `apk add --no-cache <pkg>` unpinned. Only pin when reproducibility genuinely matters more than rebuild resilience.

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

## Bash / POSIX sh

- **Always run shellcheck after editing or creating a bash/sh script** (`.sh`, `.bash`, or any
  file with a `bash`/`sh` shebang):

  ```bash
  shellcheck <file>
  ```

  Fix every issue it reports before considering the task complete. If `shfmt` is also available,
  run `shfmt -d <file>` and apply the formatting diff it shows. If `shellcheck` is not installed,
  fall back to `bash -n <file>` (syntax check only) and mention that the full lint was skipped.

## Zsh

- **Always syntax-check zsh scripts** (`.zsh`, zsh dotfiles like `.zshrc`/`.zshenv`, or any file
  with a `zsh` shebang) after editing or creating them:

  ```bash
  zsh -n <file>
  ```

  Fix every error it reports before considering the task complete. **Do not run shellcheck on
  zsh files** — it doesn't support zsh and forcing `--shell=bash` produces false positives.
