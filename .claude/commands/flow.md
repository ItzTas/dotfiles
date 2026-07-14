---
description: Continuous flow mode — take requests as a stream and do them all without me repeating
argument-hint: [first request | end]
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

### 6. Cancel only on an explicit request
- **Never** drop, skip, or silently deprioritize an item.
- The **only** reason to remove an item from the queue is me **explicitly asking to cancel it**
  (e.g., "cancel X", "drop X", "don't do Y anymore").
- When I ask, remove **exactly that item** (if it's already in progress, stop it), tell me it was
  cancelled, and **carry on** with the rest of the queue as normal.

### 7. Contradictions → ask me
- If a new request **contradicts** another item in the queue (pending, in progress, **or already
  done**) — e.g. "make the button blue" then "make the button red", or "remove Y" then "improve Y"
  — **don't guess**.
- **Stop and ask me** which option I want (ask clearly, with the alternatives). If possible, **keep
  working through the rest of the queue** while you wait for my answer.
- Only treat it as a real contradiction when the requests are truly **incompatible**. Requests that
  merely add to or complement each other are **not** contradictions — just queue both.

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
- **If `$ARGUMENTS` is exactly an exit keyword** (`end`, `out`, `stop`, `off`, `exit`), follow
  "Exiting FLOW MODE" above instead of entering the mode.
- **Otherwise**, confirm in one line that you've entered **FLOW MODE**, create the initial TODO list
  (including the first request if it came in `$ARGUMENTS`/this message), and start working. From
  then on, follow the rules above for everything I send.
