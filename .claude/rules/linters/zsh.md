# Zsh linters

- **Always syntax-check zsh scripts** (`.zsh`, zsh dotfiles like `.zshrc`/`.zshenv`, or any file
  with a `zsh` shebang) after editing or creating them:

  ```bash
  zsh -n <file>
  ```

  Fix every error it reports before considering the task complete. **Do not run shellcheck on
  zsh files**: it doesn't support zsh, and forcing `--shell=bash` produces false positives.
