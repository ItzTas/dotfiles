---
name: pr
description: Commit, push and open a PR (GitHub) and/or MR (GitLab) from the source branch to the target branch; merge waits for green CI and merges
argument-hint: [target-branch] [source-branch] [merge]
allowed-tools: Bash(git*), Bash(gh*), Bash(glab*), Bash(yadm*), Read, Glob, AskUserQuestion, Bash(~/.claude/skills/pr/scripts/*), Bash(~/.claude/scripts/forge-checks.sh*)
---

Open a pull request (GitHub) and/or merge request (GitLab) from the source branch to the target
branch, committing and pushing all changes first.

This command takes two optional positional arguments plus an optional flag: `$ARGUMENTS`
- **Target branch** (first positional): the branch the PR/MR is opened **against**.
- **Source branch** (second positional): the branch the PR/MR is opened **from**. If omitted,
  the current branch is used as the source.
- **`merge`** flag (see below), which may appear **anywhere** in the arguments.

Separately, I may include **other requests** in the same message, either before or after the
`/pr` invocation (e.g. "do this, that and the other `/pr`" or "`/pr` do this, that and the
other"). Those are not command arguments; they are work to do first.

## Flags

- **`merge`**: after the PR/MR is opened, **wait for its checks to go fully green and then merge
  it**. "Fully green" means every required check has completed successfully, with no failures, no
  cancelled runs, and nothing still pending (a pipeline that hasn't started yet is **not** green).
  If any check **fails or is cancelled**, **do not merge**. Stop and report the failing check(s) to
  me. Same semantics as the `merge` flag of my `/commit` command. Accepted spellings: `merge`,
  `-merge`, `--merge`.

Follow exactly these steps:

## 0. Handle any extra requests first
- If, in the same message, I asked for other changes (anything besides the target branch, whether
  it came before or after `/pr`), **carry those out first**: make the requested changes and get
  them working.
- Only after those changes are done should you proceed with the steps below. Those changes will be
  included in the commit/push and the PR/MR just like any other change.

## 1. Gather the context (arguments, branches, remotes, open PRs/MRs, templates)

```
~/.claude/skills/pr/scripts/context.sh [target] [source] [merge|-merge|--merge]
→ {"current_branch", "target", "source", "switch_needed", "merge", "merge_ambiguous", "upstream",
   "ahead", "behind", "dirty": {"clean", "files", …}, "forges": {"github", "gitlab"} (null if absent),
   "open": {"github": [{number, title, head, base, url}], "gitlab": […]}, "existing_from_source":
   {"github", "gitlab"}, "same_target": {"github": [numbers], …}, "templates": {"github": [paths], …},
   "errors": [{"forge", "error"}]}
```

Pass my arguments as-is (it pulls `merge` out from anywhere; the rest is target then source):
- **`merge_ambiguous`**: a branch is literally named `merge`, so **ask me** which I meant first.
- **`target` is null**: **ask me** which branch to open the PR/MR against before continuing. Do not
  assume `main`/`master` on your own.
- **`switch_needed`**: the source must be checked out (`git switch <source>`) so the commit and push
  land on it, but **ask me before switching**, per `~/.claude/rules/git-conventions.md`. Use
  `AskUserQuestion` with at least: **switch to `<source>` as I asked**, **stay on the current branch
  and open the PR/MR from it instead**, and any branch with an open PR/MR against the same target
  (`same_target`) so I don't stack yet another one. Don't switch until I answer.
- If the tree is dirty and switching would be unsafe, tell me instead of forcing it.
- `errors` means that forge's open list couldn't be read: say so, don't assume it has none.

## 1b. Show me what's already open before creating anything new
- If `existing_from_source` has a PR/MR, **do not create a second one**. Tell me it exists, push the
  new commits to it, and show me the link.
- Mention the other open PRs/MRs against the same target (`same_target`) in one line each before
  creating the new one.

## 2. Remotes
- `forges.github` / `forges.gitlab` say whether there's **only GitHub**, **only GitLab**, or
  **both**. If both exist, you will create **a PR on GitHub AND an MR on GitLab**.

## 3. Commit and push all changes
- Make sure you are on the **source branch** before committing; check `git status` and `git diff`.
- Commit **all** pending changes following the rules in my `~/.claude/rules/git-conventions.md`:
  atomic commits, Conventional Commits, imperative mood, **no** `Co-Authored-By` or any
  attribution to you (the commit is solely mine).
- Run `git push` for the source branch (use `-u` if `upstream` is null).

## 4. Use the repository's template
- If `templates` lists one for the forge, read it and **use it** as the base for the body, filling
  the sections based on the changes (several GitHub templates in a folder: pick the one that fits).
- If none is found, write a concise body: a summary of what changed and why.

## 5. Create the PR/MR
- **GitHub**: `gh pr create --base <target> --head <source-branch>` with a title (Conventional
  Commits) and body (filled template or summary).
- **GitLab**: `glab mr create --target-branch <target> --source-branch <source-branch>` with an
  equivalent title and body.
- If both exist, create both and show me both links at the end.

## 6. Merge once green (only if `merge` was given)
Skip this step entirely unless `merge` was set. It applies to the PR/MR handled in this run, whether
just created in step 5 or the already-open one from step 1b. Wait with the shared checker:

```
~/.claude/scripts/forge-checks.sh <github|gitlab> <pr/mr number> --wait [--interval S] [--timeout S]
→ {"url", "state": green|failed|pending|blocked|none, "checks": [{"name", "status", "conclusion",
   "bucket", "link"}] (failing first), "failing", "pending", "blockers": [{"kind", "detail"}], "timed_out"}
   exit 0 green, 1 failed/blocked, 3 still pending, 4 no checks, 2 error
```

It polls until nothing is queued or running (default timeout 30 min), so run it with Bash
`run_in_background` (or a 10-minute timeout and `--timeout 590`, re-running while it exits 3).
- **`green`** → merge with `gh pr merge <number>` and/or `glab mr merge <number>`. Ask me which merge
  strategy to use (merge commit / squash / rebase) unless the repo enforces only one; in that case
  use the allowed one and say which.
- **`failed`** → **do not merge**: report which check failed (`failing`, with its `link` or a short
  excerpt of the failure) and stop.
- **`blocked`** (merge conflicts, missing approvals, changes requested, branch protection, draft…)
  → don't try to force it. Tell me what's blocking (`blockers`) and stop.
- **`pending`** at timeout → tell me it's still running and stop; **`none`** (no checks ever
  reported) is not green either: tell me and ask before merging.
- If both a GitHub PR and a GitLab MR exist, apply the same rule to each.

When done, show a summary: source branch, target branch, what was committed, and the link(s) to the
created PR/MR, plus, if `merge` was given, whether it was merged or what blocked it.
