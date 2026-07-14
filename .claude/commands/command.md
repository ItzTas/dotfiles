---
description: Register a shell command to run last — I execute it in the terminal after everything else
argument-hint: <shell command, e.g. ls>
allowed-tools: Task, Agent, Read, Edit, Write, Glob, Grep, Bash
---

Take what I pass with this command — `$ARGUMENTS` (e.g. `/command ls`) — as a literal **shell
command** to run in the terminal **at the very end**, after all other work is finished.

## Rules

- The argument is a **shell command**, not a natural-language instruction. **Do not run it now** and
  **do not rewrite or "improve" it** — run it **verbatim** later.
- **If this arrives while you're mid-work** — thinking, executing another prompt, or with a subagent
  running — **do not interrupt** that work to run it, and don't run it right after that piece
  finishes either. Just register it and keep going; it runs **only at the very end of everything**.
- Register it as a **deferred final step**: add it to the **bottom** of your TODO list, marked as the
  **last** item, so it's visible and won't be forgotten.
- **Keep it pinned to the end.** If more work shows up after this (e.g. I keep sending requests, or
  FLOW MODE is active), this stays the final step — always run it *after* the rest of the queue is
  empty, no matter how much gets added in between.
- **If I use `/command` more than once**, keep **all** of them and run them at the end **in the
  order I gave them**.
- When (and only when) all other work is complete, **execute the registered command(s) via Bash**,
  exactly as given, and show me the output.

## On activation
Confirm in one line that you've registered the final shell command (echo it back) and note that it
will run at the very end. Then continue with whatever else is in progress — don't run the registered
command until everything else is done.
