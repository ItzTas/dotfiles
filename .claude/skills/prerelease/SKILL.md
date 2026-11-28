---
name: prerelease
description: Write or remove a project-specific pre-release section in the project's CLAUDE.md that allows large rewrites and removals while the project has no users, with a removal condition I choose
argument-hint: "[on [condition] | off | when <condition> | check <action>]"
disable-model-invocation: true
allowed-tools: Read, Edit, Write, Grep, Glob, AskUserQuestion, Bash(git*), Bash(ls*), Bash(find*), Bash(sed -n*)
---

Write or remove the **pre-release section** in the current project's `CLAUDE.md`. While the project
has no users, the section tells Claude to pick the best solution even when it breaks or deletes
things. Each project is different, so you write the section for this project, not a fixed text.
The section goes away when its **removal condition** is met, and I choose that condition.

Arguments (`$ARGUMENTS`):
- `on [condition]` writes the section. Anything after `on` is the removal condition, in my words.
- `off` removes it.
- `when <condition>` replaces the removal condition of an existing section.
- `check <action>` says whether an action about to happen (e.g. "open MR dev -> main", "create
  tag v0.1.0", "create branch dev") meets the condition, and removes the section if it does.
- No argument: toggle. Write it if missing, remove it if present, and tell me which one happened.

Separately, I may include **other requests** in the same message; those are not the argument, so
handle them as normal work.

## Markers

The section always sits between these two lines, each on its own line, and the first line inside
the block holds the removal condition:

```
<!-- prerelease:start -->
<!-- prerelease:remove-when: <condition> -->
...
<!-- prerelease:end -->
```

They don't render in Markdown. A tool deletes the block with
`sed '/<!-- prerelease:start -->/,/<!-- prerelease:end -->/d'` and reads the condition with
`grep -o 'prerelease:remove-when: .* -->' CLAUDE.md`. Never put anything that must outlive the
section inside the block.

Write the condition as concrete, checkable events joined by "or", in English whatever the file's
language, so any tool can match it against what it's about to do. Good: `first PR/MR from dev into
main`, `first version tag or first long-lived branch besides main`. Bad: `when it's stable`.

## Find the file

- Use `CLAUDE.md` at the repo root (`git rev-parse --show-toplevel`), or `.claude/CLAUDE.md` if only
  that one exists. If `AGENTS.md` exists and mirrors `CLAUDE.md` (same content or a symlink), apply
  the same change to both, once if it's a symlink.
- If none exists: for `off`, `when` and `check`, say there is nothing to do; for `on`, ask me before
  creating one.

## On

### 1. Check what's already there
- Markers present: say so and change nothing (use `when` to change the condition).
- An **unmarked** section or bullet already says the same thing (no production/users yet, rewrites
  or deletions are fine, remove at first release): don't add a second one. Show it to me and offer
  to wrap it in the markers as is, or to rewrite it inside the markers.

### 2. Learn the project
Read the rest of `CLAUDE.md` and look at the repo enough to answer:
- **Environments**: is there a staging environment, and who uses it? Is there production?
- **What can break**: database and migrations (where, which tool, numbered files), public API or
  wire contract and who consumes it, generated files (OpenAPI, clients), stored data, config or
  file formats, sibling repos that depend on this one or that this one depends on.
- **How dev state is rebuilt** after a breaking change: recreate the database, rerun seed, etc.
- **Rules elsewhere that this section overrides**, such as a skill or rule saying applied
  migrations are immutable.
- **Release and branch flow**: tags (`git tag`), long-lived branches (`dev`, `main`, `staging`),
  and when the last PR/MR between them was opened.

### 3. Settle the removal condition
- If I gave one after `on`, use it, rewritten as checkable events if it's vague (show me the
  rewrite).
- Otherwise ask me with `AskUserQuestion`, offering options from step 2 that fit the repo, e.g.
  `first version tag`, `first PR/MR from dev into main`, `first long-lived branch besides main`,
  `first production deploy`, each with why it fits (e.g. "no PR from dev into main since <date>").

### 4. Write the section
Use the file's language and its heading style. Keep it short: a heading, one paragraph, and one
bold line about removal. Model it on these real ones:

```
<!-- prerelease:start -->
<!-- prerelease:remove-when: first MR from dev into main -->
## No staging or production yet

The project has no staging or production environment yet, so there are no real users or deployed
clients to stay compatible with. Large rewrites and deletions are fine: remove pages, components and
stores outright, rename routes, and follow back-end contract changes without keeping a
compatibility layer.

**Remove this section with the first MR from `dev` into `main`.**
<!-- prerelease:end -->
```

```
<!-- prerelease:start -->
<!-- prerelease:remove-when: first MR from dev into main -->
## No staging or production yet

The project has no staging or production environment yet. There is no database with real data and
no API client to stay compatible with, so large rewrites and deletions are fine: delete code,
modules or routes, change the API contract, and rewrite existing migrations instead of stacking a
new `ALTER` migration on top of them. Anyone with a dev database recreates it and reruns the seed.

**Remove this section with the first MR from `dev` into `main`.** From then on, applied migrations
no longer change and every schema change goes into a new migration.
<!-- prerelease:end -->
```

The paragraph must:
- State the real situation from step 2 (no production; staging only used by the developer;
  etc.). Don't claim something you didn't check.
- Name this project's concrete things that may be deleted or reshaped, not a generic list.
- Say to change existing things **in place** instead of stacking new layers on top, naming the
  versioned files when they exist (e.g. rewrite, merge or renumber applied migrations instead of
  adding a new `ALTER` migration). Say how dev state is rebuilt afterwards.
- Say not to leave transition layers and not to give up on a change because it breaks dev or
  staging data.
- Say to pick the best solution, not the one that breaks the least.

The bold removal line states the condition from step 3 in the file's language and, when step 2
found any, what changes back once the section is gone (e.g. applied migrations become immutable
again, a skill's rule comes back, a sibling repo's section goes too).

Place it near the top, after the project overview and before commands or architecture, so it
reads as a standing condition of the whole file.

### 5. Show me
Print the section you wrote and the file, and say what in step 2 each claim came from.

## When

Replace the condition in the `prerelease:remove-when` line (settled as in **On** step 3) and
rewrite the bold removal line to match, in the file's language. Change nothing else.

## Check

Used by me, by other skills (`/release`, `/pr`) and by any agent about to cut a tag, open a PR/MR or
create a long-lived branch.

1. Read the `prerelease:remove-when` line. No block: nothing to do.
2. Decide whether the action meets any of the events in the condition. Match on meaning, e.g. an MR
   from `dev` into `main` meets `first PR/MR from dev into main`; a feature branch merged into
   `dev` does not meet `first long-lived branch besides main`. When unsure, ask me.
3. Met: tell me, then run **Off** as part of the same change (same commit, same PR/MR) unless I
   say otherwise. Not met: say nothing more.

A block with markers but no `remove-when` line uses `first release` as its condition.

## Off

1. Read the block between the markers.
2. If its removal line asks for follow-ups (restore a rule in a skill, remove the matching section
   in a sibling repo, etc.), list them. Apply the ones inside this repo; for other repos, ask me
   first.
3. Delete everything from `<!-- prerelease:start -->` to `<!-- prerelease:end -->`, both included.
   If that leaves two blank lines in a row, collapse them into one.
4. No markers but an unmarked pre-release section exists: show it and ask before deleting.

## Report
Say which file(s) changed, whether the section was written, removed, re-conditioned, or already in
that state, and any follow-ups still pending. Don't commit.
