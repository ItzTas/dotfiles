---
description: Fetch with prune and rebase the current branch onto its base, handling dirty tree and conflicts; --all-branches fast-forwards the rest
argument-hint: [base-branch] [--all-branches]
allowed-tools: Bash(git*)
---

Sync the current branch with the remote: fetch the latest, prune gone refs, and rebase the branch
onto the up-to-date base so it's current.

This command takes optional arguments: `$ARGUMENTS`
- The **base branch** to rebase onto. If none is given, detect it (see step 2).
- The flag **`--all-branches`** (also accept `--all` or a bare `all-branches`): besides syncing the
  current branch as usual, fast-forward **every other local branch** to its upstream (see step 4b).
- **Flag forms**, all equivalent: `--all-branches` = `-all-branches` = `-a` = `--all` = `-all` =
  bare `all-branches`.

Separately, I may include **other requests** in the same message, before or after `/sync`. Those
are not the argument; handle them as normal work.

## Steps

### 0. Handle any extra requests first
- If I asked for other changes in the same message, do those first.

### 1. Fetch and prune
- Run `git fetch --all --prune` to update remote-tracking refs and drop ones deleted on the remote.

### 2. Determine the base branch
- If a base was given as the argument, use it (as `origin/<base>`).
- Otherwise detect the default branch, e.g. with `git symbolic-ref --short refs/remotes/origin/HEAD`
  (fallbacks: `main`, `master`, `dev`), or use the branch this one tracks.
- **If I'm currently ON the base branch itself**, don't rebase onto itself; just fast-forward it to
  its upstream (`git pull --ff-only`). Report if it can't fast-forward.

### 3. Guard the working tree and repo state
- If a rebase/merge is already in progress (`git status`), stop and tell me; don't start another.
- If there are uncommitted changes, use rebase **`--autostash`** (or stash → rebase → pop) so my
  work isn't lost. Never discard uncommitted changes.

### 4. Rebase onto the base
- Rebase the current branch onto the freshly fetched base: `git rebase --autostash origin/<base>`.

### 4b. All-branches mode (only with `--all-branches`)
- After syncing the current branch, update every **other** local branch that tracks an upstream,
  **fast-forward only**, never rebasing or forcing branches that aren't checked out:
  - List them: `git for-each-ref refs/heads --format='%(refname:short) %(upstream:short) %(upstream:track)'`.
  - For each branch (skipping the current one), fast-forward it without checking it out:
    `git fetch . <upstream>:<branch>`, which refuses non-fast-forward updates, exactly what we
    want.
- **Skip and report** (don't touch):
  - Branches that have **diverged** from their upstream (local commits + remote commits), where a
    fast-forward is impossible; tell me so I can rebase/merge them myself.
  - Branches whose upstream is **gone** (pruned); suggest deleting them if merged.
  - Branches with **no upstream**, which have nothing to sync against.

### 5. Handle conflicts
- If the rebase stops on conflicts, **don't force anything**: report which files conflict and help
  me resolve them, then continue (`git rebase --continue`). If I'd rather bail, `git rebase --abort`
  restores the pre-sync state.

### 6. Push note (don't auto-push)
- If the branch was already pushed, rebasing rewrote its history, so the next push needs
  `git push --force-with-lease`. **Tell me** this, and do not push on your own.

### 7. Summary
- Show the base it synced against, how many commits were replayed / how far behind it was, whether
  a stash was applied back, and whether a force-push is now needed.
- In all-branches mode, also list per branch: fast-forwarded (and by how many commits), already
  up to date, or skipped (diverged / upstream gone / no upstream) and why.
