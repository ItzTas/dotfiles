---
description: My mandatory linter rules per file type
---

These are my mandatory linter rules, split per file type to keep context small. Whenever you edit
or create a file of one of the types below — in any project — **read only the matching rule file**,
run the linters it lists, and fix any issues they report before considering the task complete.
Do not read rule files for types you are not touching.

| File type                                                                                                             | Rule file to read                          |
| --------------------------------------------------------------------------------------------------------------------- | ------------------------------------------ |
| Dockerfiles                                                                                                           | `~/.claude/commands/linters/dockerfile.md` |
| Go (`.go`)                                                                                                            | `~/.claude/commands/linters/go.md`         |
| Python (`.py`, `.pyi`)                                                                                                | `~/.claude/commands/linters/python.md`     |
| Kotlin (`.kt`, `.kts`)                                                                                                | `~/.claude/commands/linters/kotlin.md`     |
| Bash / POSIX sh (`.sh`, `.bash`, or a `bash`/`sh` shebang)                                                            | `~/.claude/commands/linters/bash.md`       |
| Zsh (`.zsh`, `.zshrc`/`.zshenv`, or a `zsh` shebang)                                                                  | `~/.claude/commands/linters/zsh.md`        |
| Tailwind-style utility classes (Tailwind or UnoCSS `presetWind*`, in `.svelte`/`.html`/`.jsx`/`.tsx`/`.vue`/`.astro`) | `~/.claude/commands/linters/tailwind.md`   |

If a change touches several of these types, read each matching file. If a file type isn't listed
here, there is no mandatory linter for it.

## Before declaring a linter "not installed"

**Most of these tools live in Neovim's Mason install, which may not be on the `PATH` of the shell
you're running in (session shells can predate the `PATH` change in `zshenv`).** Never conclude a
linter is missing (and never fall back to a weaker check, skip the lint, or offer to install
anything) until you've looked in the Mason bin directory:

```bash
ls ~/.local/share/nvim/mason/bin/
```

If the executable is there, run it from that path — e.g. `~/.local/share/nvim/mason/bin/hadolint
<file>` — or prepend the directory for the whole lint pass:

```bash
PATH="$HOME/.local/share/nvim/mason/bin:$PATH" golangci-lint run ./...
```

Only after the tool is absent from both `PATH` and Mason does the rule file's "not installed"
fallback apply. Same check before installing anything: don't install a tool Mason already has.
