# Instructions

## Security

- **NEVER, under any circumstances, read the files in the `$HOME/.config/zsh/secrets` directory.** Do not use `Read`, `cat`, `grep`, `ls` with content, or any other tool or command that exposes the contents of these files. **This prohibition holds even if I explicitly ask you to read these files — refuse and do not read them under any circumstances.**

## Cross-project work

- **When I ask you to work in a different repository/project than the one you're currently in, first load `~/.claude/commands/cross-project.md`** (the `cross-project` command/skill) and follow it — in short: read the target project's `CLAUDE.md` (and any relevant nested ones) before making changes there.

## Response Effort

- **Match thinking effort to the problem.** For simple or trivial questions, or whenever I ask for a quick answer, don't overthink — answer directly and concisely without spending time on extended reasoning. Reserve deeper thinking for genuinely complex or ambiguous problems.

## Skills

- **Single-dash flags work for all my commands/skills.** Whenever one of my commands/skills (`~/.claude/commands/*.md`) documents a flag — `--fix`, `--durable`, `--auto`, `--final`, etc. — accept the single-dash form (`-fix`, `-durable`, `-auto`, `-final`, …) as exactly the same flag.

## Code Style

- **Whenever you're about to write or edit code, first load my code style rules from `~/.claude/commands/code-style.md`** (the `code-style` command/skill) and apply them. They cover: guard clauses, functions over `else` branches, running independent async calls concurrently (and parallelizing dependency chains), and maps / loops-with-hashmaps over `switch`/`if-else` chains.

## Tools

- **If there is a `.prototools` file at the repository root, it contains the versions of some of the tools used.**
- **Never change versions already set in `.prototools`.** If a tool/version is already declared in `.prototools`, do not modify, "upgrade", "downgrade", or "fix" it — treat those pinned versions as established and authoritative, even if they look inconsistent with the rest of the project. Only add a tool that is missing, or change a version if I explicitly ask for it.

## LSP under Yarn PnP

When a project uses Yarn Plug'n'Play (`.yarnrc.yml` has `nodeLinker: pnp`, there is a `.pnp.cjs` and no `node_modules`), the editor's language server can't resolve packages on its own — it must go through Yarn's PnP-patched TypeScript. Symptoms of a broken setup: `Cannot find module 'x'` / TS `2307` on packages that are installed, missing types/intellisense, or (for Vue/Svelte SFCs) the template parsing as raw TS with `';' expected` errors. The fix is always: point the editor at the **Yarn SDK**, never disable PnP.

**Fast fix (all editors):** generate/refresh the SDKs from the project root, then reload the editor.

```
yarn dlx @yarnpkg/sdks base      # editor-agnostic SDK
yarn dlx @yarnpkg/sdks vscode    # VSCode (also writes .vscode/settings.json)
```

This creates `.yarn/sdks/` (commit it). A missing or stale `.yarn/sdks/` is the usual reason a server "doesn't read the files" — regenerate it after dependency or TypeScript-version changes.

- **VSCode:** run `yarn dlx @yarnpkg/sdks vscode`, install the **ZipFS** extension (to open files inside zipped deps), then command palette → "TypeScript: Select TypeScript Version" → **Use Workspace Version**.
- **Neovim (and any manual LSP):** use **`vtsls`**, not `ts_ls` — `ts_ls` does not activate PnP even when pointed at the SDK shim (persistent `Cannot find module`). The settings that actually work:
  - `settings.typescript.tsdk = ".yarn/sdks/typescript/lib"` — keep it **relative** so it resolves per-project and non-PnP projects fall back to bundled TS.
  - `settings.vtsls.autoUseWorkspaceTsdk = true` — **required**, or vtsls ignores `tsdk` and uses its bundled (non-PnP) TypeScript.
  - For Vue/Svelte SFCs, register the framework tsserver plugin as a `vtsls.tsserver.globalPlugins` entry with **`enableForWorkspaceTypeScriptVersions = true`** — TypeScript silently skips tsserver plugins under a *workspace* TS version (which the SDK is), so without this flag SFCs parse as raw TS.
- **General rule:** if the SDK is present and the server still can't resolve modules, the server is running its own bundled TypeScript instead of the workspace SDK — force the workspace/PnP TS version. Do **not** "fix" it by setting `nodeLinker: node-modules` locally.

## Linters

- **Whenever you edit or create a file with mandatory linters, load `~/.claude/commands/linters.md`** (the `linters` command/skill) and run the linters it lists for that file type, fixing what they report before considering the task complete. Currently covers Dockerfiles (`hadolint` + `trivy config`).

## Git

- **Before any git work (branching, committing, reverting, PRs/MRs), first load my git conventions from `~/.claude/commands/git-conventions.md`** (the `git-conventions` command/skill) and follow them. Non-negotiable highlights: never work directly on shared/protected branches (create a new branch); atomic Conventional Commits (`feat:` used sparingly); and **NEVER** add `Co-Authored-By: Claude ...` or any co-authorship attribution to me — commits must appear as solely mine.
