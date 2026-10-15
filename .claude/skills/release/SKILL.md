---
name: release
description: Cut a release, inferring the bump from Conventional Commits, updating manifest/changelog, tagging and publishing (GitHub/GitLab); warns first if release automation exists
argument-hint: [major|minor|patch|<version>]
allowed-tools: Bash(git*), Bash(gh*), Bash(glab*), Bash(cargo*), Bash(npm*), Bash(npx*), Bash(git-cliff*), Read, Edit, Glob, Grep, Bash(~/.claude/skills/release/scripts/*), Bash(~/.claude/scripts/forge-detect.sh*)
---

Cut a new release: pick the next version, update the version in the manifest, refresh the changelog,
tag it, and publish the GitHub/GitLab release. But **first** make sure the repo doesn't already
automate releases. If it does, I don't want to step on that flow.

Optional argument (`$ARGUMENTS`): the bump, one of `major`, `minor`, `patch`, or an explicit version
like `1.4.0`. If omitted, infer it from the Conventional Commits since the last tag.

Separately, I may include **other requests** in the same message; those are not the argument, so do
them first, then release.

## 1. FIRST, detect existing release automation (blocking)

```
~/.claude/skills/release/scripts/detect-automation.py
→ {"count", "found": [{"tool", "kind", "evidence": ["path[:line]"], "trigger"}]}   exit 1 = found
```

It covers the JS/Rust/Go/Python release and changelog tools and CI that releases on tags. **If
anything is found: STOP and warn me.** Tell me exactly what (`evidence`) and how that flow is meant
to be triggered (`trigger`, e.g. "releases happen by merging release-please's PR, not by tagging
manually"). **Ask before continuing.** Prefer offering to *use* their flow (e.g. create the
changeset, or trigger the workflow) over conflicting manual steps. Only fall through to the steps
below if I explicitly say to.

## 2. Determine the next version

```
~/.claude/skills/release/scripts/next-version.py [major|minor|patch|<version>]
→ {"protected_branch", "last_tag", "commits": {"<type>": [{"sha", "subject", "breaking"}]}, "bump", "reason",
   "next_version", "next_tag", "manifests": [{"path", "version", "field", "note"}], "lockfiles", "warnings"}
```

Without my bump it infers from the commits since the last tag: `BREAKING CHANGE`/`!` → **major**,
`feat` → **minor**, `fix`/others → **patch**; pre-1.0 a breaking change bumps the **minor**
unless I say otherwise. Exit 1: nothing since the last tag, tell me. Relay `warnings`.

## 3. Update the version and changelog
- Bump the version where `manifests` says (`field`; `dynamic`/`inherits` means it lives elsewhere):
  `Cargo.toml` (+ `Cargo.lock`), `package.json` (+ lockfile), etc.
- Update `CHANGELOG.md` from `commits`: `git-cliff` if available, otherwise by type (Features / Fixes
  / …) under the new version heading with the date.

## 4. Show the plan and confirm (outward-facing)
- Present: **new version**, the **changelog entry**, the **target** (which branch/remote), and the
  tag name. **Ask for my confirmation before committing, tagging, or publishing**, since this is
  outward-facing and hard to undo.
- **Branch handling** (per my `~/.claude/rules/git-conventions.md`): if `protected_branch`, ask
  whether to cut it here or via a release branch + PR. Don't silently commit to a protected branch.

## 5. Commit, tag, push
- Commit the bump as `chore(release): v<version>` (my rules: imperative, **no** `Co-Authored-By`).
- Create an **annotated** tag `v<version>` (`next_tag` keeps the repo's tag prefix) with the
  changelog entry as its message. Push the commit and the tag.

## 6. Publish the release
- Per remote in `~/.claude/scripts/forge-detect.sh`: **GitHub** `gh release create v<version>`,
  **GitLab** `glab release create v<version>`, with the changelog as notes. Both: publish both links.

## 7. Report
- Summarize: previous and new version, how the bump was decided, the tag, and the release link(s).
