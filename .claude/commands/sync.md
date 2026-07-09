---
description: Bring the current branch up to date — fetch with prune and rebase onto the latest base branch, safely handling a dirty tree and conflicts
argument-hint: [base-branch]
allowed-tools: Bash(git*)
---

Sync the current branch with the remote: fetch the latest, prune gone refs, and rebase the branch
onto the up-to-date base so it's current.

This command takes a single optional argument — the **base branch** to rebase onto: `$ARGUMENTS`
If none is given, detect it (see step 2).

Separately, I may include **other requests** in the same message, before or after `/sync`. Those
are not the argument — handle them as normal work.

## Steps

### 0. Handle any extra requests first
- If I asked for other changes in the same message, do those first.

### 1. Fetch and prune
- Run `git fetch --all --prune` to update remote-tracking refs and drop ones deleted on the remote.

### 2. Determine the base branch
- If a base was given as the argument, use it (as `origin/<base>`).
- Otherwise detect the default branch — e.g. `git symbolic-ref --short refs/remotes/origin/HEAD`
  (fallbacks: `main`, `master`, `dev`) — or the branch this one tracks.
- **If I'm currently ON the base branch itself**, don't rebase onto itself — just fast-forward it to
  its upstream (`git pull --ff-only`). Report if it can't fast-forward.

### 3. Guard the working tree and repo state
- If a rebase/merge is already in progress (`git status`), stop and tell me — don't start another.
- If there are uncommitted changes, use rebase **`--autostash`** (or stash → rebase → pop) so my
  work isn't lost. Never discard uncommitted changes.

### 4. Rebase onto the base
- Rebase the current branch onto the freshly fetched base: `git rebase --autostash origin/<base>`.

### 5. Handle conflicts
- If the rebase stops on conflicts, **don't force anything**: report which files conflict and help
  me resolve them, then continue (`git rebase --continue`). If I'd rather bail, `git rebase --abort`
  restores the pre-sync state.

### 6. Push note (don't auto-push)
- If the branch was already pushed, rebasing rewrote its history, so the next push needs
  `git push --force-with-lease`. **Tell me** this — do not push on your own.

### 7. Summary
- Show the base it synced against, how many commits were replayed / how far behind it was, whether
  a stash was applied back, and whether a force-push is now needed.
