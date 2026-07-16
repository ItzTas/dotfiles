---
description: Revert a pushed commit, range, or PR/MR merge via revert commits (no history rewriting), pushing only after I confirm
argument-hint: [commit sha | range | PR/MR number | last]
allowed-tools: Bash(git*), Bash(gh*), Bash(glab*), Read, Glob, Grep
---

Undo a change that's **already been pushed** by creating a revert commit — the safe way, without
rewriting shared history. (If the commit hasn't been pushed yet, `/uncommit` is the better tool — this
one is for history that's already public.)

Argument (`$ARGUMENTS`): what to revert —
- a **commit SHA**, or a **range** (`a..b`),
- a **PR/MR number** → revert its merge commit,
- `last` or nothing → the last commit (`HEAD`).

Separately, I may include **other requests** in the same message; those are not the argument — do
them first, then revert.

Follow exactly these steps:

## 0. Handle any extra requests first
- If I asked for other changes in the same message (before or after `/revert`), do those and get them
  working before reverting.

## 1. Resolve the target
- Turn the argument into concrete commit(s): a SHA, a range, `HEAD`, or — for a PR/MR number — find
  its **merge commit** (GitHub: `gh pr view <n> --json mergeCommit`; GitLab: `glab mr view <n>`).

## 2. Inspect before acting
- Show what will be undone: `git show --stat <target>` (or `git log --oneline <range>`).
- Flag any target that is a **merge commit** — reverting it needs a mainline parent (`git revert -m 1
  <sha>`); confirm the mainline with me if unsure.
- Confirm the target is actually **pushed**. If it's local-only/unpushed, stop and point me to
  `/uncommit` instead — a revert commit there would just add noise.

## 3. Safety checks
- `git revert` needs a **clean working tree**. If it's dirty, ask me to stash or commit first — don't
  revert on top of unrelated uncommitted work.

## 4. Confirm the plan (outward-facing)
- Present: the commit(s) to revert, whether it's a merge (`-m 1`), and whether to make one combined
  revert or one revert per commit for a range. **Ask before running** — this will end up pushed.

## 5. Revert
- Run `git revert` for the target(s): `-m 1` for merges; `--no-commit` to combine a range into a
  single revert if I chose that.
- Write the message per my `~/.claude/commands/git-conventions.md` (Conventional Commits, imperative, **no** `Co-Authored-By`),
  e.g. `revert: <original subject>` and reference the reverted SHA in the body.
- If there are **conflicts**, guide me through resolving them, then `git revert --continue`. Never
  `--abort` silently — tell me if I need to bail.

## 6. Push
- **Branch handling** (per my `~/.claude/commands/git-conventions.md`): if I'm on a protected branch (`main`/`master`/`dev`/
  `develop`/`pre-homolog`), ask whether to push the revert directly or open it via a branch + PR/MR —
  don't silently push to a protected branch.
- Otherwise push the revert commit(s).

## 7. Report
- Summarize what was reverted, the new revert commit(s), and the push/PR link. Note that the original
  history is intact (revert adds a commit, it doesn't rewrite).
