---
description: Commit all pending changes as atomic Conventional Commits, optionally fast (wip/quick), detailed, and optionally push and/or open a PR
argument-hint: [wip|quick|fast] [detailed] [push] [pr]
allowed-tools: Bash(git*), Bash(gh*), Bash(glab*), Bash(yadm*), Read, Glob
---

Commit all pending changes following the commit rules in my `CLAUDE.md`
(atomic commits, Conventional Commits `type(scope): description` in the imperative,
**no** `Co-Authored-By` or any attribution to you — the commit is solely mine, and
`feat:` used sparingly).

This command takes zero or more **flags** as arguments: `$ARGUMENTS`

Flags may appear in **any order** and **more than one** may be given
(e.g. `/commit wip push`, `/commit fast pr`, `/commit quick push pr`, `/commit detailed`,
`/commit detailed push`).

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
- **`detailed`** — Write **richly detailed** commit messages. Beyond the Conventional Commits
  subject line, give **every** commit a full body: a blank line after the subject, then a wrapped
  (~72 col) prose/bulleted body explaining **what** changed and **why** (the motivation and
  context, not a restatement of the diff), and relevant footers (`BREAKING CHANGE:`, `Refs:`,
  etc.) where applicable. Keep commits **atomic** and Conventional-Commits compliant as always;
  `detailed` only affects message thoroughness, not the split. This is the **opposite** of the
  fast modes — take the time to describe each commit well. If combined with `wip`/`quick`/`fast`,
  `detailed` **wins** for message quality (still keep the split reasonably quick).
- **`push`** — After committing, `git push` the current branch (use `-u` if it has no upstream).
- **`pr`** — After committing (and pushing), open a PR/MR. Implies `push`.

If **none** of `wip`/`quick`/`fast` is given, commit in the **normal, careful** mode: think
about the best atomic split and the most accurate Conventional Commits messages.

## Steps

### 0. Handle any extra requests first
- If, in the same message, I asked for other changes (anything besides these flags, whether it
  came before or after `/commit`), **carry those out first** — make the requested changes and get
  them working. Only then proceed. Those changes get committed like any other.

### 1. Parse the flags
- Read `$ARGUMENTS` and detect which of `wip`, `quick`, `fast`, `detailed`, `push`, `pr` are present.
- `wip`, `quick` and `fast` all select **fast mode**. `detailed` selects **detailed-message mode**.
  `pr` implies `push`. If both a fast flag and `detailed` are present, `detailed` wins for message
  quality (see the flag description).
- Ignore unrecognized tokens (they were likely extra requests handled in step 0).

### 2. Inspect and commit
- Check the state with `git status` and `git diff` (staged and unstaged).
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
- **Detailed mode (`detailed`):** give **every** commit a full multi-line message — the
  Conventional Commits subject, a blank line, then a wrapped (~72 col) body explaining what changed
  and, above all, **why** (motivation and context, not a line-by-line echo of the diff), plus any
  relevant footers (`BREAKING CHANGE:`, `Refs:`, …). Pass the body via repeated `-m` flags (one
  per paragraph/blank-line block) or a here-doc / `-F` file — never cram it into the subject.
  Atomicity and the conventional format are unchanged; only the message is more thorough.
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

### 5. Summary
Show what was committed (list the commit messages), whether it was pushed, and any PR/MR link(s).
