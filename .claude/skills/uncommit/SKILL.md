---
name: uncommit
description: Safely undo the last commit(s) with a soft reset, keeping all changes in the working tree
argument-hint: [n]
allowed-tools: Bash(git*), Bash(~/.claude/skills/uncommit/scripts/*)
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

```
~/.claude/skills/uncommit/scripts/preflight.sh [n]
→ {"count", "branch", "commits": [{"sha", "subject", "is_merge", "pushed"}], "new_head": {"sha", "subject"},
   "enough_history", "upstream", "pushed", "in_progress", "blocking": [...], "warnings": [...]}
```

Show me the commit(s) to undo (newest first, the first-parent line `HEAD~n` drops) and the new
`HEAD`, and run `git status` to confirm the current state.

### 3. Safety checks (warn, don't silently proceed)
- **Exit 1 / non-empty `blocking`**: stop and tell me. That's fewer commits than requested or going
  past the **root commit** (`enough_history: false`), no commits yet, or a rebase/merge in
  progress. Do not force it.
- `warnings` need my answer first: a **merge commit** among them (point it out, ask how to
  proceed), or commits **already pushed** (`pushed` > 0 vs `upstream`): undoing them rewrites
  pushed history and will require a force-push later. Ask before proceeding. `pushed: null` means
  there's no upstream to compare against.

### 4. Undo
- Run `git reset --soft HEAD~<count>`.
- **Always use `--soft`.** Never `--mixed --hard` or anything that discards working-tree or staged
  changes. The whole point is to keep my work intact.

### 5. Summary
Confirm the new `HEAD` (`git log --oneline -n 1`) and the working-tree state (`git status`), so I
can see the undone changes are staged and nothing was lost.
