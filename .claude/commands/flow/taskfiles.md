---
description: FLOW MODE add-on where every item gets a .md written before the work starts, so I can edit it while you work
argument-hint: "[on|off] [first request]"
allowed-tools: Task, Agent, Read, Edit, Write, Glob, Grep, Bash
---

Turn **TASKFILES mode** on (or off) for **FLOW MODE** (`/flow`, `~/.claude/commands/flow.md`).

It's an add-on to FLOW MODE, not a mode of its own: everything in `flow.md` still applies as
written, and the rules below sit on top of it. **Off by default**: it's only active once I run this
command, and it stays active until I turn it off or leave FLOW MODE.

The point: **every item lands on disk as a `.md` before you touch it**, so I can open that file and
edit it (refine the spec, add constraints, cut scope) **while you're still working**, without
sending you another message.

## Dispatch on `$ARGUMENTS` (first word, case-insensitive)

- **`off`**: turn the mode off, going back to flow.md rule 5's default (files only when the item
  warrants one), and confirm in one line. Don't delete the files already written.
- **`on`, or no argument**: turn it on (see below).
- **Anything else**: turn it on **and** treat the whole argument as a **new work item**, queued per
  flow.md rule 1 (e.g. `/flow:taskfiles fix the login redirect`). `on` followed by a request does
  both too.

If FLOW MODE isn't active yet, **enter it** (per flow.md's "On activation") with this mode already
on, and say so in the same line.

**When turning it on, backfill**: write files for every item still `pending` or `in progress` that
doesn't have one yet, then report the paths.

## Rules while the mode is on

- **Write a file for every item, no exceptions.** As soon as a request arrives and goes into the
  TODO list, **immediately** create its `.md` under
  `.claude/tasks/$CLAUDE_CODE_SESSION_ID/<kebab-case-name>.md`, with the same location, naming and
  session-isolation rules as flow.md rule 5, including the `## Images` handling. This holds **even
  for trivial one-line items** and even for items you're about to start right away: rule 5's "only
  skip the file when the item is trivial" carve-out **does not apply** here.
- **File first, work second.** Never start an item before its file exists on disk. For the item
  you're starting immediately, write the file, then begin.
- **Tell me the path** in one line when you create it (relative path is fine), so I can open it.
- **Structure it so it's editable.** Short, but complete enough to be worked from later:

  ```markdown
  # <title>

  ## Goal
  <what I asked for, in my terms>

  ## Context
  <files, symbols, constraints, decisions already made>

  ## Plan
  - [ ] step
  - [ ] step

  ## My edits
  <-- I write here; treat this section as authoritative -->

  ## Notes
  <what you learned while doing it>
  ```

- **Re-read the file right before you start the item**, and again at every natural checkpoint while
  it's in progress (finishing a step, before a big edit, when coming back from a subagent). The file
  on disk, not the original prompt in context, is the **source of truth** for that item.
- **My edits win.** Anything I wrote in the file (especially under `## My edits`) overrides the
  original request and your own plan. When you notice the file changed mid-work, say so in one line
  ("`refactor-auth.md` changed, picking up the new constraint") and adapt. If my edit contradicts
  work you already finished for that item, that's flow.md rule 7: flag it and ask.
- **Keep the file updated as you go** (tick the plan boxes, append to `## Notes`), but **never
  overwrite or reword my `## My edits` section**, and never rewrite the whole file blind, since I
  may have it open. Prefer targeted edits over full rewrites.
- **Subagents get the path, not just the text.** When you hand an item to a subagent, tell it to
  read the task file first, re-read it at checkpoints, and follow the same "don't touch
  `## My edits`" rule.
- **Don't delete task files while this mode is on**, even when the item is done, since I may still
  be reading or editing them. Rule 5's deletion permission is suspended until I turn the mode off or
  exit FLOW MODE.
