---
description: Load my git conventions (branching and commit rules) — read/invoke this before any git work (branching, committing, PRs/MRs)
---

These are my personal git conventions. Whenever you are about to do **any git work** — creating
branches, committing, reverting, opening PRs/MRs — load this file and follow every rule below.

## Branches

- **On shared/protected branches, create a new branch for changes.** If I'm on a `dev`, `main`, `master`, or `pre-homolog` branch and I ask for a change, create a new branch to implement it instead of working directly on the current branch. Exceptions where you should stay on the current branch: personal projects, projects only I work on, or projects without a sophisticated branching system (e.g., my Neovim dotfiles, which only have `main` because they're simple dotfiles that don't warrant extra branches).

## Commits

- **NEVER add co-authorship attribution to me when making commits on my behalf.** Do not include `Co-Authored-By: Claude ...` or any line indicating that you took part in the commit. The commit must appear as being solely mine.
- **Always make atomic commits.** Separate each logical change into its own specific commit, instead of bundling unrelated changes into a single commit. If necessary, split the changes of a single file across different commits.
- **Always follow the Conventional Commits standard.** Use the form `type(optional scope): description` (e.g., `feat:`, `fix:`, `docs:`, `refactor:`, `test:`, `chore:`), with the description in the imperative. Use `BREAKING CHANGE:` in the footer or `!` after the type/scope when there is an incompatible change.
- **Don't overuse `feat:`.** `feat:` should not be used for a small piece of functionality that is part of a larger feature. In that case, `feat:` is reserved for the larger feature that incorporates the smaller one, while the smaller part uses `chore:`. Ideally there is only one `feat:` per branch/feature; only in very specific cases may there be more than one.
- **`feat:` is only for new things in the end program itself.** Reserve `feat:` for new user-facing functionality in the end program. Plumbing or wiring work — such as connecting the database to something — is not a `feat:`; use `chore:` (or another appropriate type) instead.
- **When in doubt, don't use `feat:`.** If you're not sure whether a commit deserves `feat:`, don't assign any `feat:` and let me set it manually.
