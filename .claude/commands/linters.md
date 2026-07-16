---
description: Load my mandatory linter rules per file type (currently Dockerfiles → hadolint + trivy config)
---

These are my mandatory linter rules, per file type. Whenever you edit or create a file of one of
the types below — in any project — run the listed linters on it and fix any issues they report
before considering the task complete.

## Dockerfiles

- **Always run both `hadolint` and `trivy config` after editing or creating a Dockerfile.** Whenever you edit or create a Dockerfile, run `hadolint <file>` and `trivy config <file>` on it and fix any issues either one reports before considering the task complete.
