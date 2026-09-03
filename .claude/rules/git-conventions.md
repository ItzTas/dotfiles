These are my personal git conventions. Whenever you are about to do **any git work** (creating
branches, committing, reverting, opening PRs/MRs), load this file and follow every rule below.

## Branches

- **On shared/protected branches, create a new branch for changes.** If I'm on a `dev`, `main`, `master`, or `pre-homolog` branch and I ask for a change, create a new branch to implement it instead of working directly on the current branch. Exceptions where you should stay on the current branch: personal projects, projects only I work on, or projects without a sophisticated branching system (e.g., my Neovim dotfiles, which only have `main` because they're simple dotfiles that don't warrant extra branches).

- **NEVER leave the current branch without asking me first.** This applies to *any* branch change: `git switch`/`git checkout` to an existing branch, `git switch -c`/`git checkout -b` to create a new one, `git worktree add`, or anything else that moves me off the branch I'm on. I work across many branches at once and forget to merge open PRs/MRs, so branches pile up, and I need to decide each move consciously.

  Before asking, gather the context so the decision is informed:
  - `git branch --show-current`: where I am now.
  - `git branch --sort=-committerdate --format='%(refname:short) %(committerdate:relative) [%(upstream:track)]'`: local branches, most recent first, with ahead/behind info.
  - Open PRs/MRs, when a remote and CLI are available: `gh pr list --state open --json number,title,headRefName,baseRefName` and/or `glab mr list --state opened`.

  Then **ask me with a multiple-choice question** (the `AskUserQuestion` tool), showing:
  - what you want to do and why (e.g. "current branch `main` is protected, the change needs its own branch");
  - the branches that already have **open, unmerged PRs/MRs**, so I can reuse one instead of opening yet another;
  - options covering at least: **create the new branch you propose** (state the exact name), **switch to an existing branch with pending work** (list the relevant ones), and **stay on the current branch**.

  If the `AskUserQuestion` tool isn't available, ask in plain text and wait for my answer. Either way: **do not switch, and do not start the work, until I answer.**

  Exceptions where you go ahead without asking:
  - I already named the branch explicitly in my request; that *is* my answer.
  - **`/implement`.** That command exists to branch first, so creating and switching to a new branch is exactly what I asked for, including when it derives the name itself. Just tell me the name you chose and move on.

- **A repo that looks shared may still be mine alone, with one standing working branch.** Even on a
  project with a `dev`/`main`/`pre-homolog` setup and a full branching model, I'm often the only one
  touching it. In that case I create a **single long-lived branch** and keep working on it, opening
  MRs/PRs from it into homologation, instead of piling up one branch per change.

  So before creating a branch (or before applying the "protected branch, branch first" rule), **ask
  me whether the branch I'm currently on is that kind of standing working branch**, with
  `AskUserQuestion`. Check memory first: if a memory already records the answer for this repo, don't
  ask again, just follow it.

  - **If I say yes:** stay on that branch, commit directly to it, MR/PR from it into the
    homologation branch, and never switch away from it, recreate it, or delete it — including for
    `/implement`. Then **save it to memory** as a `feedback` memory for that project (plus its
    `MEMORY.md` pointer): the branch name, the target branch of the MRs, and the fact that it's a
    standing branch. Model it on the existing `chore-staging-is-the-working-branch` memory in
    `wodefin-android`.
  - **If I say no:** fall back to the normal rules above (branch per change, ask before switching).

- **Report accumulated branches when you notice them.** If, while gathering the above, you find branches with open PRs/MRs or unpushed/unmerged commits that look forgotten, mention them in the question, briefly, one line each. Don't merge, close, or delete anything on your own.

## Commits

- **NEVER add co-authorship attribution to me when making commits on my behalf.** Do not include `Co-Authored-By: Claude ...` or any line indicating that you took part in the commit. The commit must appear as being solely mine.
- **Always make atomic commits.** Separate each logical change into its own specific commit, instead of bundling unrelated changes into a single commit. If necessary, split the changes of a single file across different commits.
- **Always follow the Conventional Commits standard.** Use the form `type(optional scope): description` (e.g., `feat:`, `fix:`, `docs:`, `refactor:`, `test:`, `chore:`), with the description in the imperative. Use `BREAKING CHANGE:` in the footer or `!` after the type/scope when there is an incompatible change.
- **Don't overuse `feat:`.** `feat:` should not be used for a small piece of functionality that is part of a larger feature. In that case, `feat:` is reserved for the larger feature that incorporates the smaller one, while the smaller part uses `chore:`. Ideally there is only one `feat:` per branch/feature; only in very specific cases may there be more than one.
- **`feat:` is only for new things in the end program itself.** Reserve `feat:` for new user-facing functionality in the end program. Plumbing or wiring work, such as connecting the database to something, is not a `feat:`; use `chore:` (or another appropriate type) instead.
- **When in doubt, don't use `feat:`.** If you're not sure whether a commit deserves `feat:`, don't assign any `feat:` and let me set it manually.
