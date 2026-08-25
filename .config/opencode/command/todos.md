---
description: Collect TODO/FIXME markers into one grouped report with file:line references; filter by marker or path
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
- **Never read or scan `$HOME/.config/zsh/secrets`** (per my `CLAUDE.md`). Exclude it from the scan.

Follow exactly these steps:

## 0. Handle any extra requests first
- If I asked for other changes in the same message (before or after `/todos`), carry those out and
  get them working before scanning.

## 1. Determine scope and filter
- Resolve the argument into a marker filter or a path scope (default: whole repo, all markers).
- Confirm you're in a git repo (`git rev-parse --is-inside-work-tree`); if so, scan tracked files so
  `.gitignore` is honored and vendored/generated output is skipped.

## 2. Choose the search tool and markers
- Prefer `rg` (respects `.gitignore` and is fast); fall back to `grep -rn` if `rg` is unavailable.
- Search these markers, case-sensitive, as standalone words: `TODO`, `FIXME`, `HACK`, `XXX`, `BUG`,
  `OPTIMIZE`, `NOTE`. Match common forms too: `TODO:`, `TODO(name):`, `@todo`.
- Skip generated/vendored dirs even if not gitignored: `.git`, `node_modules`, `target`, `dist`,
  `build`, `vendor`.
- Example: `rg -n --word-regexp 'TODO|FIXME|HACK|XXX|BUG|OPTIMIZE|NOTE' <scope>`.

## 3. Run the scan and collect results
- Capture each hit as `file:line`, the marker type, any `(owner)` in `TODO(owner):`, and the comment
  text. Trim the surrounding comment syntax so the message reads cleanly.

## 4. (Optional) add context for prioritization
- For anything that looks stale or high-priority, you may add a light `git blame` note (who/when the
  line was introduced), but keep it brief; don't blame every single line.

## 5. Report, grouped and clickable
- Order by urgency: `FIXME`/`BUG`/`XXX` first, then `TODO`/`HACK`/`OPTIMIZE`, then `NOTE` last.
- For each finding show the `file:line` reference (clickable) and the message; group by marker type
  (or by file if that reads better for the result set).
- Start with a one-line summary of counts per marker (e.g. `3 FIXME · 12 TODO · 1 HACK`).
- If nothing is found, say so plainly.

## 6. (Optional) offer a follow-up, opt-in only
- Offer, but do **not** do automatically: turn the important items into a task list, or open issues
  for them, GitHub via `gh issue create` and GitLab via `glab issue create` (match whichever remote
  the repo has). Only create issues if I explicitly say yes.
