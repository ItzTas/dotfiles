---
description: Load my shell-command history rules — record every command I explicitly ask you to run, and use the history to suggest corrections when a requested command is wrong or doesn't exist
---

These are my rules for keeping a history of shell commands. They apply whenever I **explicitly ask
you to run a shell command** — directly in a message ("run X"), or through a registration like
`/command` or a final-mode `/defer`. Commands you choose to run on your own initiative (builds,
searches, checks, etc.) are **not** part of this — only commands I asked for explicitly.

## History files

- Keep the history in two files, one per scope: **`.claude/command-history/history.txt`** in the
  **project's** `.claude/` directory and **`~/.claude/command-history/history.txt`** in the
  **global** one (create the folder/file if needed).
- Every explicitly-requested command that **runs successfully** is appended, as its own line, to
  **both** files at the moment it runs.
- **500-line cap per file.** After appending, if a file has more than **500 lines**, delete the
  **oldest** entries (the top lines) until it's back at 500.

## Wrong / non-existent commands

- **Never record a wrong command.** If the command I asked for turns out to be **wrong** — it fails
  when run (typo, `command not found`, bad pathspec, etc.) — or simply **doesn't exist**, do **not**
  write it to the history. Instead, **search both history files** for entries that resemble what I
  wrote and **suggest** the closest match (e.g. "did you mean `yadm add commands && yadm_update`?"),
  waiting for my confirmation before running the suggestion. **Always suggest — even if
  auto-accept/auto mode is on**; a guessed correction never auto-runs without the flag below.
- **`auto` / `--auto` flag**: if I passed it with the request (e.g. `/command --auto <cmd>`), skip
  the suggestion step — find the closest match in the histories and **execute it directly** without
  asking, then record the **corrected** command (the one that actually ran) in the history.
