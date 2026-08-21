---
description: Prune local branches already merged (or whose upstream is gone) and clean stale remote-tracking refs, never touching protected branches
argument-hint: [base-branch]
allowed-tools: Bash(git*), Bash(gh*), Bash(glab*), Read, Glob
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

## 1. Determine the base branch
- If a base branch was given as the argument, use it.
- Otherwise, infer the repo's default branch from `git symbolic-ref refs/remotes/origin/HEAD`
  (fall back to `main`, then `master`). Tell me which base you picked; if you can't infer one, **ask me**.

## 2. Define what must never be deleted
- **Protected branches** (per my `~/.claude/rules/git-conventions.md`): `main`, `master`, `dev`, `develop`, `pre-homolog`,
  plus the chosen base branch.
- **The current branch**: get it with `git branch --show-current` and always exclude it.
- Anything in this set is off-limits no matter what the later steps find.

## 3. Refresh remotes and prune stale tracking refs
- Run `git fetch --all --prune` to update refs and drop remote-tracking branches that no longer
  exist on the remote (this only cleans local `origin/*` refs; it does not touch the remote).

## 4. Find deletion candidates
Build two lists, always subtracting the never-delete set from step 2:
- **Merged**: branches fully merged into the base, from `git branch --merged <base>`. These are safe
  to delete with `git branch -d`.
- **Gone upstream**: branches whose tracked upstream no longer exists (typically squash-merged
  PRs/MRs, which `--merged` won't catch): parse `git branch -vv` for entries marked `[gone]`. These
  require a force delete (`git branch -D`), so treat them as higher-risk.
- Optional confirmation: for a `[gone]` branch, you may check whether its PR/MR was actually merged
  before force-deleting: GitHub via `gh pr list --state merged --head <branch>`, GitLab via
  `glab mr list --source-branch <branch>`. Use this only to reassure me; don't block on it.

## 5. Show the plan and confirm
- Present two clearly separated lists: **merged (safe delete)** and **gone upstream (force delete)**.
- If both lists are empty, tell me there's nothing to prune and stop.
- **Ask for my confirmation before deleting anything.** Let me approve deleting only the merged set,
  only the gone set, both, or nothing.

## 6. Delete what I approved
- Merged branches: `git branch -d <branch>` (it aborts if the branch isn't truly merged, which is what we want).
- Gone-upstream branches: `git branch -D <branch>` only after explicit approval, since `-D` forces.
- Do **not** delete any remote branches (`git push --delete`) unless I explicitly ask; this command
  only cleans up locally.

## 7. Report
- Summarize what was pruned: which branches were deleted, which were kept and why (protected /
  current / not approved), and that stale tracking refs were cleaned.
- Optionally show the remaining branches with `git branch -vv`.
