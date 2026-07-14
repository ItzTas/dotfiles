---
description: Continuous flow mode — take requests as a stream and do them all without me repeating
argument-hint: [first request | subcommand]
allowed-tools: Task, Agent, Read, Edit, Write, Glob, Grep, Bash
---

Enter **FLOW MODE** and stay in it until the end of the session (or until I explicitly leave it —
see "Exiting FLOW MODE" below).

This is a special mode for when I want to make **several changes that keep popping into my head**
and I want to dump them as I think of them, **without having to repeat myself or wait for you to
finish one before asking for the next**. It's not only for features — it applies to anything
(features, fixes, refactors, investigations, docs, whatever).

The first request may come with the invocation: `$ARGUMENTS` (and/or in the rest of this message).

## Mode rules

### 1. Every message from me is a new backlog item
- While you're working, **I'll keep sending prompts**. Each new message is a **work item to add to
  the queue**, **not** a replacement for what you're currently doing.
- As soon as a request arrives, **add it to your TODO list immediately** (use the TODO list) before
  continuing, so nothing gets lost.
- **Never make me repeat myself.** Once I've asked for something, it's in the queue and it will get
  done.

### 2. Work until the queue is empty
- Work through the items until you've **completed them all**. When you finish an item, **move on to
  the next pending one automatically** — don't stop for approval after each item.
- Only stop when the backlog is **empty**. Then give a short summary of what was done and say you're
  ready for more (the mode stays active).

### 3. Order is your choice
- You may do the items **consecutively (in the order they arrived)** or **in whatever order you
  prefer**.
- Prefer reordering when it respects **dependencies** (something that must come first) or lets you
  **batch related changes** to be more efficient.
- Use good judgment: don't let one big item **starve** several small ones indefinitely.

### 4. Parallelism is allowed
- You **may** spawn **subagents in parallel** (Task/Agent) for items that are **independent** of
  each other, when it genuinely speeds up the work.
- Keep the main thread **coordinating** and **updating the TODO list** as the subagents finish.
  Don't parallelize items that depend on one another or touch the same files.

### 5. Keep the TODO list visible and current
- Keep the TODO list **continuously updated**: `pending` / `in progress` / `done`, so I can see
  what's queued and what's already out.
- Mark an item done **the moment** you finish it.
- **For very complex items**, the short TODO entry may not be enough. You **may** write the item's
  full details — plan, sub-steps, decisions, context — to its own file. Store these files under
  **`.claude/tasks/`** in the **project's** `.claude/` directory (the one at the current project/repo
  root, not the global `~/.claude`), and **inside it in a subdirectory named after the current
  session** (its id/number) — i.e. **`.claude/tasks/<session-id>/`**. Create those directories if
  they don't exist, and put each task file there with a short kebab-case filename (e.g.
  `.claude/tasks/<session-id>/refactor-auth.md`). Keep the file updated as you work and reference it
  from the TODO entry. Only do this when the complexity warrants it — don't create a file for trivial
  items.
- **When you no longer need one of these task files** (the item is done and the details won't be
  needed anymore), you **may delete it**.

### 6. Cancel only on an explicit request
- **Never** drop, skip, or silently deprioritize an item.
- The **only** reason to remove an item from the queue is me **explicitly asking to cancel it**
  (e.g., "cancel X", "drop X", "don't do Y anymore", or the explicit form
  **`/flow canceltask <task>`**).
- When I ask, remove **exactly that item** (if it's already in progress, stop it), tell me it was
  cancelled, and **carry on** with the rest of the queue as normal.

### 7. Contradictions → ask me
- If a new request **contradicts** another item in the queue (pending, in progress, **or already
  done**) — e.g. "make the button blue" then "make the button red", or "remove Y" then "improve Y"
  — **don't guess**.
- The moment you notice a possible contradiction, **flag it out loud in your reasoning/thinking**
  (name the two conflicting items) as soon as it comes up, so I can see it while you're still going.
- **If I see that and reply with a prompt resolving it before you'd ask** (telling you which one to
  do), just **follow my resolution — no question needed.** Only fall back to **stopping and asking
  me** (clearly, with the alternatives) if I *haven't* already clarified. If possible, **keep
  working through the rest of the queue** while you wait for my answer.
- Only treat it as a real contradiction when the requests are truly **incompatible**. Requests that
  merely add to or complement each other are **not** contradictions — just queue both.

## Control subcommands
These are run as `/flow <keyword> [args]` while in FLOW MODE. When the argument is one of these
keywords, **don't treat it as a new work item** — carry out the control action instead. The mode
stays active (except for the exit keywords).

- **`/flow status`** — Show the current queue grouped as `pending` / `in progress` / `done`. Just
  report it; don't add or run anything.
- **`/flow recap`** — Summarize what's been **completed** so far (the `done` items), in a short
  readable list. Don't add or run anything.
- **`/flow clear`** — Cancel **all `pending` items at once** and stay in the mode. Since rule 6
  forbids silent drops, **confirm first** (show how many/which will be dropped). Don't touch an
  `in progress` item unless I say so — ask if I also want to stop it.
- **`/flow pause`** — **Stop starting new work.** Bring any `in progress` item to a safe stopping
  point and hold. Keep **accepting and queueing** everything I send (rule 1 still applies), but
  don't execute until I resume. Confirm you're paused.
- **`/flow resume`** — Leave the paused state and **start working through the queue again** from
  where it left off, following the normal rules.
- **`/flow parallel [on|off]`** — Control rule 4's parallelism. `on` (also the default when bare)
  lets you spawn parallel subagents for independent items; `off` forces **serial** execution (one
  item at a time, no parallel subagents). The setting persists until I change it or exit the mode.
- **`/flow defer <task>`** — **Deprioritize** the matching task: move it to the **end** of the
  queue without cancelling it (if it's `in progress`, hold it and pick it up later). If `<task>` is
  ambiguous or matches no queued item, ask me which one I mean.
- **`/flow help`** — List all the subcommands with a one-line description of each (every keyword in
  this section, plus `canceltask <task>` and the exit keywords). Just print the list; don't add or
  run anything and don't change the mode.

## Exiting FLOW MODE
- I leave the mode by running the command again with an exit keyword as the argument — i.e.
  **`/flow end`** or **`/flow out`** (also accept `stop`, `off`, `exit`, case-insensitive). I may
  also just say "exit flow" / "end flow" in plain words.
- When that happens, **do not** treat the keyword as a new work item. Instead, leave FLOW MODE:
  stop treating my messages as backlog items and stop applying the rules above.
- Before leaving, if there are still `pending` / `in progress` items, tell me what's left and ask
  whether you should **finish them first** or **drop them** — don't silently discard queued work
  (that would violate rule 6). Once the queue is empty or I've decided, confirm in one line that
  you've exited FLOW MODE.

## On activation
Dispatch on `$ARGUMENTS` (first word, case-insensitive):
- **Exit keyword** (`end`, `out`, `stop`, `off`, `exit`) → follow "Exiting FLOW MODE" above instead
  of entering the mode.
- **`canceltask <task>`** → don't treat it as a new work item; **cancel that specific task** per
  rule 6: find the item the `<task>` refers to, remove it from the queue (if it's already in
  progress, stop it), tell me it was cancelled, and **carry on** with the rest of the queue. If
  `<task>` is ambiguous or matches no queued item, ask me which one I mean.
- **A control keyword** (`status`, `recap`, `clear`, `pause`, `resume`, `parallel`, `defer`,
  `help`) → don't treat it as a new work item; carry out the matching action from "Control
  subcommands" above.
- **Otherwise** → confirm in one line that you've entered **FLOW MODE**, create the initial TODO
  list (including the first request if it came in `$ARGUMENTS`/this message), and start working.
  From then on, follow the rules above for everything I send.
