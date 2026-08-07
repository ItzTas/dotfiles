These are my rules for keeping a history of shell commands. They apply whenever I **explicitly ask
you to run a shell command** — directly in a message ("run X"), through a registration like
`/command` or a final-mode `/defer`, or when I run one myself with the **`!` prefix** in the input
box. Commands you choose to run on your own initiative (builds, searches, checks, etc.) are **not**
part of this — only commands I asked for explicitly.

## History files

- Keep the history in two files, one per scope: **`.claude/command-history/history.txt`** in the
  **project's** `.claude/` directory and **`~/.claude/command-history/history.txt`** in the
  **global** one (create the folder/file if needed).
- Every explicitly-requested command that **runs successfully** is appended, as its own line, to
  **both** files at the moment it runs.
- **Line caps: 500 for the project file, 1000 for the global file.** After appending, if a file has
  more than its cap, delete the **oldest** entries (the top lines) until it's back at the cap.
- **`!` commands are recorded automatically.** Commands I run with the `!` prefix are appended by
  the `UserPromptSubmit` hook (`~/.claude/hooks/command-history.sh`) at submission time — don't
  record those manually a second time.
- **Remove entries that turn out to fail.** The hook records a `!` command at **submission**,
  before it runs — so when you see in its output that it **errored** (non-zero exit,
  `command not found`, bad pathspec, etc.), **delete that entry** from both history files (the
  last matching line). Likewise for any already-recorded command that later proves wrong: a
  failing command must not stay in the history.

## Wrong / non-existent commands

- **Never record a wrong command.** If the command I asked for turns out to be **wrong** — it fails
  when run (typo, `command not found`, bad pathspec, etc.) — or simply **doesn't exist**, do **not**
  write it to the history. Instead, **suggest the most likely intended command** (e.g. "did you mean
  `yadm add commands && yadm_update`?"), waiting for my confirmation before running the suggestion.
  **Search both history files** for entries resembling what I wrote, but the history is a **source,
  not a constraint**: when another **known command** is the more likely intent — an obvious typo fix
  (`gti status` → `git status`), a tool you know exists on my system, a command from the current
  context — suggest that one instead of forcing a history match. **Always suggest — even if
  auto-accept/auto mode is on**; a guessed correction never auto-runs without the flag below.
- **`auto` / `--auto` flag**: if I passed it with the request (e.g. `/command --auto <cmd>`), skip
  the suggestion step — pick the best correction (from the histories or a known command, as above)
  and **execute it directly** without asking, then record the **corrected** command (the one that
  actually ran) in the history.
