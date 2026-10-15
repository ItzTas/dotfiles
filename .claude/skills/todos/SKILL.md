---
name: todos
description: Collect TODO/FIXME markers into one grouped report with file:line references; filter by marker or path
argument-hint: [marker | path]
allowed-tools: Bash(~/.claude/skills/todos/scripts/*), Bash(rg*), Bash(git*), Bash(gh*), Bash(glab*), Grep, Glob, Read
---

Gather all the loose TODO/FIXME-style markers left in the codebase into one place so I can see what's
still pending, where it is, and how urgent it looks.

Optional argument (`$ARGUMENTS`):
- no argument → scan the whole repo for every known marker.
- a **marker** (e.g. `FIXME`, `HACK`, `BUG`) → report only that marker.
- a **path** (file, dir, or glob) → limit the scan to that path.
(If the argument matches a known marker keyword, treat it as a marker filter; otherwise treat it as
a path.)

Separately, I may include **other requests** in the same message; those are not arguments, so do
them first, then run the scan.

## Guardrail
- **Never read or scan `$HOME/.config/zsh/secrets`** (per my `CLAUDE.md`). The script excludes it;
  keep it out of any manual search too.

Follow exactly these steps:

## 0. Handle any extra requests first
- If I asked for other changes in the same message (before or after `/todos`), carry those out and
  get them working before scanning.

## 1. Run the collector
```
~/.claude/skills/todos/scripts/collect.py [--limit N] [marker | path | 'glob' ...]
```
- Pass `$ARGUMENTS` through; it tells markers from paths as above (`fixme` = `FIXME` unless a path
  by that name exists). **Quote globs** (`'src/**/*.ts'`) so the script expands them.
- Default scope: repo root (else cwd). Uses `rg` (honors `.gitignore`), else `grep -r` (`tool` says
  which); always skips `.git`, `node_modules`, `target`, `dist`, `build`, `vendor`.
- Markers: `TODO`, `FIXME`, `HACK`, `XXX`, `BUG`, `OPTIMIZE`, `NOTE` (case-sensitive standalone
  words) plus `@todo`, counted only when opening a comment or in `TODO:`/`TODO(name):` form, so
  `todoList`, `MY_NOTE`, enum values and mid-sentence words are dropped.
- stdout JSON: `{tool, paths, markers, counts, total, items: [{marker, urgency, file, line, owner,
  text}], truncated?}`; items come in urgency order (`FIXME`/`BUG`/`XXX`, `TODO`/`HACK`/`OPTIMIZE`,
  `NOTE`), then file/line, with cwd-relative `file` and comment syntax trimmed from `text`. Lists
  300 items (`--limit 0` = all); `counts`/`total` cover everything. Exit `0`, `2` on usage errors.

## 2. (Optional) add context for prioritization
- For anything that looks stale or high-priority, you may add a light `git blame` note (who/when the
  line was introduced), but keep it brief; don't blame every single line.

## 3. Report, grouped and clickable
- Start with a one-line summary of counts per marker (e.g. `3 FIXME · 12 TODO · 1 HACK`).
- For each finding show the `file:line` reference (clickable) and the message; group by marker type
  (or by file if that reads better for the result set).
- If `truncated` is set, say how many more there are. If nothing is found, say so plainly.

## 4. (Optional) offer a follow-up, opt-in only
- Offer, but do **not** do automatically: turn the important items into a task list, or open issues
  for them, GitHub via `gh issue create` and GitLab via `glab issue create` (match whichever remote
  the repo has). Only create issues if I explicitly say yes.
