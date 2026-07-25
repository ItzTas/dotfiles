# Bash / POSIX sh linters

- **Always run shellcheck after editing or creating a bash/sh script** (`.sh`, `.bash`, or any
  file with a `bash`/`sh` shebang):

  ```bash
  shellcheck <file>
  ```

  Fix every issue it reports before considering the task complete. If `shfmt` is also available,
  run `shfmt -d <file>` and apply the formatting diff it shows. If `shellcheck` is not installed,
  fall back to `bash -n <file>` (syntax check only) and mention that the full lint was skipped.
