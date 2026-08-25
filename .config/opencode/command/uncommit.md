---
description: Safely undo the last commit(s) with a soft reset, keeping all changes in the working tree
---

Undo the last commit (or the last `n` commits) **without losing any work**. The changes stay in
the working tree so I can re-commit, edit, or split them.

This command takes a single optional argument, how many commits to undo: `$ARGUMENTS`
If no number is given, undo **one** commit.

Separately, I may include **other requests** in the same message, before or after `/uncommit`. Those
are not the argument; handle them as normal work.

## Steps

### 1. Parse the count
- Read `$ARGUMENTS`. If it's a positive integer `n`, undo that many commits. Otherwise default to `1`.

### 2. Show what will be undone
- Run `git log --oneline -n <count+1>` so I can see exactly which commit(s) will be undone and
  what the new `HEAD` will be.
- Run `git status` to confirm the current state.

### 3. Safety checks (warn, don't silently proceed)
- If there are **fewer commits** than requested (e.g. undoing 3 but the branch has 2), or `HEAD`
  would go past the **root commit**, stop and tell me. Do not force it.
- If any of the commit(s) to undo is a **merge commit**, point it out and ask me how to proceed
  before resetting.
- If the commit(s) have **already been pushed** to the remote (compare `HEAD` against the tracking
  branch, e.g. `git status -sb` / `git rev-list @{u}..HEAD`), warn me that undoing them rewrites
  pushed history and will require a force-push later. Ask before proceeding in that case.

### 4. Undo
- Run `git reset --soft HEAD~<count>`.
- **Always use `--soft`.** Never `--mixed --hard` or anything that discards working-tree or staged
  changes. The whole point is to keep my work intact.

### 5. Summary
Confirm the new `HEAD` (`git log --oneline -n 1`) and the working-tree state (`git status`), so I
can see the undone changes are staged and nothing was lost.
