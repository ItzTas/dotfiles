---
name: prune-branches
description: Prune local branches already merged (or whose upstream is gone) and clean stale remote-tracking refs, never touching protected branches
argument-hint: [base-branch]
allowed-tools: Bash(git*), Bash(gh*), Bash(glab*), Read, Glob, Bash(~/.claude/skills/prune-branches/scripts/*), Bash(~/.claude/scripts/forge-detect.sh*)
---

Clean up the local branch list: delete branches that are already merged (or whose remote upstream is
gone) and drop stale remote-tracking references, so only live work remains.

This command takes a single optional argument, the base branch to measure "merged" against: `$ARGUMENTS`

Separately, I may include **other requests** in the same message, either before or after the
`/prune-branches` invocation. Those are not command arguments; they are work to do first.

**Safety first:** deleting branches is destructive. Never delete without showing me the list and
getting my confirmation, and never delete a protected branch or the branch I'm currently on.

Follow exactly these steps:

## 0. Handle any extra requests first
- If, in the same message, I asked for other changes (anything besides the base branch, whether it
  came before or after `/prune-branches`), **carry those out first** and get them working.
- Only after that should you proceed with the steps below.

## 1. Find the candidates

```
~/.claude/skills/prune-branches/scripts/candidates.sh [base] [--no-fetch] [--check-prs]
→ {"base", "base_ref", "base_source": "argument"|"origin/HEAD"|"fallback", "current",
   "fetch": "ok"|"failed"|"skipped", "protected": [{"branch", "reason"}],
   "merged": [{"branch", "upstream", "upstream_gone", "last_commit": {"date", "subject"}}],
   "gone":   [{"branch", "upstream", "last_commit", "pr"?: {"status": "merged"|"none"|"unknown", "number", "url", "notes"}}]}
```

- It runs `git fetch --all --prune` first (only cleans local `origin/*` refs; never touches the
  remote). If `fetch` is `"failed"`, tell me the lists reflect the last successful fetch.
- Base: the argument if I gave one, else `origin/HEAD`, else `main`, then `master`. Tell me which
  base it picked (`base_source`). **Exit 2** "cannot determine the base branch": **ask me**, then
  rerun with it.
- The never-delete set is subtracted by the script and listed in `protected`: `main`, `master`,
  `dev`, `develop`, `pre-homolog` (per my `~/.claude/rules/git-conventions.md`), the base, the
  current branch, and branches checked out in another worktree.
- `merged`: fully merged into `base_ref`, safe for `git branch -d`. `gone`: upstream no longer
  exists and not merged (typically squash-merged PRs/MRs), so they need `git branch -D`: higher risk.
- `--check-prs` (optional) looks up a merged PR/MR per gone branch via `gh`/`glab`. Use it only to
  reassure me; `"unknown"` (no CLI, no auth, no forge remote) never blocks anything.

## 2. Show the plan and confirm
- Present two clearly separated lists: **merged (safe delete)** and **gone upstream (force delete)**.
- If both lists are empty, tell me there's nothing to prune and stop.
- **Ask for my confirmation before deleting anything.** Let me approve deleting only the merged set,
  only the gone set, both, or nothing.

## 3. Delete what I approved
- Merged branches: `git branch -d <branch>` (it aborts if the branch isn't truly merged, which is
  what we want). `-d` checks the branch's upstream or `HEAD`, not the base, so it may refuse one the
  script verified against the base (e.g. upstream gone, I'm not on the base): report it and ask
  before using `-D`.
- Gone-upstream branches: `git branch -D <branch>` only after explicit approval, since `-D` forces.
- Do **not** delete any remote branches (`git push --delete`) unless I explicitly ask; this command
  only cleans up locally.

## 4. Report
- Summarize what was pruned: which branches were deleted, which were kept and why (protected /
  current / worktree / not approved), and that stale tracking refs were cleaned.
- Optionally show the remaining branches with `git branch -vv`.
