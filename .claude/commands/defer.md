---
description: Wait a specified amount of time, then run the prompt I give you
argument-hint: [--durable] <time e.g. 10 | 10min | 10 minutes | hour> <prompt to run afterwards>
---

Defer a task: wait the amount of time I specify, then carry out the prompt I give you.

Everything I passed with the command: `$ARGUMENTS`

## How to read the arguments

- An optional **`--durable` flag** may appear anywhere (usually first). Strip it out before parsing
  the rest. When present, the defer must **survive session restarts** (see step 2).
- The **leading part** (after removing the flag) is a **duration**: a number optionally followed by a
  unit word, in **any language**.
- **Everything after the duration** is the **prompt** — what I want you to do once the time elapses.
- If a unit word appears with **no number** (e.g. `hour`, `hora`), treat the number as **1**.
- A **bare number with no unit** (e.g. `10`) means **seconds**.

### Parsing the duration into total seconds (N)

Identify the unit from keywords in **any language** (case-insensitive), then convert to total
seconds `N`:

- **seconds** — `s`, `sec`, `secs`, `second(s)`, `segundo(s)`, `seg`, … → ×1
- **minutes** — `m`, `min`, `mins`, `minute(s)`, `minuto(s)`, … → ×60
- **hours** — `h`, `hr`, `hrs`, `hour(s)`, `hora(s)`, … → ×3600
- **days** — `d`, `day(s)`, `dia(s)`, … → ×86400

Bare number → seconds. Examples:
- `10` → 10s
- `10min` / `10 minutes` / `10 minutos` → 600s
- `hour` / `1 hora` → 3600s
- `2h` → 7200s

If you can't find a valid duration, or there's no prompt after it, **ask me** — don't guess.

## Steps

### 1. Split and normalize
- Detect and strip the optional **`--durable`** flag; note whether it was present.
- Separate the rest of `$ARGUMENTS` into the leading **duration** and the trailing **prompt**.
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
  prompt exactly as if I had just typed it now — following my `CLAUDE.md` and the repo's conventions.
- **Cron path:** the harness enqueues the prompt for you at fire time; just execute it when it
  arrives.

### 4. Confirm
- Right after scheduling, tell me — **in the language I used** — what will run and when: both the
  delay and the absolute time (e.g. "em 10 min, às 14:23"), and whether it's **durable** (survives
  restart) or session-only. Keep it to one line.
