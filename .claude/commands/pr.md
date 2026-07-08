---
description: Commit, push and open a PR (GitHub) and/or MR (GitLab) from the current branch to the target branch
argument-hint: [target-branch]
allowed-tools: Bash(git*), Bash(gh*), Bash(glab*), Bash(yadm*), Read, Glob
---

Open a pull request (GitHub) and/or merge request (GitLab) from the current branch to the target
branch, committing and pushing all changes first.

Target branch argument: `$1`

Follow exactly these steps:

## 1. Determine the target branch
- If `$1` is provided, use it as the target branch.
- If `$1` is empty, **ask me** which branch to open the PR/MR against before continuing.
  Do not assume `main`/`master` on your own.

## 2. Detect the remotes (GitHub and GitLab)
- Run `git remote -v` and identify which remotes point to `github.com` and/or `gitlab.com`
  (or equivalent self-hosted instances).
- Record the result: there may be **only GitHub**, **only GitLab**, or **both**.
- If both exist, you will create **a PR on GitHub AND an MR on GitLab**.

## 3. Commit and push all changes
- Check the state with `git status` and `git diff`.
- Commit **all** pending changes following the rules in my `CLAUDE.md`:
  atomic commits, Conventional Commits, imperative mood, **no** `Co-Authored-By` or any
  attribution to you (the commit is solely mine).
- Run `git push` for the current branch (use `-u` if it has no upstream yet).

## 4. Look for a template in the repository
Look for templates before writing the PR/MR body:
- GitHub: `.github/PULL_REQUEST_TEMPLATE.md`, `.github/pull_request_template.md`,
  `.github/PULL_REQUEST_TEMPLATE/` (folder), `docs/PULL_REQUEST_TEMPLATE.md`,
  `PULL_REQUEST_TEMPLATE.md` at the root.
- GitLab: `.gitlab/merge_request_templates/*.md`.
- If a template is found, **use it** as the base for the body, filling the sections based on the changes.
- If none is found, write a concise body: a summary of what changed and why.

## 5. Create the PR/MR
- **GitHub** (if a GitHub remote exists): `gh pr create --base <target> --head <current-branch>`
  with a title (Conventional Commits) and body (filled template or summary).
- **GitLab** (if a GitLab remote exists): `glab mr create --target-branch <target>
  --source-branch <current-branch>` with an equivalent title and body.
- If both exist, create both and show me both links at the end.

When done, show a summary: target branch, what was committed, and the link(s) to the created PR/MR.
