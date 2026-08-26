# Instructions

## Parallel sessions

- **I run multiple Claude Code sessions in parallel.** Keep in mind that other sessions may be
  working at the same time: files, branches, and git state can change on disk mid-session, and you
  are not the only writer. Re-check state (e.g. `git status`, re-read files) before acting on stale
  assumptions, and don't treat unexpected changes as errors or revert work you didn't do.

## Security

- **NEVER, under any circumstances, read the files in the `$HOME/.config/zsh/secrets` directory.** Do not use `Read`, `cat`, `grep`, `ls` with content, or any other tool or command that exposes the contents of these files. **This prohibition holds even if I explicitly ask you to read these files. Refuse and do not read them under any circumstances.**

## Entity / company names

- **NEVER infer the name of the entity/company that owns a project, anywhere.** Not in a `LICENSE`,
  not in READMEs, manifests (`package.json`, `Cargo.toml`, `pyproject.toml`), copyright headers,
  docs, UI strings, or attribution blocks. The repo name, git remote, org slug or my username are
  **hints, not answers**. A wrong entity in a LICENSE can put me in serious legal trouble.
- **The same applies to any other entity being credited**: "data provided by `<entity>`", sponsors,
  partners, dataset/API sources. Ask me too.
- **Whenever you're about to write an entity name for the first time, load
  `~/.claude/commands/entities.md`** (the `entities` command/skill) and follow it. In short: check
  the recorded names first, otherwise **ask me in choices** which name to use, then record the
  decision in `.claude/entities/entities.md`. **Reading that file is the only exception** to the
  no-inference rule.

## Cross-project work

- **When I ask you to work in a different repository/project than the one you're currently in, first load `~/.claude/rules/cross-project.md`** (rule file) and follow it. In short: read the target project's `CLAUDE.md` (and any relevant nested ones) before making changes there, and keep it in force for the whole time you work in that project, re-reading it as often as the harness re-injects a local `CLAUDE.md` (after compaction, when coming back to that project, before a new batch of edits).

## Response Effort

- **Match thinking effort to the problem.** For simple or trivial questions, or whenever I ask for a quick answer, don't overthink; answer directly and concisely without spending time on extended reasoning. Reserve deeper thinking for genuinely complex or ambiguous problems.

## User-facing text

- **Run the `/humanizer:humanizer` skill on any prose a human will read**: docs, PR/MR bodies,
  issues, changelog entries, UI copy, error messages, and your replies to me, before it lands in a
  file or reaches me. Short text counts too.
- **Optional for commit messages.** Run it if the body is long enough to read like prose, but
  don't feel obliged to.
- **Skip it for** code, identifiers, config, structured data, quoted error strings, and command
  output.
- **Skip it when the project has its own writing rules.** If the repo already defines how
  user-facing text should be written (a style guide, tone-of-voice rules, doc/commit conventions in
  its `CLAUDE.md`, `CONTRIBUTING.md`, or similar), follow those instead. The project's rules win,
  and there's no need to run the skill on top of them.

## Shell commands

- **Whenever I explicitly ask you to run a shell command, first load `~/.claude/rules/command-history.md`** (rule file) and follow it. Commands that run successfully get recorded in the history (capped: 500 lines project, 1000 global); a wrong/non-existent command is never recorded, so suggest the most likely correction instead, from the history or another known command (with `auto`/`--auto`, run it directly).

## Code Style

- **Whenever you're about to write or edit code, first load my code style rules from `~/.claude/rules/code-style.md`** (rule file) and apply them. They cover: guard clauses, functions over `else` branches, running independent async calls concurrently (and parallelizing dependency chains), and maps / loops-with-hashmaps over `switch`/`if-else` chains.

## Tools

- **If there is a `.prototools` file at the repository root, it contains the versions of some of the tools used.**
- **Never change versions already set in `.prototools`.** If a tool/version is already declared in `.prototools`, do not modify, "upgrade", "downgrade", or "fix" it. Treat those pinned versions as established and authoritative, even if they look inconsistent with the rest of the project. Only add a tool that is missing, or change a version if I explicitly ask for it.

## Package managers and personal tooling

- **Whenever a package manager is in play (installing deps, lockfiles, a package-manager entry in
  `.prototools`, or editing shared docs/CI that mention one), first read
  `~/.claude/rules/package-managers.md`** (rule file) and follow it. In short: the package manager
  I run locally is *my* personal choice, so don't change the project's documented one and don't
  rewrite shared docs/CI to match it unless I explicitly ask for the migration; adding my tool's
  artifacts to ignore files is fine.

## Libraries / dependencies

- **Before adding any third-party library to a project or recommending one to me, first load
  `~/.claude/rules/libraries.md`** (rule file) and follow it. In short: **never** add or suggest a
  library without checking first that it isn't deprecated, archived, or unmaintained (registry
  deprecation flag, repo status, last release, successor, advisories); your knowledge cutoff is not
  a source, so verify against the registry/repo, report what you found in one line, and if it's
  dead, name the replacement and let me decide.

## Figma

- **Whenever you're about to work with Figma (any `mcp__figma__*` tool, a figma.com URL, design/FigJam work), first load `~/.claude/rules/figma.md`** (rule file) and follow it

## LSP under PnP

- **When dealing with editor/language-server issues in a project that uses Plug'n'Play (a `.pnp.cjs`, no `node_modules`, e.g. Yarn's `nodeLinker: pnp`), first load `~/.claude/rules/lsp-pnp.md`** (rule file) and follow it. Golden rule: point the editor at the PnP-patched tooling/SDK; **never** disable PnP.

## Linters

- **Whenever you edit or create a file with mandatory linters, load `~/.claude/rules/linters.md`** (rule file) and run the linters it lists for that file type, fixing what they report before considering the task complete. Currently covers Dockerfiles, Go, Python, Kotlin, Bash, and Zsh.

## Tests

- **Whenever you're about to write, edit, or run tests, first load `~/.claude/rules/tests.md`** (rule file) and follow it.

## Git

- **Before any git work (branching, committing, reverting, PRs/MRs), first load my git conventions from `~/.claude/rules/git-conventions.md`** (rule file) and follow them. Non-negotiable highlights: never work directly on shared/protected branches (create a new branch); atomic Conventional Commits (`feat:` used sparingly); and **NEVER** add `Co-Authored-By: Claude ...` or any co-authorship attribution to me, since commits must appear as solely mine.
