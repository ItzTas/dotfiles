---
name: commit
description: Commit everything as atomic Conventional Commits; flags: wip/quick/fast, fastest, detailed, verbose, push, pr, merge, force
argument-hint: [wip|quick|fast|fastest|quickest] [detailed|verbose] [push] [pr] [merge] [force]
allowed-tools: Bash(git*), Bash(gh*), Bash(glab*), Bash(yadm*), Read, Glob, Bash(~/.claude/skills/commit/scripts/*), Bash(~/.claude/skills/pr/scripts/*), Bash(~/.claude/scripts/forge-checks.sh*)
---

Commit all pending changes following the commit rules in my `~/.claude/rules/git-conventions.md`
(atomic commits, Conventional Commits `type(scope): description` in the imperative,
**no** `Co-Authored-By` or any attribution to you, since the commit is solely mine, and
`feat:` used sparingly).

This command takes zero or more **flags** as arguments: `$ARGUMENTS`

Flags may appear in **any order** and **more than one** may be given
(e.g. `/commit wip push`, `/commit fast pr`, `/commit quick push pr`, `/commit fastest`,
`/commit detailed`, `/commit detailed push`, `/commit verbose`, `/commit verbose pr`,
`/commit pr merge`, `/commit pr force`).

Separately, I may include **other requests** in the same message, either before or after the
`/commit` invocation (e.g. "do this, that and the other `/commit`" or "`/commit` do this, that
and the other"). Those are **not** flags; they are work to do first.

## Flags

- **`wip`** is work-in-progress checkpoint mode. Commit **quickly, without overthinking**: don't
  deliberate over the perfect split or message wording. Still honor my standards though: commits
  must stay **atomic** and **Conventional Commits** compliant. This is meant to be fast; favor a
  reasonable grouping over a perfect one.
- **`quick`** / **`fast`** are synonyms for the fast behavior: commit quickly without spending too
  long, while still keeping commits atomic and Conventional-Commits compliant. Treat these the
  same as `wip`'s speed behavior.
- **`fastest`** / **`quickest`** mean **as fast as you possibly can.** Stronger than `wip`/`quick`/
  `fast`: skip the analysis entirely, don't read through the diffs looking for the right split,
  just glance at `git status --short` and go. Group by whatever is obvious from the file paths.
  Unlike the other fast modes, atomicity is **best-effort** here: keep the split when it's
  self-evident, but if separating the changes would cost real thinking time, bundle them into a
  single commit instead. Conventional Commits (`type(scope): description`, imperative) still
  applies, with a short, correct-enough subject line and no body. Speed beats precision in this
  mode; asking for `fastest` is me accepting a rougher split in exchange for it.
- **`detailed`** writes **richly detailed** commit messages. Beyond the Conventional Commits
  subject line, give **every** commit a full body: a blank line after the subject, then a wrapped
  (~72 col) prose/bulleted body explaining **what** changed and **why** (the motivation and
  context, not a restatement of the diff), and relevant footers (`BREAKING CHANGE:`, `Refs:`,
  etc.) where applicable. Keep commits **atomic** and Conventional-Commits compliant as always;
  `detailed` only affects message thoroughness, not the split. This is the **opposite** of the
  fast modes, so take the time to describe each commit well. If combined with any fast mode
  (`wip`/`quick`/`fast`/`fastest`/`quickest`), `detailed` **wins** for message quality (still keep
  the split quick, per that mode).
- **`verbose`** means **be as detailed as you possibly can, about every detail.** Stronger than
  `detailed`: `detailed` explains a commit, `verbose` **documents** it exhaustively. Read the diff
  closely and account for **everything** in the commit: go area by area (or file by file) through
  what changed, spell out the reasoning behind each decision, note alternatives you considered and
  why you rejected them, call out side effects, edge cases, assumptions and anything a future
  reader would otherwise have to reconstruct from the diff, and add every footer that applies. Long
  is fine; there's no length budget here, so don't compress at the cost of a detail. Still wrap at
  ~72 cols, keep the subject line a normal Conventional Commits subject, and keep the split
  **atomic** and careful (`verbose` implies the non-fast split, so take the time to get it right).
  Asking for `verbose` is me wanting the full record, not a summary.
- **`push`**: after committing, `git push` the current branch (use `-u` if it has no upstream).
- **`pr`**: after committing (and pushing), open a PR/MR. Implies `push`.
- **`merge`** is only meaningful **together with `pr`**: after opening the PR/MR, **wait for its
  checks to go fully green and then merge it**. "Fully green" means every required check has
  completed successfully, with no failures, no cancelled runs, and nothing still pending. If any
  check **fails**, **do not merge**. Stop and report the failing check(s) to me. If `merge` is
  given without `pr`, treat it as `pr merge` (open the PR/MR, then merge it once green).
- **`force`** is only meaningful **together with `pr`/`merge`**: **merge even when CI is red.**
  This is the deliberate override of `merge`'s green-only rule. Don't wait for the checks, don't
  refuse on a failure: open the PR/MR and merge it right away, whatever the pipeline says (failed,
  cancelled, still queued or never started). Report afterwards which checks were red or pending at
  merge time, so I know what I merged over. `force` implies `merge` (and therefore `pr` and
  `push`): `/commit force` alone means "commit, push, open the PR/MR and merge it regardless of
  CI". Accepted spellings: `force`, `-force`, `--force`, `force-merge`.
  Non-CI blockers are **not** covered by `force`: merge conflicts, missing required approvals or
  branch protection still stop the merge, so report what's blocking instead of working around it. If
  the only thing standing in the way is a branch-protection rule requiring green checks, and the
  merge is otherwise clean, say so and ask me before reaching for `gh pr merge --admin`.

If **none** of the fast modes is given, commit in the **normal, careful** mode: think about the
best atomic split and the most accurate Conventional Commits messages.

Speed order, slowest to fastest: `verbose`, `detailed`, the default, `wip`/`quick`/`fast`, then
`fastest`/`quickest`. The two ends are opposites: `verbose` spares no detail, `fastest` spares
every one it can.

## Steps

### 0. Handle any extra requests first
- If, in the same message, I asked for other changes (anything besides these flags, whether it
  came before or after `/commit`), **carry those out first**: make the requested changes and get
  them working. Only then proceed. Those changes get committed like any other.

### 1. Resolve the flags

```
~/.claude/skills/commit/scripts/flags.sh '<arg>' …      (my arguments, each single-quoted)
→ {"speed": verbose|fastest|fast|detailed|normal, "message": verbose|detailed|normal,
   "push", "pr", "merge", "force", "unknown_tokens": [...]}
```

It applies every spelling and precedence rule above: `fastest` beats `fast`, `verbose` beats
`detailed`, a message flag wins over a fast mode for the message (`speed` keeps the fast split,
except that `verbose` overrides it), and `force` ⇒ `merge` ⇒ `pr` ⇒ `push`. Follow its output.
`unknown_tokens` are ignored (they were likely extra requests handled in step 0).

### 2. Inspect and commit
- Check the state with `git status` and `git diff` (staged and unstaged). With `speed: fastest`
  and `message: normal`, a single `git status --short` is enough, so skip the diffs.
- If there is nothing to commit, say so and stop (unless `push`/`pr` still need to run for
  already-committed work, in which case continue).
- Split the changes into **atomic** commits, each logical change on its own, splitting a single
  file across commits when needed.
- Write each message as Conventional Commits (`type(scope): description`, imperative), with
  `BREAKING CHANGE:`/`!` when applicable. Don't overuse `feat:`; reserve it for new user-facing
  functionality in the end program; use `chore:` for plumbing/wiring and for the small parts of a
  larger feature. When in doubt, don't use `feat:`.
- **`speed: fast`:** move quickly, picking a sensible atomic grouping and a correct-enough
  conventional message without long deliberation. Do not sacrifice atomicity or the conventional
  format for speed.
- **`speed: fastest`:** go straight from `git status --short` to committing, with no diff reading
  and no deliberation over the split or the wording. Take the grouping that's obvious from the file
  paths; where it isn't obvious, don't work it out, just bundle those changes into one commit and
  move on. A single commit for everything is acceptable here. Subject line only, no body (unless
  `message` says otherwise). Conventional Commits format still holds, and `feat:` stays rare; when
  unsure of the type, reach for `chore:` rather than stopping to decide.
- **`message: detailed`:** give **every** commit a full multi-line message: the Conventional
  Commits subject, a blank line, then a wrapped (~72 col) body explaining what changed and, above
  all, **why** (motivation and context, not a line-by-line echo of the diff), plus any relevant
  footers (`BREAKING CHANGE:`, `Refs:`, …). Pass the body via repeated `-m` flags (one per
  paragraph/blank-line block) or a here-doc / `-F` file, and never cram it into the subject.
  Atomicity and the conventional format are unchanged; only the message is more thorough.
- **`message: verbose`:** as `detailed`, but exhaustive. Read the diff closely and document
  **every** detail of each commit: a structured body walking through what changed area by area (or
  file by file), the reasoning behind each decision, alternatives considered and rejected, side
  effects, edge cases, assumptions, and every applicable footer. Nothing a future reader would have
  to reconstruct from the diff gets left out, and length is not a constraint. Use a here-doc or
  `-F` file for bodies this long rather than a pile of `-m` flags. Split carefully and atomically
  as in normal mode.
- **NEVER** add `Co-Authored-By` or any attribution to me-the-assistant. The commits are solely mine.

### 3. Push (if `push`)
- Run `git push` for the current branch, using `-u`/`--set-upstream` if it has no upstream yet.

### 4. Open the PR/MR (if `pr`)
Follow the same procedure as my `/pr` skill (`~/.claude/skills/pr/SKILL.md`), starting from its
context script with the current branch as source and no target:
`~/.claude/skills/pr/scripts/context.sh` (output: remotes, open PRs/MRs, an already-open one from
this branch, templates).
- Create a PR on GitHub and/or an MR on GitLab, per the remotes found (**only GitHub**, **only
  GitLab**, or **both**). If one is already open from this branch, reuse it instead.
- **Target branch:** no target is passed as a flag, so **ask me** which branch to open the PR/MR
  against before creating it. Do not assume `main`/`master` on your own.
- Use the listed template as the base if found; otherwise write a concise body summarizing what
  changed and why.
- Create with `gh pr create --base <target> --head <current-branch>` and/or
  `glab mr create --target-branch <target> --source-branch <current-branch>`, with a Conventional
  Commits title. If both remotes exist, create both and show both links.

### 5. Merge the PR/MR (if `merge`)
Only when `merge` is set, after the PR/MR exists. Read the checks with the shared checker (CLI and
output documented in the `/pr` skill, step 6):
`~/.claude/scripts/forge-checks.sh <github|gitlab> <number> [--wait]`.

**If `force` is set, skip the waiting and the green check entirely:** run it once **without**
`--wait`, purely to report the check status, and merge the PR/MR immediately with
`gh pr merge <number>` and/or `glab mr merge <number>`, whatever state CI is in. A failing or
pending check does **not** stop the merge here. Non-CI `blockers` still do: on merge conflicts,
missing approvals or branch protection, stop and tell me what's blocking (and ask before
`gh pr merge --admin`). Then jump to step 6.

Without `force`, run it **with `--wait`** (Bash `run_in_background`, or a 10-minute timeout with
`--timeout 590`, re-running while it exits 3) and act on `state`:
- **`green`** → merge with `gh pr merge <number>` and/or `glab mr merge <number>`. Ask me which merge
  strategy to use (merge commit / squash / rebase) unless the repo enforces only one; in that case
  use the allowed one and say which.
- **`failed`** → **do not merge**: report which check failed (and a link/short excerpt of the
  failure) and stop.
- **`blocked`** (merge conflicts, missing approvals, branch protection) → don't try to force it.
  Tell me what's blocking and stop.
- **`pending`** at timeout → tell me and stop; **`none`** (no checks ever reported) is not green
  either: tell me and ask before merging.
- If both a GitHub PR and a GitLab MR were created, apply the same rule to each.

### 6. Summary
Show what was committed (list the commit messages), whether it was pushed, any PR/MR link(s), and,
if `merge` was given, whether it was merged or what blocked it. With `force`, also list the
checks that were failing or still pending when you merged.
