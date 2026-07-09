---
description: Create a new branch and implement whatever I ask on it
argument-hint: <branch-name>
allowed-tools: Bash(git*), Read, Edit, Write, Glob, Grep, Bash
---

Create a **new branch** and implement the request I make in this same message **on that branch**.

This command takes a single argument — the **name of the new branch** to create: `$ARGUMENTS`
(This mirrors the argument of my `/pr` command.)

**What to implement comes from the rest of my message** — anything I write besides the branch name,
before or after `/implement` (e.g. "`/implement feat-x` do this, that and the other" or "do this,
that and the other `/implement feat-x`"). Treat all of that as the work to build on the new branch.

This command exists precisely to honor my `CLAUDE.md` rule of never working directly on a
protected branch: it always branches first. I plan to combine it with `/pr` in one prompt (e.g.
`/implement feat-x do X /pr main`) to go from idea to PR in a single shot.

## Steps

### 1. Determine the new branch name
- If a branch name was given as the argument, use it.
- If **no** name was given, derive a sensible **kebab-case** name from what I asked (short and
  descriptive, e.g. `fix-login-redirect`), tell me the name you chose, and proceed — branch names
  are cheap and easy to rename, so don't block on this.

### 2. Create and switch to the branch
- Create the branch from the current `HEAD` and switch to it: `git switch -c <name>`.
- If a branch with that name already exists, don't clobber it — switch to it if it's clearly the
  same work, otherwise ask me how to proceed.
- Do **not** commit onto whatever protected branch I was on — the whole point is to move to the new
  branch first.

### 3. Implement the request
- Carry out everything I asked, on the new branch. Make the changes and **get them working**.
- Follow my `CLAUDE.md` code style (guard clauses over nesting, a map over `switch`/`if-else` for
  simple key→value) and any per-project conventions in the repo.

### 4. Commit the work
- **If this same message also invokes `/pr` or `/commit`,** do the branching and implementation
  here and leave the committing/pushing/PR to that command — don't duplicate it.
- **Otherwise,** commit the changes following my `CLAUDE.md` rules: atomic commits, Conventional
  Commits in the imperative, **no** `Co-Authored-By` or any attribution to you, and `feat:` used
  sparingly. Do **not** push or open a PR unless `/pr` was also invoked.

### 5. Summary
- Show the new branch name, what was implemented, and whether it was committed (list the commit
  messages) — or, if `/pr`/`/commit` will handle that, note that it's being handed off.
