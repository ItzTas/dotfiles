---
description: Fetch the review comments on the current branch's PR (GitHub) and/or MR (GitLab), apply the requested fixes, push, and optionally reply to and resolve each thread
argument-hint: [pr/mr number or url]
allowed-tools: Bash(gh*), Bash(glab*), Bash(git*), Read, Edit, Glob, Grep, mcp__github__pull_request_read, mcp__gitlab__mr_discussions, mcp__gitlab__resolve_merge_request_thread
---

Take the review feedback on my current PR/MR and act on it: read every comment, apply the changes
reviewers asked for, push the fixes, and (if I confirm) reply to and resolve each thread. This is the
answering side of `/pr`.

Optional argument (`$ARGUMENTS`): a specific PR/MR number or URL. If omitted, detect it from the
current branch.

Separately, I may include **other requests** in the same message; those are not the argument — do
them first, then address the review.

Follow exactly these steps:

## 0. Handle any extra requests first
- If I asked for other changes in the same message (before or after `/address-comments`), do those
  and get them working before addressing the review.

## 1. Detect the PR/MR
- Identify the hosts from `git remote -v` (`github.com` → GitHub, `gitlab.com`/self-hosted → GitLab),
  the same way `/pr` does — there may be a GitHub PR, a GitLab MR, or both.
- Find the open PR/MR for the current branch (GitHub: `gh pr view`; GitLab: `glab mr view`), or use
  the number/URL I passed. If both hosts have one and it's ambiguous, ask which to address.
- Make sure I'm on that PR/MR's branch (`git status`); if not, check it out. If it turns out I'm on a
  protected branch, stop and warn me.

## 2. Fetch the review comments
- **GitHub**: general + review comments via `gh pr view --comments` and the inline review comments
  (`gh api repos/{owner}/{repo}/pulls/{n}/comments`). Fallback: `mcp__github__pull_request_read`.
- **GitLab**: read the discussion threads via `mcp__gitlab__mr_discussions` (or
  `glab api "projects/:id/merge_requests/:iid/discussions"`); `glab mr view` shows the summary.
  (Note: `glab mr note` only *adds* notes — it's not for listing them.)
- Pull down the latest first (`git pull`) so I'm editing against the reviewed state.

## 3. Triage the feedback
- List each comment with its `file:line`, the reviewer, and what they're asking. Classify each as:
  **change requested** (actionable code edit), **question** (needs a reply, maybe no code change), or
  **nit/praise** (optional / no action). Group by file.
- Skip already-resolved/outdated threads unless they still apply.

## 4. Apply the changes
- For each **change requested**, make the focused edit that addresses exactly that comment — nothing
  unrelated. Keep the reviewer's intent; if a request seems wrong or risky, note it for a reply
  instead of silently ignoring it.
- For each **question**, draft a reply (don't invent a code change).
- After the edits, run the build/tests to confirm nothing broke.

## 5. Commit and push
- Commit the fixes following my `CLAUDE.md` rules (atomic, Conventional Commits, imperative, **no**
  `Co-Authored-By`). Group by logical change; reference the review where it helps (e.g. what was
  addressed).
- Push so the PR/MR updates.

## 6. Reply and resolve — outward-facing, confirm first
- **Ask before posting anything.** Then, for each thread, reply briefly (e.g. `Done in <sha>` or the
  answer to a question) and resolve it — GitHub: reply via `gh`/GraphQL and resolve with
  `resolveReviewThread`; GitLab: reply with `glab mr note <id> -m "…"` and resolve via
  `mcp__gitlab__resolve_merge_request_thread`.
- Leave threads I disagreed with open, with a reply explaining why.

## 7. Report
- Summarize: which comments were addressed (and how), which got a reply instead of a change, and
  anything left open with the reason. Show the PR/MR link.
