# Instructions

## Parallel sessions

- **I run multiple Claude Code sessions in parallel.** Keep in mind that other sessions may be
  working at the same time: files, branches, and git state can change on disk mid-session, and you
  are not the only writer. Re-check state (e.g. `git status`, re-read files) before acting on stale
  assumptions, and don't treat unexpected changes as errors or revert work you didn't do.

## Entity / company names

- **NEVER infer the name of the entity/company that owns a project, anywhere.** Not in a `LICENSE`,
  not in READMEs, manifests (`package.json`, `Cargo.toml`, `pyproject.toml`), copyright headers,
  docs, UI strings, or attribution blocks. The repo name, git remote, org slug or my username are
  **hints, not answers**. A wrong entity in a LICENSE can put me in serious legal trouble.
- **The same applies to any other entity being credited**: "data provided by `<entity>`", sponsors,
  partners, dataset/API sources. Ask me too.
- **Whenever you're about to write an entity name for the first time, load
  `~/.claude/commands/entities.md`** (the `entities` command/skill) and follow it.

## Cross-project work

- **When I ask you to work in a different repository/project than the one you're currently in, first load `~/.claude/rules/cross-project.md`** (rule file) and follow it.

## Response Effort

- **Match thinking effort to the problem.** For simple or trivial questions, or whenever I ask for a quick answer, don't overthink; answer directly and concisely without spending time on extended reasoning. Reserve deeper thinking for genuinely complex or ambiguous problems.

## User-facing text

- **Run the `/humanizer:humanizer` skill on prose written for people other than me**: UI copy and
  error messages shown to an app's users, emails, documents (e.g. ones filed in SEI), docs, PR/MR
  bodies, issues, changelog entries, before it lands in a file or gets sent. Short text counts too.
- **Never run it on your replies to me.** Chat answers, status updates, explanations and questions
  addressed to me in the session are not "user-facing text"; don't load the skill for them.
- **Optional for commit messages.** Run it if the body is long enough to read like prose, but
  don't feel obliged to.
- **Skip it for** code, identifiers, config, structured data, quoted error strings, and command
  output.
- **Skip it when the project has its own writing rules.** If the repo already defines how
  user-facing text should be written (a style guide, tone-of-voice rules, doc/commit conventions in
  its `CLAUDE.md`, `CONTRIBUTING.md`, or similar), follow those instead. The project's rules win,
  and there's no need to run the skill on top of them.

## Analyses and factual claims

- **Before investigating data/systems to answer a factual question, and always before drafting
  text that states facts for someone else, load `~/.claude/rules/analysis.md`** (rule file) and
  follow it. `/analysis` runs the full flow with an independent `fact-checker` agent.

## Shell commands

- **Whenever I explicitly ask you to run a shell command, first load `~/.claude/rules/command-history.md`** (rule file) and follow it.

## Code Style

- **Whenever you're about to write or edit code, first load my code style rules from `~/.claude/rules/code-style.md`** (rule file) and apply them.

## Error handling

- **Before writing or editing a `try`/`catch` block (or `try/except`, `begin/rescue`, `do/catch`, …), or initializing/scaffolding a new project in a try/catch language, first load `~/.claude/rules/error-handling.md`** (rule file) and follow it.

## Tests

- **Whenever you're about to write, edit, or delete tests, first load `~/.claude/rules/tests.md`** (rule file) and follow it.

## Tools

- **If there is a `.prototools` file at the repository root, it contains the versions of some of the tools used.**
- **Never change versions already set in `.prototools`.** If a tool/version is already declared in `.prototools`, do not modify, "upgrade", "downgrade", or "fix" it. Treat those pinned versions as established and authoritative, even if they look inconsistent with the rest of the project. Only add a tool that is missing, or change a version if I explicitly ask for it.

## Package managers and personal tooling

- **Whenever a package manager is in play (installing deps, lockfiles, a package-manager entry in
  `.prototools`, or editing shared docs/CI that mention one), first read
  `~/.claude/rules/package-managers.md`** (rule file) and follow it.

## Libraries / dependencies

- **Before adding any third-party library to a project or recommending one to me, first load
  `~/.claude/rules/libraries.md`** (rule file) and follow it.

## Figma

- **Whenever you're about to work with Figma (any `mcp__figma__*` tool, a figma.com URL, design/FigJam work), first load `~/.claude/rules/figma.md`** (rule file) and follow it.

## LSP under PnP

- **When dealing with editor/language-server issues in a project that uses Plug'n'Play (a `.pnp.cjs`, no `node_modules`, e.g. Yarn's `nodeLinker: pnp`), first load `~/.claude/rules/lsp-pnp.md`** (rule file) and follow it.

## Linters

- **Whenever you edit or create a file with mandatory linters, load `~/.claude/rules/linters.md`** (rule file) and run the linters it lists for that file type, fixing what they report before considering the task complete.

## Git

- **Before any git work (branching, committing, reverting, PRs/MRs), first load my git conventions from `~/.claude/rules/git-conventions.md`** (rule file) and follow them. **NEVER** add `Co-Authored-By: Claude ...` or any co-authorship attribution to me, since commits must appear as solely mine.
