---
description: Load my mandatory linter rules per file type.
---

These are my mandatory linter rules, split per file type to keep context small. Whenever you edit
or create a file of one of the types below — in any project — **read only the matching rule file**,
run the linters it lists, and fix any issues they report before considering the task complete.
Do not read rule files for types you are not touching.

| File type | Rule file to read |
|-----------|-------------------|
| Dockerfiles | `~/.claude/commands/linters/dockerfile.md` |
| Go (`.go`) | `~/.claude/commands/linters/go.md` |
| Python (`.py`, `.pyi`) | `~/.claude/commands/linters/python.md` |
| Bash / POSIX sh (`.sh`, `.bash`, or a `bash`/`sh` shebang) | `~/.claude/commands/linters/bash.md` |
| Zsh (`.zsh`, `.zshrc`/`.zshenv`, or a `zsh` shebang) | `~/.claude/commands/linters/zsh.md` |

If a change touches several of these types, read each matching file. If a file type isn't listed
here, there is no mandatory linter for it.
