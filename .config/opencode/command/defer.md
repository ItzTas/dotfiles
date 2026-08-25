---
description: Wait a specified amount of time, then run the prompt I give you
---

Defer a task: wait the amount of time I specify, then carry out the prompt I give you.

Everything I passed with the command: `$ARGUMENTS`

## How to read the arguments

- An optional **`--durable` flag** may appear anywhere (usually first). Strip it out before parsing
  the rest. When present, the defer must **survive session restarts** (see step 2).
- The **leading part** (after removing the flag) is a **duration**: a number optionally followed by a
  unit word, in **any language**.
- **Everything after the duration** is the **prompt**: what I want you to do once the time elapses.
- If a unit word appears with **no number** (e.g. `hour`, `hora`), treat the number as **1**.
- A **bare number with no unit** (e.g. `10`) means **seconds**.
- Instead of a duration, the first token may be the keyword **`final`** (or **`--final`**,
  **`afterall`**, **`--afterall`**, case-insensitive): that's not a time, it defers the prompt to
  the **end of the work queue** (see "Final mode" below).
- **Flag forms**, all equivalent: `--durable` = `-durable` = `-d`, `--final` = `-final` = `-f` =
  bare `final`, `--afterall` = `-afterall` = `-a` = bare `afterall`.

### Parsing the duration into total seconds (N)

Identify the unit from keywords in **any language** (case-insensitive), then convert to total
seconds `N`:

- **seconds**: `s`, `sec`, `secs`, `second(s)`, `segundo(s)`, `seg`, … → ×1
- **minutes**: `m`, `min`, `mins`, `minute(s)`, `minuto(s)`, … → ×60
- **hours**: `h`, `hr`, `hrs`, `hour(s)`, `hora(s)`, … → ×3600
- **days**: `d`, `day(s)`, `dia(s)`, … → ×86400

Bare number → seconds. Examples:
- `10` → 10s
- `10min` / `10 minutes` / `10 minutos` → 600s
- `hour` / `1 hora` → 3600s
- `2h` → 7200s

If you can't find a valid duration or the `final`/`afterall` keyword, or there's no prompt after
it, **ask me**; don't guess.

### Final mode (`final` / `afterall`): run at the end of the queue

`/defer final <prompt>` (or `--final`, `afterall`, `--afterall`) is **queue-based, not time-based**,
the `/flow`-compatible form of defer:

- Register the prompt as a **deferred final step**: add it to the **bottom** of the TODO list,
  pinned as the **last** item, the same end-of-queue behavior as my `/command` command (they share
  the queue position; several final defers and/or end-of-queue `/command`s run in the **order I
  gave them**).
- **With FLOW MODE active**, run it only when the whole backlog is **empty**. It stays after
  everything else no matter how many new items arrive in between.
- **Outside FLOW MODE**, run it once all the work currently pending/in progress in the session is
  finished.
- Nothing is scheduled by time in this mode, so don't use `sleep`/`CronCreate` (steps 2 and 3 don't
  apply). `--durable` doesn't apply either; if I combine them, treat it as session-only and tell me.

## Steps

### 1. Split and normalize
- Detect and strip the optional **`--durable`** flag; note whether it was present.
- If the first token is `final`/`--final`/`afterall`/`--afterall`, use **Final mode** (above) with
  everything after it as the prompt, and skip steps 2 and 3.
- Otherwise, separate the rest of `$ARGUMENTS` into the leading **duration** and the trailing
  **prompt**.
- Compute `N` (total seconds).

### 2. Schedule based on N (and durability)

**If `--durable` was passed:** the defer must survive a session restart, so `sleep`-in-background
won't work (it dies with the process). Always use `CronCreate` with **`durable: true`**, regardless
of `N`:
  - Compute the target clock time: run `date -d "+<N> seconds" +"%M %H %d %m"` → gives
    `minute hour day month`. Cron is minute-granularity, so if `N < 60`, just schedule the **next
    minute** and tell me the wait was rounded up.
  - Call `CronCreate` with `cron: "<M> <H> <dom> <month> *"`, `recurring: false`, `durable: true`,
    and `prompt` set to the **exact prompt I gave you**. It's written to
    `.claude/scheduled_tasks.json` and resumes on the next launch (missed one-shots are surfaced for
    catch-up).

**Otherwise (session-only, the default)** pick the mechanism by how long the wait is:

- **N ≤ 600 (≤ 10 minutes):** run `sleep <N>` with `Bash` and `run_in_background: true`. **Do not
  block** waiting on it. In the message where you launch it, clearly restate the deferred prompt, so
  that when the background command finishes and you're re-invoked, you know exactly what to run.
- **N > 600 (> 10 minutes):** schedule a one-shot with `CronCreate`:
  - Compute the target clock time: run `date -d "+<N> seconds" +"%M %H %d %m"` → gives
    `minute hour day month` (handles hour/day/month rollover for you).
  - Call `CronCreate` with `cron: "<M> <H> <dom> <month> *"`, `recurring: false`,
    `durable: false`, and `prompt` set to the **exact prompt I gave you** (so it runs verbatim at
    fire time).

### 3. When the time elapses
- **Sleep path:** once you're re-invoked after the background `sleep` exits, carry out the deferred
  prompt exactly as if I had just typed it now, following my `CLAUDE.md` and the repo's conventions.
- **Cron path:** the harness enqueues the prompt for you at fire time; just execute it when it
  arrives.

### 4. Confirm
- Right after scheduling, tell me, **in the language I used**, what will run and when: both the
  delay and the absolute time (e.g. "in 10 min, at 14:23"), and whether it's **durable** (survives
  restart) or session-only. For **Final mode**, say instead that it will run at the **end of the
  queue**. Keep it to one line.
