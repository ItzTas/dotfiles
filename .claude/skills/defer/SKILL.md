---
name: defer
description: Wait a specified amount of time, then run the prompt I give you
argument-hint: [--durable] <time e.g. 10 | 10min | 10 minutes | hour, or final|afterall> <prompt to run afterwards>
---

Defer a task: wait the amount of time I specify, then carry out the prompt I give you.

Everything I passed with the command: `$ARGUMENTS`

## How the arguments read

- An optional **`--durable` flag** (`-durable`, `-d`) may appear anywhere (usually first). With it,
  the defer must **survive session restarts**.
- Then a **duration**: a number optionally followed by a unit word in **any language** (`10`,
  `10min`, `10 minutos`, `2h`, `1 dia`). A bare number is **seconds**; a unit with no number
  (`hour`, `hora`) is **1** of it.
- **Everything after the duration** is the **prompt**: what I want you to do once the time elapses.
- Instead of a duration, the keyword **`final`** (`--final`, `-final`, `-f`) or **`afterall`**
  (`--afterall`, `-afterall`, `-a`), case-insensitive, defers the prompt to the **end of the work
  queue** (see "Final mode").

## 1. Parse

Pass `$ARGUMENTS` to the parser as **one** single-quoted argument (write a `'` inside it as `'\''`):

```
~/.claude/skills/defer/scripts/parse.py '<$ARGUMENTS>'
→ {"mode": "sleep|cron|final", "durable": bool, "seconds": N, "rounded_up": bool,
   "cron": "M H dom month *", "fire_at": "<local ISO>", "fire_at_hhmm": "HH:MM",
   "prompt": "…", "warning": null|"…"}
```

It already applies the rules: `N ≤ 600` → `sleep`; `N > 600` → `cron`; `--durable` → always
`cron` (a wait under 60 s moves to the next minute, `rounded_up: true`); `final` → `final`, where
`--durable` doesn't apply (`warning` says so: tell me it's session-only). `cron` and `fire_at`
handle hour/day/month/year rollover. **Exit 2** prints `{"error": "missing_duration" |
"missing_prompt" | "duration_too_long", "message"}`: **ask me**; don't guess.

## 2. Schedule by `mode`

- **`sleep`**: run `sleep <seconds>` with `Bash` and `run_in_background: true`. **Do not block**
  waiting on it. In the message where you launch it, clearly restate the deferred prompt, so that
  when the background command finishes and you're re-invoked, you know exactly what to run.
- **`cron`**: call `CronCreate` with `cron` from the output, `recurring: false`, `durable` from the
  output, and `prompt` set to the **exact prompt** (so it runs verbatim at fire time). A durable one
  is written to `.claude/scheduled_tasks.json` and resumes on the next launch (missed one-shots are
  surfaced for catch-up); `sleep` in the background can't survive a restart, which is why durable
  always goes through cron.
- **`final`** (queue-based, not time-based; the `/flow`-compatible form of defer): register the
  prompt as a **deferred final step**, at the **bottom** of the TODO list, pinned as the **last**
  item, the same end-of-queue behavior as my `/command` command (they share the queue position;
  several final defers and/or end-of-queue `/command`s run in the **order I gave them**). **With
  FLOW MODE active**, run it only when the whole backlog is **empty**, no matter how many new items
  arrive in between. **Outside FLOW MODE**, run it once all the work currently pending/in progress
  in the session is finished. No `sleep`/`CronCreate` here.

## 3. When the time elapses
- **Sleep path:** once you're re-invoked after the background `sleep` exits, carry out the deferred
  prompt exactly as if I had just typed it now, following my `CLAUDE.md` and the repo's conventions.
- **Cron path:** the harness enqueues the prompt for you at fire time; just execute it when it
  arrives.

## 4. Confirm
- Right after scheduling, tell me, **in the language I used**, what will run and when: both the
  delay and the absolute time (`fire_at_hhmm`, e.g. "in 10 min, at 14:23"), and whether it's
  **durable** (survives restart) or session-only; mention a `rounded_up` wait. For **Final mode**,
  say instead that it will run at the **end of the queue**. Keep it to one line.
