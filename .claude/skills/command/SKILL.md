---
name: command
description: Register a shell command to run after everything else (--durable persists it), at the start of every session (--persistent), or right away (--now)
argument-hint: [--durable|--persistent] [--auto] [--now] <shell command, e.g. ls>
allowed-tools: Task, Agent, Read, Edit, Write, Glob, Grep, Bash, Bash(~/.claude/skills/command/scripts/*), Bash(~/.claude/scripts/command-history.sh*)
---

Take what I pass with this command, `$ARGUMENTS` (e.g. `/command ls`), as a literal **shell
command** to run in the terminal **at the very end**, after all other work is finished.

## Parse the arguments

Pass `$ARGUMENTS` to the parser as **one** single-quoted argument (write a `'` inside it as `'\''`):

```
~/.claude/skills/command/scripts/queue.sh parse '<$ARGUMENTS>'
→ {"durable","persistent","auto","now": bool, "kind": "session|durable|persistent|now",
   "store": "durable|persistent|null", "run_now": bool, "command": "…"}
```

It strips the leading flags (`--durable` = `-durable` = `-d`, `--persistent` = `-persistent` =
`-p`, `--auto` = `-auto` = `-a`, `--now` = `-now` = `-n`); `command` is the rest, verbatim. `kind`,
`store` and `run_now` already apply the rules below (e.g. `--now --durable` → `store: null`). Exit 2
prints `{"error", "message"}` (no command, or `--durable` with `--persistent`): ask me.

## Rules

- The command is a **shell command**, not a natural-language instruction. **Do not run it now**
  (unless `run_now` is true) and **do not rewrite or "improve" it**. Run `command` **verbatim**.
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
  exactly as given, and show me the output: session-only ones first, then durable, then persistent
  (see below), each in order.

## Queue files

Durable and persistent commands live **per project** in the project's `.claude/` directory (not the
global `~/.claude`): `.claude/flow-durable-commands.txt` and `.claude/flow-persistent-commands.txt`.
Always go through the script, which never clears a whole file. Pass `--project <project root>`
(the primary working directory) first: `$CLAUDE_PROJECT_DIR` isn't set in Bash tool calls, and
without it the script falls back to the git toplevel, then the cwd, which may have drifted.

```
~/.claude/skills/command/scripts/queue.sh --project <root> add durable|persistent '<command>'     → {"status":"added|exists","kind","file","command"}
~/.claude/skills/command/scripts/queue.sh --project <root> list durable|persistent               → ["…", …] (file order; [] when absent)
~/.claude/skills/command/scripts/queue.sh --project <root> remove durable|persistent '<command>' → {"status":"removed|not_found",…}; exit 1 if no match
```

## Durable (`--durable`)
- **Without the flag**, a registration lasts **only for the current session**: it runs at the end
  and is then gone (if the session ends before it runs, it's lost).
- **With `--durable`** (`store: "durable"`), `add durable` it: it **survives across sessions** but is
  a **one-shot**. Persisting it just means it won't be **lost** if the session ends before it runs;
  it still runs **only once**.
- **At the final step of every session**, `list durable` and run each command, in order, **after**
  the session-only ones. **`remove durable` each one right after it runs**, so every durable command
  executes **exactly once** (in this session, or in the next one if it never got to run).
- **To cancel a durable command before it runs**, I remove its line from the file (or ask you to
  delete exactly that line and confirm, then `remove durable` it). Never clear the file on your own.

## Persistent (`--persistent`)
- `add persistent` it. The line **persists across sessions** and, **unlike `--durable`, is never
  removed after running**: it **runs every session**, **twice per session, at the start and at the
  end**. Durable is a **one-shot**; persistent repeats.
- `list persistent` and run each command, in order, at **both** points, every session: at the
  **start** (**before** other work) and at the **final step** (**after** the session-only and
  durable commands). Nothing is removed.
- When I register one now, also **run it once immediately** (`run_now: true`) so it takes effect
  right away; from then on it auto-runs at the start and end of every future session.
- **To stop a persistent command**, I remove its line (or ask you to delete exactly that line and
  confirm, then `remove persistent` it). Never clear the file on your own.

## Now (`--now`)
- **With `--now`** (`kind: "now"`), skip the deferral entirely: **run the command immediately via
  Bash**, verbatim, and show me the output. Don't add it to the TODO list or any queue file.
- With **`--durable`**, running it now already fulfills the one-shot, so it's **not** stored
  (`store: null`). With **`--persistent`**, it's stored as usual; `--now` just makes the immediate
  first run explicit.
- The **command-history rules** (below) still apply to a `--now` run.

## Command history

- Registered commands follow my general **command-history rules**, so load
  `~/.claude/rules/command-history.md` (rule file) and apply them. Record and fix entries with:

  ```
  ~/.claude/scripts/command-history.sh --project <root> add '<command>'          # after it runs successfully
  ~/.claude/scripts/command-history.sh --project <root> remove-last '<command>'  # an entry that turned out wrong
  ~/.claude/scripts/command-history.sh --project <root> search <words…>          # [{"command","score","scopes"}], best first
  ```

  A **wrong** command is never recorded: `search` for the closest entries and suggest the most
  likely correction (or another known command), even in auto-accept mode.
- **`--auto`** (`auto: true`): per those rules, skip the suggestion step, so the best correction
  runs directly and the corrected command is recorded.

## On activation
Confirm in one line that you've registered the command (echo it back) and say which kind it is:
**session-only** (runs once at the very end), **durable** (persisted one-shot; runs once at the end,
then removed), **persistent** (persisted; runs at the start **and** end of every session, and run
it once now), or **now** (run immediately, nothing deferred). Then continue with whatever else is in
progress; except for `--now`, don't run an end-of-session command until everything else is done.
