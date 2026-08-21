---
description: Continuous flow mode that takes requests as a stream and does them all without me repeating
argument-hint: [first request | subcommand]
allowed-tools: Task, Agent, Read, Edit, Write, Glob, Grep, Bash
---

Enter **FLOW MODE** and stay in it until the end of the session (or until I explicitly leave it;
see "Exiting FLOW MODE" below).

This is a special mode for when I want to make **several changes that keep popping into my head**
and I want to dump them as I think of them, **without having to repeat myself or wait for you to
finish one before asking for the next**. It's not only for features; it applies to anything
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
  the next pending one automatically**, and don't stop for approval after each item.
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
- The main thread is the **single owner** of task assignment: give each subagent the **specific,
  disjoint** item(s) to work on in its prompt. Subagents must **not** scan `.claude/tasks/` to pick
  work themselves, since self-selection lets two agents grab the same task. If a pull model is ever
  unavoidable, claiming a task must be **atomic**: `mv` it from a `pending/` to an `in-progress/`
  subdir (rename is atomic; the loser's `mv` fails and it moves on). Never rely on a `status:` field
  inside the file, since read-then-write isn't atomic.

### 5. Keep the TODO list visible and current
- Keep the TODO list **continuously updated**: `pending` / `in progress` / `done`, so I can see
  what's queued and what's already out.
- Mark an item done **the moment** you finish it.
- **When the short TODO entry may not be enough**, write the item's full details (plan, sub-steps,
  decisions, context) to its own file. This applies not only to **very complex items**, but to
  **any item whose specifics you're likely to forget by the time you get to it**, in particular
  when the queue already has many items and this one lands near the **end**: by then a lot of work
  (and context) will have gone by, and details from the original request will be lost unless they're
  written down. When in doubt, err on the side of writing the file. Store these files under
  **`.claude/tasks/`** in the **project's** `.claude/` directory (the one at the current project/repo
  root, not the global `~/.claude`), and **inside it in a subdirectory named after the real session
  id**, taken from `$CLAUDE_CODE_SESSION_ID` (unique per process/terminal, and stable for the
  whole session; if it's ever empty, generate one once with `uuidgen` / `mktemp -d
  .claude/tasks/XXXXXXXX` and reuse it), i.e. **`.claude/tasks/$CLAUDE_CODE_SESSION_ID/`**. Do
  **not** name this folder with a made-up number or with a value derived from the date, branch, or
  project name: two `claude` processes running in different terminals would compute the **same** name
  and end up sharing the same task folder. **Always operate only inside your own session's folder**:
  when listing or reading tasks, scan just your `$CLAUDE_CODE_SESSION_ID/` subdirectory, never the
  whole `.claude/tasks/` tree, and never read or touch another session's subdirectory, **unless I
  explicitly ask you to read it**. On my explicit request (and **only** then) you may **read**
  another session's folder or the whole `.claude/tasks/` tree, never on your own initiative, and
  even then it's **read-only**: never write to, move, or delete anything in another session's
  folder. Create those
  directories if they don't exist, and put each task file there with a short kebab-case filename
  (e.g. `.claude/tasks/$CLAUDE_CODE_SESSION_ID/refactor-auth.md`). Keep the file updated as you work
  and reference it from the TODO entry. Only skip the file when the item is trivial or will be done
  right away; don't create files for those (**unless `taskfiles` mode is on**, per rule 8, which
  removes that carve-out and makes the file mandatory for **every** item).
- **If the request came with an image, record its path in the task file.** This applies **only**
  when you're actually writing a task `.md` under `.claude/tasks/$CLAUDE_CODE_SESSION_ID/` (per the
  bullet above). Never create a file just to store an image path, and don't add paths to the short
  TODO entry.
  - Put them near the top of the file, in an `## Images` section, as **absolute** paths, one per
    line, each with a one-line note on what it shows and why it matters for the item (e.g. `screen
    with the broken spacing`, `reference layout to reproduce`). Absolute, because you may be in a
    different working directory by the time you read it back.
  - **Re-read the image when you pick the item up**, and whenever the visual detail matters. That's
    the whole point of keeping the path: the image content is long gone from context by then, but
    the file is still on disk.
  - Only include images **actually related to that item**. If one image covers several items, repeat
    its path in each of their files. If a message brings an image but no task file is warranted,
    ignore this rule.
  - **When the image has no path** (pasted inline into the prompt rather than dragged/attached from
    disk, so there's no file on disk to point at), don't invent one and don't settle for a
    description: **save the image to disk yourself** and point the `## Images` entry at what you
    saved.
    - Save it **in the same directory as the task file**, `.claude/tasks/$CLAUDE_CODE_SESSION_ID/`
      and never anywhere else, with a kebab-case name tied to the item and the real extension (e.g.
      `.claude/tasks/$CLAUDE_CODE_SESSION_ID/refactor-auth-broken-spacing.png`). Same session
      isolation as the task files: only your own session's folder. Record it in `## Images` as an
      **absolute** path, with the same one-line note as any other image.
    - **Getting the bytes:** the image only exists in context as pixels, so pull it from the
      clipboard, where a just-pasted image is normally still there:

      ```bash
      wl-paste --type image/png > .claude/tasks/$CLAUDE_CODE_SESSION_ID/<name>.png   # Wayland
      xclip -selection clipboard -t image/png -o > .claude/tasks/$CLAUDE_CODE_SESSION_ID/<name>.png   # X11
      ```

      `wl-paste --list-types` (or `xclip -selection clipboard -t TARGETS -o`) tells you which image
      type is actually on the clipboard, so use that one instead of assuming PNG.
    - **Verify before recording the path.** The file must be non-empty and `file <path>` must report
      an image; then **read the saved file back** and confirm it's the image I sent. The clipboard is
      not a reliable channel: I may have copied something else since pasting, or pasted from a
      screenshot tool that never touched it. A wrong image recorded as the item's reference is worse
      than none.
    - **Fallback when nothing usable lands on disk** (clipboard empty, stale, holds something else,
      or no clipboard tool available): delete whatever you wrote, write a short **description** of
      the image in `## Images` marked `no path, pasted inline, could not be saved`, and tell me in
      one line so I can drag the file in.
- **When you no longer need one of these task files** (the item is done and the details won't be
  needed anymore), you **may delete it**, along with any image you saved next to it for that item. The same goes for the session folder itself: once you no
  longer need your `.claude/tasks/$CLAUDE_CODE_SESSION_ID/` directory (it's empty, or everything in
  it is done and won't be needed anymore), you **may delete the whole folder**. Only ever delete
  **your own** session's folder, never another session's.

### 6. Cancel only on an explicit request
- **Never** drop, skip, or silently deprioritize an item.
- The **only** reason to remove an item from the queue is me **explicitly asking to cancel it**
  (e.g., "cancel X", "drop X", "don't do Y anymore", or the explicit form
  **`/flow canceltask <task>`**).
- When I ask, remove **exactly that item** (if it's already in progress, stop it), tell me it was
  cancelled, and **carry on** with the rest of the queue as normal.

### 7. Contradictions: ask me
- If a new request **contradicts** another item in the queue (pending, in progress, **or already
  done**), e.g. "make the button blue" then "make the button red", or "remove Y" then "improve Y",
  **don't guess**.
- The moment you notice a possible contradiction, **flag it out loud in your reasoning/thinking**
  (name the two conflicting items) as soon as it comes up, so I can see it while you're still going.
- **If I see that and reply with a prompt resolving it before you'd ask** (telling you which one to
  do), just **follow my resolution, no question needed.** Only fall back to **stopping and asking
  me** (clearly, with the alternatives) if I *haven't* already clarified. If possible, **keep
  working through the rest of the queue** while you wait for my answer.
- Only treat it as a real contradiction when the requests are truly **incompatible**. Requests that
  merely add to or complement each other are **not** contradictions; just queue both.

### 8. `taskfiles` mode lives in its own command
There's an optional add-on, **off by default**, that makes **every** item, trivial ones included,
get its own `.md` **before** the work starts, re-read as you go, so I can edit it while you work.
Its rules are in **`/flow:taskfiles`** (`~/.claude/commands/flow/taskfiles.md`): read that file when
I turn it on, and treat its rules as sitting on top of these. Nothing here changes until I run it.

## Control subcommands
These are run as `/flow <keyword> [args]` while in FLOW MODE. When the argument is one of these
keywords, **don't treat it as a new work item**; carry out the control action instead. The mode
stays active (except for the exit keywords).

- **`/flow status`** shows the current queue grouped as `pending` / `in progress` / `done`. Just
  report it; don't add or run anything.
- **`/flow recap`** summarizes what's been **completed** so far (the `done` items), in a short
  readable list. Don't add or run anything.
- **`/flow clear`** cancels **all `pending` items at once** and stays in the mode. Since rule 6
  forbids silent drops, **confirm first** (show how many/which will be dropped). Don't touch an
  `in progress` item unless I say so; ask if I also want to stop it.
- **`/flow pause`** means **stop starting new work.** Bring any `in progress` item to a safe stopping
  point and hold. Keep **accepting and queueing** everything I send (rule 1 still applies), but
  don't execute until I resume. Confirm you're paused.
- **`/flow resume`** leaves the paused state and **starts working through the queue again** from
  where it left off, following the normal rules.
- **`/flow parallel [on|off]`** controls rule 4's parallelism. `on` (also the default when bare)
  lets you spawn parallel subagents for independent items; `off` forces **serial** execution (one
  item at a time, no parallel subagents). The setting persists until I change it or exit the mode.
- **`/flow:taskfiles [on|off] [first request]`** is rule 8's add-on, in its own command file. `on`
  (also the default when bare) makes **every** item get its own `.md` before the work starts; `off`
  goes back to rule 5's default. Read `~/.claude/commands/flow/taskfiles.md` for the full rules when
  I run it. The setting persists until I change it or exit the mode. `/flow taskfiles ...` (space
  instead of `:`) means the same thing, so dispatch it to that file.
- **`/flow defer <task>`** **deprioritizes** the matching task: move it to the **end** of the
  queue without cancelling it (if it's `in progress`, hold it and pick it up later). If `<task>` is
  ambiguous or matches no queued item, ask me which one I mean.
- **`/flow help`** lists all the subcommands with a one-line description of each (every keyword in
  this section, plus `canceltask <task>` and the exit keywords). Just print the list; don't add or
  run anything and don't change the mode.

## Exiting FLOW MODE
- I leave the mode by running the command again with an exit keyword as the argument, i.e.
  **`/flow end`**, **`/flow out`**, **`/flow off`**, **`/flow stop`**, or **`/flow exit`**
  (case-insensitive). Any of these **ends FLOW MODE**. I may also just say "exit flow" / "end flow"
  in plain words.
- When that happens, **do not** treat the keyword as a new work item. Instead, leave FLOW MODE:
  stop treating my messages as backlog items and stop applying the rules above.
- Before leaving, if there are still `pending` / `in progress` items, tell me what's left and ask
  whether you should **finish them first** or **drop them**, and don't silently discard queued work
  (that would violate rule 6). Once the queue is empty or I've decided, confirm in one line that
  you've exited FLOW MODE.

## On activation
Dispatch on `$ARGUMENTS` (first word, case-insensitive):
- **Exit keyword** (`end`, `out`, `stop`, `off`, `exit`): follow "Exiting FLOW MODE" above instead
  of entering the mode.
- **`canceltask <task>`**: don't treat it as a new work item; **cancel that specific task** per
  rule 6: find the item the `<task>` refers to, remove it from the queue (if it's already in
  progress, stop it), tell me it was cancelled, and **carry on** with the rest of the queue. If
  `<task>` is ambiguous or matches no queued item, ask me which one I mean.
- **A control keyword** (`status`, `recap`, `clear`, `pause`, `resume`, `parallel`, `taskfiles`,
  `defer`, `help`): don't treat it as a new work item; carry out the matching action from "Control
  subcommands" above. For `taskfiles`, read `~/.claude/commands/flow/taskfiles.md` and follow its
  own dispatch; it accepts a first request after the keyword (e.g.
  `/flow:taskfiles fix the login redirect`), meaning: enter FLOW MODE with the add-on on and queue
  the rest as the first work item.
- **Otherwise**: confirm in one line that you've entered **FLOW MODE**, create the initial TODO
  list (including the first request if it came in `$ARGUMENTS`/this message), and start working.
  From then on, follow the rules above for everything I send.
