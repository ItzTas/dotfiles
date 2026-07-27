---
description: Commit, push and open a PR (GitHub) and/or MR (GitLab) from the source branch to the target branch
argument-hint: [target-branch] [source-branch]
allowed-tools: Bash(git*), Bash(gh*), Bash(glab*), Bash(yadm*), Read, Glob, AskUserQuestion
---

Open a pull request (GitHub) and/or merge request (GitLab) from the source branch to the target
branch, committing and pushing all changes first.

This command takes two optional arguments:
- **Target branch** (first argument): `$1`
- **Source branch** (second argument): `$2` — the branch the PR/MR is opened **from**. If omitted,
  the current branch is used as the source.

Separately, I may include **other requests** in the same message, either before or after the
`/pr` invocation (e.g. "do this, that and the other `/pr`" or "`/pr` do this, that and the
other"). Those are not command arguments — they are work to do first.

Follow exactly these steps:

## 0. Handle any extra requests first
- If, in the same message, I asked for other changes (anything besides the target branch, whether
  it came before or after `/pr`), **carry those out first** — make the requested changes and get
  them working.
- Only after those changes are done should you proceed with the steps below. Those changes will be
  included in the commit/push and the PR/MR just like any other change.

## 1. Determine the target and source branches
- **Target branch**: if it was given as the first argument, use it. If no target branch was given,
  **ask me** which branch to open the PR/MR against before continuing. Do not assume `main`/`master`
  on your own.
- **Source branch**: if a source branch was given as the second argument, use it as the branch the
  PR/MR is opened from. If it was omitted, use the current branch (`git branch --show-current`) as
  the source.
- If a source branch was given and it differs from the current branch, it needs to be checked out
  (`git switch <source>`) so that the commit and push land on the source branch — but **ask me
  before switching**, per the branch rule in `~/.claude/commands/git-conventions.md`. Use
  `AskUserQuestion` with at least: **switch to `<source>` as I asked**, **stay on the current branch
  and open the PR/MR from it instead**, and any branch that already has an open PR/MR against the
  same target (so I don't stack yet another one). Don't switch until I answer.
- If the working tree is dirty and switching would be unsafe, tell me instead of forcing it.

## 1b. Show me what's already open before creating anything new
- Before opening a new PR/MR, list what is already open so I don't accumulate duplicates:
  `gh pr list --state open --json number,title,headRefName,baseRefName` and/or
  `glab mr list --state opened` (whichever remotes exist).
- If there is **already an open PR/MR from this source branch**, do not create a second one — tell me
  it exists, push the new commits to it, and show me the link.
- If there are other open PRs/MRs that overlap with this change (same target, related branch),
  mention them in one line each before creating the new one.

## 2. Detect the remotes (GitHub and GitLab)
- Run `git remote -v` and identify which remotes point to `github.com` and/or `gitlab.com`
  (or equivalent self-hosted instances).
- Record the result: there may be **only GitHub**, **only GitLab**, or **both**.
- If both exist, you will create **a PR on GitHub AND an MR on GitLab**.

## 3. Commit and push all changes
- Make sure you are on the **source branch** determined in step 1 before committing.
- Check the state with `git status` and `git diff`.
- Commit **all** pending changes following the rules in my `~/.claude/commands/git-conventions.md`:
  atomic commits, Conventional Commits, imperative mood, **no** `Co-Authored-By` or any
  attribution to you (the commit is solely mine).
- Run `git push` for the source branch (use `-u` if it has no upstream yet).

## 4. Look for a template in the repository
Look for templates before writing the PR/MR body:
- GitHub: `.github/PULL_REQUEST_TEMPLATE.md`, `.github/pull_request_template.md`,
  `.github/PULL_REQUEST_TEMPLATE/` (folder), `docs/PULL_REQUEST_TEMPLATE.md`,
  `PULL_REQUEST_TEMPLATE.md` at the root.
- GitLab: `.gitlab/merge_request_templates/*.md`.
- If a template is found, **use it** as the base for the body, filling the sections based on the changes.
- If none is found, write a concise body: a summary of what changed and why.

## 5. Create the PR/MR
- **GitHub** (if a GitHub remote exists): `gh pr create --base <target> --head <source-branch>`
  with a title (Conventional Commits) and body (filled template or summary).
- **GitLab** (if a GitLab remote exists): `glab mr create --target-branch <target>
  --source-branch <source-branch>` with an equivalent title and body.
- If both exist, create both and show me both links at the end.

When done, show a summary: source branch, target branch, what was committed, and the link(s) to the
created PR/MR.
