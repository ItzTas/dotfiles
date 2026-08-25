---
description: Register a shell command to run after everything else (--durable persists it), at the start of every session (--persistent), or right away (--now)
---

Take what I pass with this command, `$ARGUMENTS` (e.g. `/command ls`), as a literal **shell
command** to run in the terminal **at the very end**, after all other work is finished.

## Rules

- The argument is a **shell command**, not a natural-language instruction. **Do not run it now**
  (unless the **`--now`** flag is given, see "Now" below) and **do not rewrite or "improve" it**.
  Run it **verbatim**. A leading **`--durable`**, **`--persistent`**, **`--auto`**, or **`--now`** is
  a flag, not part of the command, so strip it and treat the rest as the command (see "Durable",
  "Persistent", "Now" and "Command history" below).
- **Flag forms**, all equivalent: `--durable` = `-durable` = `-d`, `--persistent` = `-persistent` =
  `-p`, `--auto` = `-auto` = `-a`, `--now` = `-now` = `-n`.
- **If this arrives while you're mid-work** (thinking, executing another prompt, or with a subagent
  running), **do not interrupt** that work to run it, and don't run it right after that piece
  finishes either. Just register it and keep going; it runs **only at the very end of everything**.
- Register it as a **deferred final step**: add it to the **bottom** of your TODO list, marked as the
  **last** item, so it's visible and won't be forgotten.
- **Keep it pinned to the end.** If more work shows up after this (e.g. I keep sending requests, or
  FLOW MODE is active), this stays the final step: always run it *after* the rest of the queue is
  empty, no matter how much gets added in between.
- **If I use `/command` more than once**, keep **all** of them and run them at the end **in the
  order I gave them**.
- When (and only when) all other work is complete, **execute the registered command(s) via Bash**,
  exactly as given, and show me the output. This includes both the session-only ones and any
  **durable** ones (see below), run in order.

## Durable (`--durable`)
- **Without the flag**, a registration lasts **only for the current session**: it runs at the end
  and is then gone (if the session ends before it runs, it's lost).
- **With `--durable`**, the registration **survives across sessions** but is a **one-shot**: store it
  **per project** by appending the exact command as its own line to
  **`.claude/flow-durable-commands.txt`** in the **project's** `.claude/` directory (not the global
  `~/.claude`; create the dir/file if needed; no duplicate lines). Persisting it just means it won't
  be **lost** if the session ends before it runs; it still runs **only once**.
- **At the final step of every session**, read `.claude/flow-durable-commands.txt` (if it exists) and
  run each command in it, in file order, **after** the session-only commands. **Remove each line
  right after it runs**, so every durable command executes **exactly once** (in this session, or in
  the next one if it never got to run).
- **To cancel a durable command before it runs**, I remove its line from the file (or ask you to
  delete exactly that line and confirm). Never clear the file on your own.

## Persistent (`--persistent`)
- The line **persists across sessions** and, **unlike `--durable`, is never removed after running**.
  It **stays in the file and repeats every session**.
- **Difference from durable:** durable is a **one-shot** (runs once at the end, then removed); a
  persistent command **runs every session** and fires **twice per session, at the start and at the
  end**.
- Store it **per project** by appending the exact command as its own line to
  **`.claude/flow-persistent-commands.txt`** in the **project's** `.claude/` directory (create the
  dir/file if needed; no duplicates, so leave an existing identical line as is).
- Read `.claude/flow-persistent-commands.txt` (if it exists) and run each command in it, in file
  order, at **both** of these points, every session: at the **start** (**before** other work) and at
  the **final step** (**after** the session-only and durable commands). Nothing is removed; the
  file stays intact.
- When I register one now, also **run it once immediately** so it takes effect right away; from then
  on it auto-runs at the start and end of every future session.
- **To stop a persistent command**, I remove its line from `.claude/flow-persistent-commands.txt`
  (or ask you to delete exactly that line and confirm). Never clear the file on your own.

## Now (`--now`)
- **With `--now`**, skip the deferral entirely: **run the command immediately via Bash**, verbatim,
  and show me the output. Don't add it to the TODO list and don't register it as an end-of-session
  step, since running it now is the whole job.
- Combined with **`--durable`**, running it now already fulfills the one-shot, so **don't** write it to
  `.claude/flow-durable-commands.txt`.
- Combined with **`--persistent`**, store it per the "Persistent" rules as usual; `--now` just makes
  explicit the immediate first run that persistent registration already does.
- The **command-history rules** (below) still apply to a `--now` run.

## Command history

- Registered commands follow my general **command-history rules**, so load
  `~/.claude/rules/command-history.md` (rule file) and apply them:
  successful commands are recorded in `.claude/command-history/history.txt` (project capped at
  500 lines, global at 1000); a **wrong** command is never recorded, so suggest the most likely
  correction instead (from the history or another known command), even in auto-accept mode.
- **`auto` / `--auto` flag** (e.g. `/command --auto <cmd>`): per those rules, skips the suggestion
  step, so the closest history match runs directly and the corrected command is recorded. Like the
  other flags, `--auto` is stripped and is not part of the command.

## On activation
Confirm in one line that you've registered the command (echo it back) and say which kind it is:
**session-only** (runs once at the very end), **durable** (persisted one-shot; runs once at the end,
then removed), **persistent** (persisted; runs at the start **and** end of every session, and run
it once now), or **now** (run immediately, nothing deferred). Then continue with whatever else is in
progress; except for `--now`, don't run an end-of-session command until everything else is done.
