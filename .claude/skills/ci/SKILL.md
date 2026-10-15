---
name: ci
description: Check this branch's latest CI on GitHub/GitLab and explain the failure from the logs; --fix applies the fix and pushes
argument-hint: [run/pipeline id or url | --fix]
allowed-tools: Bash(gh*), Bash(glab*), Bash(git*), Read, Edit, Glob, Grep, mcp__github__pull_request_read, mcp__gitlab__get_pipeline, mcp__gitlab__get_pipeline_job_output, Bash(~/.claude/skills/ci/scripts/*)
---

Close the loop on CI: find the latest run/pipeline for my current branch, and if it's red, dig into
the logs, tell me exactly what broke and why, and propose the fix. This is the feedback side of
`/pr`.

Argument (`$ARGUMENTS`):
- **no argument** → report the latest run's status and, if failed, the diagnosis.
- **`--fix`** (or `fix`) → also apply the fix locally, verify, and push so CI re-runs.
- a **run/pipeline id or URL** → target that specific run instead of the branch's latest.
- **Flag forms**, all equivalent: `--fix` = `-fix` = `-f` = bare `fix`.

Separately, I may include **other requests** in the same message; those are not the argument, so do
them first, then check CI.

Follow exactly these steps:

## 0. Handle any extra requests first
- If I asked for other changes in the same message (before or after `/ci`), do those first.

## 1. Find the latest run/pipeline (every GitHub/GitLab remote)

```
~/.claude/skills/ci/scripts/latest.sh [run/pipeline id | url] [--forge github|gitlab] [--branch B]
→ {"state", "runs": [{"forge", "repo", "id", "url", "name", "state", "jobs", "failing_jobs": [{"id",
   "name", "url", "failed_steps"}]}], "errors": [{"forge", "error"}]}   exit 0 green, 1 failed, 3 pending
```

An `errors` entry means that host wasn't checked: say so and fall back to
`mcp__github__pull_request_read` / `mcp__gitlab__get_pipeline` for it. Then:
- **green** → report it (which jobs ran) and stop. **pending** → report it's still in progress;
  don't block waiting (mention `/loop` to poll). **failed** → continue.

## 2. Pull the failing logs, already trimmed to the error regions

```
~/.claude/skills/ci/scripts/failed-log.sh <github|gitlab> <run/pipeline id> [--job] [-R <run's repo>] [--max-lines N] [--before N]
→ {"sections": [{"job", "step", "lines_total", "lines_kept", "excerpt"}], "truncated"}   exit 1 nothing failed
```

Per failed run, or per job with `--job <id>`. If an excerpt lacks context, raise `--before`/
`--max-lines`. Fallback: `mcp__gitlab__get_pipeline_job_output`.

## 3. Diagnose
- Extract the actual error (compile error, failing test, lint, missing dep, type error, bad config)
  and pin it to a `file:line` / job/step. State the **root cause**, not just the last log line.
- Distinguish a **real failure** from a **flake / infra hiccup** (network, timeout, runner). Say which
  you think it is.

## 4. Report, and fix if asked
- Always report: failing job(s), root cause, and the proposed fix.
- If `--fix` was given (per my `~/.claude/rules/git-conventions.md`, new branch first if I'm on a protected branch):
  - Apply the fix locally and **reproduce the failing check locally** (run that lint/test/build) to
    confirm it's resolved; don't fix blind against CI.
  - Commit following my rules (atomic, Conventional Commits, no `Co-Authored-By`) and push so CI
    re-runs.
  - If it was clearly a **flake/infra** issue, offer to just re-run instead: `gh run rerun <id>` /
    `glab ci retry <pipeline>`.
- End with the run/pipeline link and a one-line verdict.
