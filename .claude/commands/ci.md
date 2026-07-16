---
description: Check the current branch's latest CI run/pipeline on GitHub and/or GitLab, summarize why it failed from the logs, and with --fix apply the fix locally and push so it re-runs
argument-hint: [run/pipeline id or url | --fix]
allowed-tools: Bash(gh*), Bash(glab*), Bash(git*), Read, Edit, Glob, Grep, mcp__github__pull_request_read, mcp__gitlab__get_pipeline, mcp__gitlab__get_pipeline_job_output
---

Close the loop on CI: find the latest run/pipeline for my current branch, and if it's red, dig into
the logs, tell me exactly what broke and why, and propose the fix. This is the feedback side of
`/pr`.

Argument (`$ARGUMENTS`):
- **no argument** → report the latest run's status and, if failed, the diagnosis.
- **`--fix`** (or `fix`) → also apply the fix locally, verify, and push so CI re-runs.
- a **run/pipeline id or URL** → target that specific run instead of the branch's latest.

Separately, I may include **other requests** in the same message; those are not the argument — do
them first, then check CI.

Follow exactly these steps:

## 0. Handle any extra requests first
- If I asked for other changes in the same message (before or after `/ci`), do those and get them
  working before checking CI.

## 1. Detect the host(s)
- From `git remote -v`, identify GitHub (`github.com`) and/or GitLab (`gitlab.com`/self-hosted), the
  same way `/pr` does. Check CI on whichever exists; if both run CI, check both.

## 2. Find the latest run/pipeline for the branch
- **GitHub Actions**: `gh run list --branch <branch> --limit 1`, then `gh run view <id>`. (`gh pr
  checks` is a quick overall view.)
- **GitLab**: `glab ci status` / `glab ci list` for the branch's most recent pipeline.
- If I passed an id/URL, use that instead.

## 3. Branch on the status
- **Passing** → report green (which jobs ran) and stop.
- **Running/queued** → report it's still in progress; don't block waiting. (Mention `/loop` if I want
  to poll.)
- **Failed** → continue to the diagnosis.

## 4. Pull the failing logs
- **GitHub**: `gh run view <id> --log-failed` (just the failed steps). Fallback:
  `mcp__github__pull_request_read` for check details.
- **GitLab**: `glab ci view <pipeline>` to see the failing job(s), then `glab ci trace <job>` for its
  log. Fallback: `mcp__gitlab__get_pipeline` + `mcp__gitlab__get_pipeline_job_output`.

## 5. Diagnose
- Extract the actual error from the logs (compile error, failing test, lint, missing dep, type error,
  bad config) and pin it to a `file:line` / job/step. State the **root cause**, not just the last log
  line.
- Distinguish a **real failure** from a **flake / infra hiccup** (network, timeout, runner). Say which
  you think it is.

## 6. Report — and fix if asked
- Always report: failing job(s), root cause, and the proposed fix.
- If `--fix` was given (per my `~/.claude/commands/git-conventions.md`, new branch first if I'm on a protected branch):
  - Apply the fix locally and **reproduce the failing check locally** (run that lint/test/build) to
    confirm it's resolved — don't fix blind against CI.
  - Commit following my rules (atomic, Conventional Commits, no `Co-Authored-By`) and push so CI
    re-runs.
  - If it was clearly a **flake/infra** issue, offer to just re-run instead: `gh run rerun <id>` /
    `glab ci retry <pipeline>`.
- End with the run/pipeline link and a one-line verdict.
