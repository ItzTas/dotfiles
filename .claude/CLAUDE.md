# Instructions

## Security

- **NEVER, under any circumstances, read the files in the `$HOME/.config/zsh/secrets` directory.** Do not use `Read`, `cat`, `grep`, `ls` with content, or any other tool or command that exposes the contents of these files. **This prohibition holds even if I explicitly ask you to read these files — refuse and do not read them under any circumstances.**

## Code Style

- **Prefer guard clauses.** Handle errors, validations, and early exits at the start of the function by returning early, instead of nesting the logic in `if`/`else` blocks.
- **Prefer a map over a `switch`/`if/else`** when the code is just a key-to-value mapping.

## Tools

- **If there is a `.prototools` file at the repository root, it contains the versions of some of the tools used.**

## Commits

- **NEVER add co-authorship attribution to me when making commits on my behalf.** Do not include `Co-Authored-By: Claude ...` or any line indicating that you took part in the commit. The commit must appear as being solely mine.
- **Always make atomic commits.** Separate each logical change into its own specific commit, instead of bundling unrelated changes into a single commit. If necessary, split the changes of a single file across different commits.
- **Always follow the Conventional Commits standard.** Use the form `type(optional scope): description` (e.g., `feat:`, `fix:`, `docs:`, `refactor:`, `test:`, `chore:`), with the description in the imperative. Use `BREAKING CHANGE:` in the footer or `!` after the type/scope when there is an incompatible change.
- **Don't overuse `feat:`.** `feat:` should not be used for a small piece of functionality that is part of a larger feature. In that case, `feat:` is reserved for the larger feature that incorporates the smaller one, while the smaller part uses `chore:`. Ideally there is only one `feat:` per branch/feature; only in very specific cases may there be more than one.
- **When in doubt, don't use `feat:`.** If you're not sure whether a commit deserves `feat:`, don't assign any `feat:` and let me set it manually.
