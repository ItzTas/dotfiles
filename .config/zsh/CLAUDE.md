# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## ⛔ Absolute rule: `secrets/`

NEVER read, open, list, `cat`, `grep`, `source`, or access in any way anything under `secrets/`. Not even when asked, not even to "verify" something. Treat its contents as nonexistent. The only thing you may know is that `zshrc` sources `secrets/tokens` — do not look inside.

## What this is

A personal Zsh configuration rooted at `$ZDOTDIR` (`~/.config/zsh`). There is no build/lint/test — "running" it means starting an interactive shell. The two dotfiles Zsh actually loads are symlinks:

- `.zshenv` → `zshenv` (every shell; non-interactive too)
- `.zshrc` → `zshrc` (interactive shells only — guarded by `[[ $- != *i* ]] && return`)

## Load order (the architecture)

`zshrc` is an orchestrator: it sources, in a deliberate sequence, small single-purpose files. Editing the wrong file or assuming the wrong order is the most common way to break things.

1. `config/prompt` — oh-my-posh init (loaded first so the prompt exists immediately).
2. **Plugins** via `__source_zsh_plugins`: for each name in the hardcoded list (`zsh-autosuggestions`, `zsh-syntax-highlighting`), it first sources its settings (either `plugins/settings/<name>` as a file *or* `plugins/settings/<name>/settings`), then sources `plugins/repos/<name>/<name>.zsh`.
3. **Config files** via `__source_zsh_config_files`, sourced in this exact order from `config/`: `envs → aliases → completions → functions → sources → setopt → binds → fzf → evals → zstyle`. The list is hardcoded in `zshrc`; a new `config/` file is dead until you add its name here.
4. **Secrets** via `__source_zsh_secrets` (sources `secrets/tokens` — see the rule above).
5. `compinit`, then main-shell-only setup that must run here rather than in a sourced file: npm prefix on `$path`, NVM, and `proto activate`.

`zshenv` sets `ZDOTDIR`, all `XDG_*` dirs, tool homes (Android, pnpm, cargo, etc.), telemetry opt-outs, and the base `PATH`. Because `zshenv` runs for non-interactive shells too, put environment that scripts/non-login contexts need here, not in `config/envs`.

## Where things live

- `config/aliases`, `config/functions` — user commands. Both are big; this is where most behavior lives.
- `config/binds` — keybindings (vi mode via `bindkey -v`) and ZLE widgets.
- `config/envs` — interactive-only env (history sizing, `EDITOR`, `PAGER`, themes…).
- `config/evals` / `config/sources` — third-party `eval "$(tool init)"` hooks (zoxide→`cd`, direnv, phpenv, keychain, dircolors, pay-respects→`f`, lesspipe) and file sourcing (cargo env).
- `config/completions` — creates `completions/{generated,manual}`, lazily generates completion files for installed tools (bootdev, eww, mdcat, git-bug, aws, and a remote-fetched `_claude`), and builds `fpath`.
- `config/setopt`, `config/zstyle`, `config/fzf` — shell options, completion styling, and fzf defaults (Catppuccin colors, `fd`-backed sources, `__` completion trigger).
- `plugins/repos/<name>/` — git clones of plugins (gitignored; update with `update_zsh_plugins`).
- `plugins/settings/<name>` — per-plugin config sourced *before* the plugin (e.g. syntax-highlighting loads its `catppuccin-mocha` theme here).
- `completions/generated/` — auto-generated, gitignored. `completions/manual/` — hand-written, committed.

## Conventions to follow when editing

- **Guard every tool reference** with `if (( ${+commands[tool]} ))` before defining an alias/function or running its init. The whole config is written to degrade gracefully on machines where a tool is absent — match this.
- Each `config/` file starts with `#!/bin/env zsh` + `# vim: filetype=zsh` and re-exports the core `PATH`. Keep that header on new files.
- **Wrapper functions shadow binaries** — be aware they exist before "fixing" a command:
  - `git()` (in `config/functions`) intercepts `git --no-pager diff` to pipe through `diff-so-fancy`; everything else falls through to the real git via `command git`.
  - `yadm()` wraps the binary to silence a `pkg_resources` warning.
  - Many aliases also remap commands (`cat`→`bat`, `ls`→`lsd`, `man`→`qman`, `cd`→`zoxide`, `vim`/`nano`→`nvim`).
- Theme is Catppuccin Mocha throughout (fzf, bat, syntax-highlighting) — keep new color choices consistent.

## Common operations

- Apply changes to the live shell: `exec zsh` (re-exec) or `source ~/.config/zsh/.zshrc`.
- `upgrady` — full system upgrade (AUR helper, flatpak, hyprpm, snap, plugins, yadm submodules…).
- `update_zsh_plugins` — `git pull` every repo under `plugins/repos/`.
- Dotfiles are managed with **yadm**; `secrets/`, `history`, `.zcompdump`, `.dircolors`, `plugins/repos/`, and `completions/generated/` are gitignored.
