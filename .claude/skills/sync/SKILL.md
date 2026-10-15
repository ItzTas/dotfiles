---
name: sync
description: Fetch with prune and rebase the current branch onto its base, handling dirty tree and conflicts; --all-branches fast-forwards the rest
argument-hint: [base-branch] [--all-branches]
allowed-tools: Bash(git*), Bash(~/.claude/skills/sync/scripts/*)
---

Sync the current branch with the remote: fetch the latest, prune gone refs, and rebase the branch
onto the up-to-date base so it's current.

This command takes optional arguments: `$ARGUMENTS`
- The **base branch** to rebase onto. If none is given, the script detects it.
- The flag **`--all-branches`** (also accept `--all` or a bare `all-branches`): besides syncing the
  current branch as usual, fast-forward **every other local branch** to its upstream (step 3).
- **Flag forms**, all equivalent: `--all-branches` = `-all-branches` = `-a` = `--all` = `-all` =
  bare `all-branches`.

Separately, I may include **other requests** in the same message, before or after `/sync`. Those
are not the argument; handle them as normal work.

## Steps

### 0. Handle any extra requests first
- If I asked for other changes in the same message, do those first.

### 1. Sync the current branch

```
~/.claude/skills/sync/scripts/sync.sh [base]
```

It refuses if a rebase/merge/cherry-pick is already in progress (or `HEAD` is detached), runs
`git fetch --all --prune`, picks the base (argument as `origin/<base>`, else `origin/HEAD`, else
`main`/`master`/`dev`, else the tracked branch), then rebases with
`git rebase --autostash origin/<base>`. **On the base branch itself** it only fast-forwards
(`git merge --ff-only --autostash`, i.e. `git pull --ff-only` after the fetch). Uncommitted
changes always ride `--autostash`, never discarded. It never pushes. Output:

```
{"status": "rebased"|"fast_forwarded"|"up_to_date"|"conflict"|"cannot_fast_forward"|"error"|"refused",
 "branch", "base", "base_ref", "base_source", "mode", "behind", "ahead", "replayed",
 "autostash": "none"|"reapplied"|"conflict_kept_in_stash"|"pending", "upstream", "force_push_needed",
 "conflicts"?, "stopped_at"?: {"sha", "subject"}, "reason"?, "message"?}
```

Exit 0 synced/up to date, 1 `conflict`/`cannot_fast_forward`/`error`, 2 `refused`:
- `refused`: tell me the `reason` and stop; don't start another rebase/merge.
- `cannot_fast_forward` (base branch has local commits) / `error` (git's `message`): report it.
- `conflict`: the rebase is left stopped at `stopped_at`. **Don't force anything**: report the
  `conflicts` files and help me resolve them, then continue (`git rebase --continue`). If I'd
  rather bail, `git rebase --abort` restores the pre-sync state (`autostash: "pending"` comes back
  either way).
- `autostash: "conflict_kept_in_stash"`: synced, but my changes clashed on re-apply; they're safe
  in `git stash list` and `conflicts` lists the files with markers. Tell me.

### 2. Push note (don't auto-push)
- If `force_push_needed`, the branch was already pushed and the rebase rewrote its history, so the
  next push needs `git push --force-with-lease`. **Tell me** this, and do not push on your own.

### 3. All-branches mode (only with `--all-branches`)
After step 1, run `~/.claude/skills/sync/scripts/ff-all.sh`. For every **other** local branch with
an upstream it runs `git fetch . <upstream>:<branch>` (fast-forward only, no checkout, never
rebases or forces) and prints `{"current", "branches": [{"branch", "upstream", "status":
"fast_forwarded"|"up_to_date"|"skipped", "commits"?, "ahead"?, "behind"?, "reason"?}]}`. Skipped:
- `diverged` (local + remote commits): tell me so I can rebase/merge it myself.
- `upstream_gone` (pruned): suggest deleting it if merged.
- `no_upstream`: nothing to sync against. `checked_out_in_worktree`: sync it in that worktree.

### 4. Summary
- Show the base it synced against, how many commits were replayed / how far behind it was, whether
  a stash was applied back, and whether a force-push is now needed.
- In all-branches mode, also list per branch: fast-forwarded (and by how many commits), already
  up to date, or skipped and why.
