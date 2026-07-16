---
description: Summarize my recent commits into a work log/standup, grouped by commit type, over a chosen time window
argument-hint: [period | path]
allowed-tools: Bash(git*), Bash(gh*), Bash(glab*), Glob
---

Summarize what I've been working on lately by digesting my own commits into a readable work log —
the kind of thing I'd paste into a standup or a daily update.

Optional argument (`$ARGUMENTS`):
- a **period** → how far back to look: `today`, `yesterday` (default), `week`, a number of days
  (`3`), or any git `--since` expression (`"2 days ago"`).
- a **path** → a single repo, or a directory containing several repos to scan together.
(You may receive both, e.g. `week ~/code`.)

Separately, I may include **other requests** in the same message; those are not arguments — do them
first, then build the log.

Follow exactly these steps:

## 0. Handle any extra requests first
- If I asked for other changes in the same message (before or after `/worklog`), carry those out and
  get them working before summarizing.

## 1. Identify "me"
- Get the author identity from `git config user.email` (and `user.name`) and use it as the
  `--author` filter. If a scanned repo uses a different identity, note it and match that repo's.

## 2. Determine the time window
Map the period argument to a `--since` value (default `yesterday`):
- `today` → since 00:00 today · `yesterday` → since yesterday (covers yesterday and today) ·
  `week` → since 7 days ago · a bare number `N` → since `N days ago` · anything else → pass through
  to `--since` verbatim.

## 3. Determine the scope
- Default: the current repo.
- If given a path (or run from a directory that holds several repos), find each git repo beneath it
  and process them all, labeling output per repo.

## 4. Collect the commits
- For each repo: `git log --author="<me>" --since="<window>" --no-merges --pretty=format:'%h %s'`
  (add `--stat`/`--shortstat` if I want churn numbers).
- Skip repos with no matching commits silently unless none of them have any.

## 5. Summarize into a work log
- Group by **Conventional Commit type** (`feat`, `fix`, `refactor`, `docs`, `test`, `chore`, …),
  since that's how I write commits — turn each into a short human-readable bullet, keeping the short
  hash for reference. When scanning several repos, group by repo first, then by type.
- Aim for a readable narrative, not a raw hash dump: collapse trivial/related commits into one line
  where it reads better.

## 6. (Optional) include work in flight
- Briefly list open PRs/MRs I authored as "in review", only if the corresponding remote exists:
  - GitHub: `gh pr list --author "@me"` (`@me` is valid here).
  - GitLab: `glab`'s `--author` takes a **username**, not `@me` (only `--assignee`/`--reviewer`
    accept `@me`). Resolve my username first — `glab api user --jq .username` — and pass it:
    `glab mr list --author=<username>`.

## 7. Output
- A clean, paste-ready summary: the window covered, then the grouped bullets. Lead with a one-line
  headline of what got done.
