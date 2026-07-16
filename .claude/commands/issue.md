---
description: Create a well-structured issue (GitHub, GitLab, or Linear) from a short description, using the repo's template and drafting title/body/labels first
argument-hint: [github|gitlab|linear] <description>
allowed-tools: Bash(gh*), Bash(glab*), Bash(git*), Read, Glob, mcp__github__issue_write, mcp__gitlab__create_issue, mcp__linear__authenticate, mcp__linear__complete_authentication, mcp__linear__*
---

Turn a short description into a well-structured issue on the right tracker — **GitHub**, **GitLab**,
or **Linear** (and extensible to other connected tools). Draft a good title, body, and labels, then
create it.

Argument (`$ARGUMENTS`): an optional leading **destination** keyword (`github`, `gitlab`, `linear`)
followed by the **description** of the issue. If no destination is given, infer it (step 1). The rest
of my message is the issue description — including any bug details, acceptance criteria, or context.

**This is an outward-facing action** — it posts to a shared tracker. Always draft the issue and get
my confirmation before creating it (step 4).

Follow exactly these steps:

## 1. Determine the destination
- If I named one (`github` / `gitlab` / `linear`), use it.
- Otherwise infer from the repo's remotes (`git remote -v`): `github.com` → GitHub,
  `gitlab.com` (or self-hosted GitLab) → GitLab. If **both** exist, ask me which one.
- **Linear** isn't tied to a git remote — use it only when I name it, or when my description clearly
  targets a Linear team/project. If it's still ambiguous, ask me.

## 2. Draft the content
- **Title**: concise and imperative (e.g. `Fix flaky retry on timeout`), no trailing period.
- **Body**: shape it to the issue kind — for a bug: context, expected vs actual, steps to reproduce,
  environment; for a feature/task: problem, proposed solution, acceptance criteria. Keep it tight.
- **Labels/metadata**: suggest sensible labels (`bug`, `enhancement`, …) and, for Linear, the team,
  project, and priority if I gave hints.

## 3. Apply an issue template if the repo has one
- **GitHub**: `.github/ISSUE_TEMPLATE/*.md` or `*.yml` forms — pick the matching one and fill it.
- **GitLab**: `.gitlab/issue_templates/*.md` — pick and fill.
- **Linear**: no repo template; use the team's default template/labels.

## 4. Show the draft and confirm
- Present the resolved **destination**, **title**, **body**, and **labels/metadata**.
- **Ask for my confirmation before creating.** Let me tweak any field first.

## 5. Create it on the chosen tracker
- **GitHub** — prefer the CLI: `gh issue create --title "…" --body "…" [--label … --assignee …]`.
  Fallback: the `mcp__github__issue_write` tool with `method: "create"` and the repo's `owner`/`repo`.
- **GitLab** — prefer the CLI: `glab issue create --title "…" --description "…" [--label …]`.
  Fallback: the `mcp__gitlab__create_issue` tool with `title` and `project_id`.
- **Linear** — MCP only. If the Linear tools aren't loaded yet, it needs auth: call
  `mcp__linear__authenticate`, share the authorization URL with me, and finish with
  `mcp__linear__complete_authentication`. Once authenticated, find the Linear "create issue" tool via
  ToolSearch (e.g. query `select:`/`linear create issue`) and call it with the title, description,
  team, and labels. Ask me for the team if it's unknown.

## 6. Report
- Show the created issue's **URL/identifier** (and the tracker it landed on). If I asked for more than
  one destination, create each and list all links.
