---
name: worklog
description: Summarize my recent commits into a work log/standup, grouped by commit type, over a chosen time window
argument-hint: [period | path]
allowed-tools: Bash(git*), Bash(gh*), Bash(glab*), Glob, Bash(~/.claude/skills/worklog/scripts/*), Bash(~/.claude/scripts/forge-detect.sh*)
---

Summarize what I've been working on lately by digesting my own commits into a readable work log,
the kind of thing I'd paste into a standup or a daily update.

Optional argument (`$ARGUMENTS`):
- a **period** → how far back to look: `today`, `yesterday` (default), `week`, a number of days
  (`3`), or any git `--since` expression (`"2 days ago"`).
- a **path** → a single repo, or a directory containing several repos to scan together.
(You may receive both, e.g. `week ~/code`.)

Separately, I may include **other requests** in the same message; those are not arguments, so do
them first, then build the log.

Follow exactly these steps:

## 0. Handle any extra requests first
- If I asked for other changes in the same message (before or after `/worklog`), carry those out and
  get them working before summarizing.

## 1. Collect the commits

```
~/.claude/skills/worklog/scripts/collect.py [period] [path] [--prs] [--stat]
```

Pass the period and path as given, in either order. The script resolves "me" from
`git config user.email`/`user.name` (a repo with a different identity is matched with its own and
flagged `identity_differs`: mention it), maps the period to `--since` (`today`/`yesterday` → 00:00
of that day, `week` → 7 days ago, `N` → N days ago, anything else verbatim), scans the current repo
or every repo under the path (3 levels deep), and runs
`git log --author=<me> --since=<window> --no-merges` per repo, parsing the Conventional Commit
subject. Repos with nothing to report are left out. `--stat` adds churn numbers if I want them.

```
{"window": {"period", "since"}, "identity", "scope", "scanned",
 "repos": [{"path", "identity", "identity_differs",
            "commits": [{"hash", "date", "type", "scope", "breaking", "subject", "files"?, "insertions"?, "deletions"?}],
            "prs"?: {"open": [{"forge", "number", "title", "url", "branch", "draft"}], "notes": [...]}}],
 "errors"?: [{"path", "error"}]}
```

Exit 1: no commits (and no PRs) anywhere in the window, so tell me that. Exit 2: bad argument
(e.g. a path that doesn't exist) or no git identity.

## 2. Summarize into a work log
- Group by **Conventional Commit type** (`feat`, `fix`, `refactor`, `docs`, `test`, `chore`, …),
  since that's how I write commits (`type: null` → "other"). Turn each into a short human-readable
  bullet, keeping the short hash for reference, and flag `breaking` ones. When scanning several
  repos, group by repo first, then by type.
- Aim for a readable narrative, not a raw hash dump: collapse trivial/related commits into one line
  where it reads better.

## 3. (Optional) include work in flight
- Add `--prs` in step 1 to list open PRs/MRs I authored as "in review". It only asks the forges
  whose remotes exist (`gh pr list --author @me`; GitLab needs my username, which it resolves with
  `glab api user`). A missing CLI or login just lands in `notes`; mention it briefly.

## 4. Output
- A clean, paste-ready summary: the window covered, then the grouped bullets. Lead with a one-line
  headline of what got done.
