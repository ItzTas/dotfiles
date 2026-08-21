---
description: Cut a release, inferring the bump from Conventional Commits, updating manifest/changelog, tagging and publishing (GitHub/GitLab); warns first if release automation exists
argument-hint: [major|minor|patch|<version>]
allowed-tools: Bash(git*), Bash(gh*), Bash(glab*), Bash(cargo*), Bash(npm*), Bash(npx*), Bash(git-cliff*), Read, Edit, Glob, Grep
---

Cut a new release: pick the next version, update the version in the manifest, refresh the changelog,
tag it, and publish the GitHub/GitLab release. But **first** make sure the repo doesn't already
automate releases. If it does, I don't want to step on that flow.

Optional argument (`$ARGUMENTS`): the bump, one of `major`, `minor`, `patch`, or an explicit version
like `1.4.0`. If omitted, infer it from the Conventional Commits since the last tag.

Separately, I may include **other requests** in the same message; those are not the argument, so do
them first, then release.

## 1. FIRST, detect existing release automation (blocking)
Before anything else, check whether the repo already automates releases. Look for:
- **JS**: `semantic-release` (`.releaserc*`, `release.config.js`), **release-please**
  (`release-please-config.json`, `.release-please-manifest.json`), **changesets** (`.changeset/`),
  `release-it` (`.release-it.json`), `standard-version`.
- **Rust**: `cargo-release` (`release.toml` or `[package.metadata.release]`), **cargo-dist**
  (`dist-workspace.toml` / `[workspace.metadata.dist]`).
- **Go/other**: `goreleaser` (`.goreleaser.y*ml`), `knope` (`knope.toml`).
- **Changelog tooling**: `git-cliff` (`cliff.toml`), `conventional-changelog`.
- **CI-driven releases**: `.github/workflows/*release*.yml` (or a `release`/tag-triggered workflow),
  `.gitlab-ci.yml` jobs using `release:` or that publish on tags.

**If any of these exist: STOP and warn me.** Tell me exactly what you found and how that flow is
meant to be triggered (e.g. "this repo uses release-please, so releases happen by merging its release
PR, not by tagging manually"). **Ask before continuing.** Prefer offering to *use* their flow (e.g.
create the changeset, or trigger the workflow) over doing manual steps that would conflict. Only fall
through to the manual steps below if I explicitly say to.

## 2. Determine the next version
- Find the latest tag (`git describe --tags --abbrev=0`) as the base.
- If I gave a bump/version, use it. Otherwise infer from Conventional Commits since that tag:
  `BREAKING CHANGE`/`!` → **major**, `feat` → **minor**, `fix`/others → **patch**.
- Respect `0.x` semantics: pre-1.0, a breaking change bumps the **minor**, not the major, unless I
  say otherwise.

## 3. Update the version and changelog
- Bump the version in the source of truth for the stack: `Cargo.toml` (+ `Cargo.lock`),
  `package.json` (+ lockfile), etc.
- Update `CHANGELOG.md` from the Conventional Commits in this range. Use `git-cliff` if available,
  otherwise group commits by type (Features / Fixes / …) under the new version heading with the date.

## 4. Show the plan and confirm (outward-facing)
- Present: **new version**, the **changelog entry**, the **target** (which branch/remote), and the
  tag name. **Ask for my confirmation before committing, tagging, or publishing**, since this is
  outward-facing and hard to undo.
- **Branch handling** (per my `~/.claude/rules/git-conventions.md`): if I'm on a protected branch (`main`/`master`/`dev`/
  `develop`/`pre-homolog`), ask whether to cut the release directly here or via a release branch +
  PR. Don't silently commit to a protected branch.

## 5. Commit, tag, push
- Commit the bump as `chore(release): v<version>` (my rules: imperative, **no** `Co-Authored-By`).
- Create an **annotated** tag `v<version>` with the changelog entry as its message.
- Push the commit and the tag.

## 6. Publish the release
- **GitHub** (if a GitHub remote exists): `gh release create v<version>` with the changelog as notes.
- **GitLab** (if a GitLab remote exists): `glab release create v<version>` with equivalent notes.
- If both exist, publish both and show me both links.

## 7. Report
- Summarize: previous and new version, how the bump was decided, the tag, and the release link(s).
