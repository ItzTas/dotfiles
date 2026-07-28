---
description: Commit everything as atomic Conventional Commits; flags: wip/quick/fast, fastest, detailed, verbose, push, pr, merge
argument-hint: [wip|quick|fast|fastest|quickest] [detailed|verbose] [push] [pr] [merge]
allowed-tools: Bash(git*), Bash(gh*), Bash(glab*), Bash(yadm*), Read, Glob
---

Commit all pending changes following the commit rules in my `~/.claude/commands/git-conventions.md`
(atomic commits, Conventional Commits `type(scope): description` in the imperative,
**no** `Co-Authored-By` or any attribution to you — the commit is solely mine, and
`feat:` used sparingly).

This command takes zero or more **flags** as arguments: `$ARGUMENTS`

Flags may appear in **any order** and **more than one** may be given
(e.g. `/commit wip push`, `/commit fast pr`, `/commit quick push pr`, `/commit fastest`,
`/commit detailed`, `/commit detailed push`, `/commit verbose`, `/commit verbose pr`,
`/commit pr merge`).

Separately, I may include **other requests** in the same message, either before or after the
`/commit` invocation (e.g. "do this, that and the other `/commit`" or "`/commit` do this, that
and the other"). Those are **not** flags — they are work to do first.

## Flags

- **`wip`** — Work-in-progress checkpoint mode. Commit **quickly, without overthinking**: don't
  deliberate over the perfect split or message wording. Still honor my standards though — commits
  must stay **atomic** and **Conventional Commits** compliant. This is meant to be fast; favor a
  reasonable grouping over a perfect one.
- **`quick`** / **`fast`** — Synonyms for the fast behavior: commit quickly without spending too
  long, while still keeping commits atomic and Conventional-Commits compliant. Treat these the
  same as `wip`'s speed behavior.
- **`fastest`** / **`quickest`** — **As fast as you possibly can.** Stronger than `wip`/`quick`/
  `fast`: skip the analysis entirely — don't read through the diffs looking for the right split,
  just glance at `git status --short` and go. Group by whatever is obvious from the file paths.
  Unlike the other fast modes, atomicity is **best-effort** here: keep the split when it's
  self-evident, but if separating the changes would cost real thinking time, bundle them into a
  single commit instead. Conventional Commits (`type(scope): description`, imperative) still
  applies — a short, correct-enough subject line, no body. Speed beats precision in this mode;
  asking for `fastest` is me accepting a rougher split in exchange for it.
- **`detailed`** — Write **richly detailed** commit messages. Beyond the Conventional Commits
  subject line, give **every** commit a full body: a blank line after the subject, then a wrapped
  (~72 col) prose/bulleted body explaining **what** changed and **why** (the motivation and
  context, not a restatement of the diff), and relevant footers (`BREAKING CHANGE:`, `Refs:`,
  etc.) where applicable. Keep commits **atomic** and Conventional-Commits compliant as always;
  `detailed` only affects message thoroughness, not the split. This is the **opposite** of the
  fast modes — take the time to describe each commit well. If combined with any fast mode
  (`wip`/`quick`/`fast`/`fastest`/`quickest`), `detailed` **wins** for message quality (still keep
  the split quick, per that mode).
- **`verbose`** — **Be as detailed as you possibly can, about every detail.** Stronger than
  `detailed`: `detailed` explains a commit, `verbose` **documents** it exhaustively. Read the diff
  closely and account for **everything** in the commit — go area by area (or file by file) through
  what changed, spell out the reasoning behind each decision, note alternatives you considered and
  why you rejected them, call out side effects, edge cases, assumptions and anything a future
  reader would otherwise have to reconstruct from the diff, and add every footer that applies. Long
  is fine — there's no length budget here, so don't compress at the cost of a detail. Still wrap at
  ~72 cols, keep the subject line a normal Conventional Commits subject, and keep the split
  **atomic** and careful (`verbose` implies the non-fast split — take the time to get it right).
  Asking for `verbose` is me wanting the full record, not a summary.
- **`push`** — After committing, `git push` the current branch (use `-u` if it has no upstream).
- **`pr`** — After committing (and pushing), open a PR/MR. Implies `push`.
- **`merge`** — Only meaningful **together with `pr`**: after opening the PR/MR, **wait for its
  checks to go fully green and then merge it**. "Fully green" means every required check has
  completed successfully — no failures, no cancelled runs, and nothing still pending. Poll the
  PR/MR status until it settles; if any check **fails**, **do not merge** — stop and report the
  failing check(s) to me. If `merge` is given without `pr`, treat it as `pr merge` (open the PR/MR,
  then merge it once green).

If **none** of the fast modes is given, commit in the **normal, careful** mode: think about the
best atomic split and the most accurate Conventional Commits messages.

Speed order, slowest to fastest: `verbose` → `detailed` → (default) → `wip`/`quick`/`fast` →
`fastest`/`quickest`. The two ends are opposites: `verbose` spares no detail, `fastest` spares
every one it can.

## Steps

### 0. Handle any extra requests first
- If, in the same message, I asked for other changes (anything besides these flags, whether it
  came before or after `/commit`), **carry those out first** — make the requested changes and get
  them working. Only then proceed. Those changes get committed like any other.

### 1. Parse the flags
- Read `$ARGUMENTS` and detect which of `wip`, `quick`, `fast`, `fastest`, `quickest`, `detailed`,
  `verbose`, `push`, `pr`, `merge` are present.
- `wip`, `quick` and `fast` select **fast mode**; `fastest` and `quickest` select **fastest mode**.
  If both are present, `fastest` wins. `detailed` selects **detailed-message mode**; `verbose`
  selects **verbose mode**. If both are present, `verbose` wins. `pr` implies `push`.
- If a fast flag is combined with `detailed`/`verbose`, the message flag **wins** for message
  quality (see the flag descriptions). `verbose` additionally overrides the fast split — a
  `fastest verbose` request is contradictory, so honor `verbose` and commit carefully.
- `merge` implies `pr` (and therefore `push`): if I wrote `merge` without `pr`, still open the
  PR/MR and then merge it once green.
- Match `fastest`/`quickest` before `fast`/`quick` so the superlative isn't read as the base flag.
- Ignore unrecognized tokens (they were likely extra requests handled in step 0).

### 2. Inspect and commit
- Check the state with `git status` and `git diff` (staged and unstaged). In **fastest mode**, a
  single `git status --short` is enough — skip the diffs.
- If there is nothing to commit, say so and stop (unless `push`/`pr` still need to run for
  already-committed work — in that case continue).
- Split the changes into **atomic** commits — each logical change on its own, splitting a single
  file across commits when needed.
- Write each message as Conventional Commits (`type(scope): description`, imperative), with
  `BREAKING CHANGE:`/`!` when applicable. Don't overuse `feat:` — reserve it for new user-facing
  functionality in the end program; use `chore:` for plumbing/wiring and for the small parts of a
  larger feature. When in doubt, don't use `feat:`.
- **Fast mode (`wip`/`quick`/`fast`):** move quickly — pick a sensible atomic grouping and a
  correct-enough conventional message without long deliberation. Do not sacrifice atomicity or the
  conventional format for speed.
- **Fastest mode (`fastest`/`quickest`):** go straight from `git status --short` to committing —
  no diff reading, no deliberation over the split or the wording. Take the grouping that's obvious
  from the file paths; where it isn't obvious, don't work it out — bundle those changes into one
  commit and move on. A single commit for everything is acceptable here. Subject line only, no
  body. Conventional Commits format still holds, and `feat:` stays rare — when unsure of the type,
  reach for `chore:` rather than stopping to decide.
- **Detailed mode (`detailed`):** give **every** commit a full multi-line message — the
  Conventional Commits subject, a blank line, then a wrapped (~72 col) body explaining what changed
  and, above all, **why** (motivation and context, not a line-by-line echo of the diff), plus any
  relevant footers (`BREAKING CHANGE:`, `Refs:`, …). Pass the body via repeated `-m` flags (one
  per paragraph/blank-line block) or a here-doc / `-F` file — never cram it into the subject.
  Atomicity and the conventional format are unchanged; only the message is more thorough.
- **Verbose mode (`verbose`):** as `detailed`, but exhaustive — read the diff closely and document
  **every** detail of each commit: a structured body walking through what changed area by area (or
  file by file), the reasoning behind each decision, alternatives considered and rejected, side
  effects, edge cases, assumptions, and every applicable footer. Nothing a future reader would have
  to reconstruct from the diff gets left out, and length is not a constraint. Use a here-doc or
  `-F` file for bodies this long rather than a pile of `-m` flags. Split carefully and atomically
  as in normal mode.
- **NEVER** add `Co-Authored-By` or any attribution to me-the-assistant. The commits are solely mine.

### 3. Push (if `push` or `pr`)
- Run `git push` for the current branch, using `-u`/`--set-upstream` if it has no upstream yet.

### 4. Open the PR/MR (if `pr`)
Follow the same procedure as my `/pr` command (see `~/.claude/commands/pr.md`):
- Detect remotes with `git remote -v`: there may be **only GitHub**, **only GitLab**, or **both**.
  Create a PR on GitHub and/or an MR on GitLab accordingly.
- **Target branch:** no target is passed as a flag, so **ask me** which branch to open the PR/MR
  against before creating it. Do not assume `main`/`master` on your own.
- Look for a template before writing the body: GitHub
  (`.github/PULL_REQUEST_TEMPLATE.md`, `.github/pull_request_template.md`,
  `.github/PULL_REQUEST_TEMPLATE/`, `PULL_REQUEST_TEMPLATE.md`) or GitLab
  (`.gitlab/merge_request_templates/*.md`). Use it as the base if found; otherwise write a concise
  body summarizing what changed and why.
- Create with `gh pr create --base <target> --head <current-branch>` and/or
  `glab mr create --target-branch <target> --source-branch <current-branch>`, with a Conventional
  Commits title. If both remotes exist, create both and show both links.

### 5. Merge the PR/MR (if `merge`)
Only when `merge` was given. After the PR/MR exists:
- **Wait for the checks to finish.** GitHub: `gh pr checks --watch` (or poll
  `gh pr checks <number>` / `gh pr view <number> --json statusCheckRollup`). GitLab:
  poll `glab ci status` / `glab mr view <number>`. Keep waiting while anything is queued or
  running — a not-yet-started pipeline is **not** green.
- **Only merge when everything is green:** every required check succeeded, none failed, none was
  cancelled, and nothing is still pending. If any check **fails or is cancelled**, **do not merge**
  — report which check failed (and a link/short excerpt of the failure) and stop.
- If the PR/MR is blocked for a non-CI reason (merge conflicts, missing approvals, branch
  protection), don't try to force it — tell me what's blocking and stop.
- Merge with `gh pr merge <number>` and/or `glab mr merge <number>`. Ask me which merge strategy
  to use (merge commit / squash / rebase) unless the repo enforces only one — in that case use the
  allowed one and say which.
- If both a GitHub PR and a GitLab MR were created, apply the same rule to each.

### 6. Summary
Show what was committed (list the commit messages), whether it was pushed, any PR/MR link(s), and
— if `merge` was given — whether it was merged or what blocked it.
