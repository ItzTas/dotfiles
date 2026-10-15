---
name: address-comments
description: Fetch this branch's PR/MR review comments, apply the fixes, push, and optionally reply/resolve each thread
argument-hint: [pr/mr number or url]
allowed-tools: Bash(gh*), Bash(glab*), Bash(git*), Read, Edit, Glob, Grep, mcp__github__pull_request_read, mcp__gitlab__mr_discussions, mcp__gitlab__resolve_merge_request_thread, Bash(~/.claude/skills/address-comments/scripts/*)
---

Take the review feedback on my current PR/MR and act on it: read every comment, apply the changes
reviewers asked for, push the fixes, and (if I confirm) reply to and resolve each thread. This is the
answering side of `/pr`.

Optional argument (`$ARGUMENTS`): a specific PR/MR number or URL. If omitted, detect it from the
current branch.

Separately, I may include **other requests** in the same message; those are not the argument, so do
them first, then address the review.

Follow exactly these steps:

## 0. Handle any extra requests first
- If I asked for other changes in the same message (before or after `/address-comments`), do those
  and get them working before addressing the review.

## 1. Detect the PR/MR and fetch its review

```
~/.claude/skills/address-comments/scripts/fetch.sh [pr/mr number | url] [--forge github|gitlab] [--all]
→ {"results": [{"forge", "number", "url", "head", "threads": [{"id", "path", "line", "comments": [{"author",
   "body", "url"}]}], "conversation", "reviews", "skipped"}], "not_found", "errors"}   exit 1 none open
```

It finds the current branch's open PR/MR on every remote (or uses mine), skipping resolved/outdated
threads (`--all` if one may still apply). On `errors`, fall back to the MCP tools above.
- If both hosts have one and it's ambiguous, ask which to address.
- Make sure I'm on its `head` branch; if not, check it out (asking first, per
  `~/.claude/rules/git-conventions.md`). If I'm on a protected branch, stop and warn me.
- Pull down the latest first (`git pull`) so I'm editing against the reviewed state.

## 2. Triage the feedback
- List each comment with its `file:line`, the reviewer, and what they're asking. Classify each as:
  **change requested** (actionable code edit), **question** (needs a reply, maybe no code change), or
  **nit/praise** (optional / no action). Group by file.

## 3. Apply the changes
- For each **change requested**, make the focused edit that addresses exactly that comment, nothing
  unrelated. Keep the reviewer's intent; if a request seems wrong or risky, note it for a reply
  instead of silently ignoring it.
- For each **question**, draft a reply (don't invent a code change).
- After the edits, run the build/tests to confirm nothing broke.

## 4. Commit and push
- Commit the fixes per my `~/.claude/rules/git-conventions.md` (atomic, Conventional Commits,
  imperative, **no** `Co-Authored-By`), grouped by logical change. Push so the PR/MR updates.

## 5. Reply and resolve: outward-facing, confirm first
- **Ask before posting anything.** Then, **only for each thread I confirmed** (`--dry-run` previews):
  `~/.claude/skills/address-comments/scripts/respond.sh <github|gitlab> <thread id> --reply "<text>" --resolve [--mr <GitLab MR>]`
  with a brief reply (e.g. `Done in <sha>` or the answer); it resolves only if the reply went through.
  Conversation comments aren't threads: `gh pr comment` / `glab mr note`, same confirmation.
- Leave threads I disagreed with open, with a reply explaining why (no `--resolve`).

## 6. Report
- Summarize: which comments were addressed (and how), which got a reply instead of a change, and
  anything left open with the reason. Show the PR/MR link.
