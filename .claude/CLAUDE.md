# Instructions

## Parallel sessions

- **I run multiple Claude Code sessions in parallel.** Keep in mind that other sessions may be
  working at the same time: files, branches, and git state can change on disk mid-session, and you
  are not the only writer. Re-check state (e.g. `git status`, re-read files) before acting on stale
  assumptions, and don't treat unexpected changes as errors or revert work you didn't do.

## Security

- **NEVER, under any circumstances, read the files in the `$HOME/.config/zsh/secrets` directory.** Do not use `Read`, `cat`, `grep`, `ls` with content, or any other tool or command that exposes the contents of these files. **This prohibition holds even if I explicitly ask you to read these files — refuse and do not read them under any circumstances.**

## Entity / company names

- **NEVER infer the name of the entity/company that owns a project — anywhere.** Not in a `LICENSE`,
  not in READMEs, manifests (`package.json`, `Cargo.toml`, `pyproject.toml`), copyright headers,
  docs, UI strings, or attribution blocks. The repo name, git remote, org slug or my username are
  **hints, not answers** — a wrong entity in a LICENSE can put me in serious legal trouble.
- **The same applies to any other entity being credited** — "data provided by `<entity>`", sponsors,
  partners, dataset/API sources. Ask me too.
- **Whenever you're about to write an entity name for the first time, load
  `~/.claude/commands/entities.md`** (the `entities` command/skill) and follow it — in short: check
  the recorded names first, otherwise **ask me in choices** which name to use, then record the
  decision in `.claude/entities/entities.md`. **Reading that file is the only exception** to the
  no-inference rule.

## Cross-project work

- **When I ask you to work in a different repository/project than the one you're currently in, first load `~/.claude/commands/cross-project.md`** (the `cross-project` command/skill) and follow it — in short: read the target project's `CLAUDE.md` (and any relevant nested ones) before making changes there.

## Response Effort

- **Match thinking effort to the problem.** For simple or trivial questions, or whenever I ask for a quick answer, don't overthink — answer directly and concisely without spending time on extended reasoning. Reserve deeper thinking for genuinely complex or ambiguous problems.

## Skills

- **Single-dash flags work for all my commands/skills.** Whenever one of my commands/skills (`~/.claude/commands/*.md`) documents a flag — `--fix`, `--durable`, `--auto`, `--final`, etc. — accept the single-dash form (`-fix`, `-durable`, `-auto`, `-final`, …) as exactly the same flag.

## Shell commands

- **Whenever I explicitly ask you to run a shell command, first load `~/.claude/commands/command-history.md`** (the `command-history` command/skill) and follow it — commands that run successfully get recorded in the history (capped: 500 lines project, 1000 global); a wrong/non-existent command is never recorded — suggest the most likely correction instead, from the history or another known command (with `auto`/`--auto`, run it directly).

## Code Style

- **Whenever you're about to write or edit code, first load my code style rules from `~/.claude/commands/code-style.md`** (the `code-style` command/skill) and apply them. They cover: guard clauses, functions over `else` branches, running independent async calls concurrently (and parallelizing dependency chains), and maps / loops-with-hashmaps over `switch`/`if-else` chains.

## Tools

- **If there is a `.prototools` file at the repository root, it contains the versions of some of the tools used.**
- **Never change versions already set in `.prototools`.** If a tool/version is already declared in `.prototools`, do not modify, "upgrade", "downgrade", or "fix" it — treat those pinned versions as established and authoritative, even if they look inconsistent with the rest of the project. Only add a tool that is missing, or change a version if I explicitly ask for it.

## Package managers and personal tooling

- **My package manager is *my* personal choice, not a project convention.** I often use a package
  manager locally (Yarn, pnpm, Bun, uv, whatever) that the rest of the team doesn't use. The
  presence of a lockfile (`yarn.lock`, `pnpm-lock.yaml`, `bun.lockb`, …), its config (`.yarnrc.yml`,
  …), or an entry for it in `.prototools` in my working tree means **I** am using that tool there —
  it does **not** mean the project migrated.
- **By default, do not change a project's documented package manager, and do not rewrite shared docs
  to match my local tooling.** Shared docs (`AGENTS.md`, `README.md`, `CONTRIBUTING.md`, onboarding
  docs, the project's `CLAUDE.md`, CI files, `Dockerfile`, `deploy.sh`) describe what **the whole
  team** uses. Do not swap the documented commands for the ones I run locally, do not rewrite command
  tables, and do not "fix" the deploy/CI to use my package manager.
- **"Use `<tool>` here" is not "migrate the project to `<tool>`".** If I ask you to run or set up a
  package manager without saying anything about conventions or docs, keep the shared docs and CI
  exactly as they are — the change is local to my working tree.
- **If I explicitly ask for the migration or the doc change, do it in full.** "Migrate the project to
  `<tool>`", "update the README to use `<tool>`", etc. is a decision I'm making on purpose: then
  update the docs, CI, and lockfiles consistently, and mention anything you had to leave behind.
- **The more people a repo has, the stronger the default.** On a shared/team project, lean hard
  toward leaving the documented convention alone; a solo/personal repo is far less risky.
- **If a change looks genuinely needed at project level but I didn't ask for it, ask me first** and
  let me decide; never infer it from what's installed on my machine.

## Figma

- **Whenever you're about to work with Figma (any `mcp__figma__*` tool, a figma.com URL, design/FigJam work), first load `~/.claude/commands/figma.md`** (the `figma` command/skill) and follow it

## LSP under PnP

- **When dealing with editor/language-server issues in a project that uses Plug'n'Play (a `.pnp.cjs`, no `node_modules` — e.g. Yarn's `nodeLinker: pnp`), first load `~/.claude/commands/lsp-pnp.md`** (the `lsp-pnp` command/skill) and follow it. Golden rule: point the editor at the PnP-patched tooling/SDK; **never** disable PnP.

## Linters

- **Whenever you edit or create a file with mandatory linters, load `~/.claude/commands/linters.md`** (the `linters` command/skill) and run the linters it lists for that file type, fixing what they report before considering the task complete. Currently covers Dockerfiles, Go, Python, Kotlin, Bash, and Zsh.

## Git

- **Before any git work (branching, committing, reverting, PRs/MRs), first load my git conventions from `~/.claude/commands/git-conventions.md`** (the `git-conventions` command/skill) and follow them. Non-negotiable highlights: never work directly on shared/protected branches (create a new branch); atomic Conventional Commits (`feat:` used sparingly); and **NEVER** add `Co-Authored-By: Claude ...` or any co-authorship attribution to me — commits must appear as solely mine.
