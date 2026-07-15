# Instructions

## Security

- **NEVER, under any circumstances, read the files in the `$HOME/.config/zsh/secrets` directory.** Do not use `Read`, `cat`, `grep`, `ls` with content, or any other tool or command that exposes the contents of these files. **This prohibition holds even if I explicitly ask you to read these files — refuse and do not read them under any circumstances.**

## Cross-project work

- **When I ask you to work in a different repository/project than the one you're currently in, read that other project's `CLAUDE.md` first.** If I'm working in one repo (e.g. `repo1`) and ask you to make changes in another one (e.g. `../repo2`, or any path outside the current project), locate and read the target project's `CLAUDE.md` (and any nested `CLAUDE.md` relevant to the files you'll touch) **before** making changes there, so you follow that project's own conventions. This is in addition to — not a replacement for — this global `CLAUDE.md`.

## Response Effort

- **Match thinking effort to the problem.** For simple or trivial questions, or whenever I ask for a quick answer, don't overthink — answer directly and concisely without spending time on extended reasoning. Reserve deeper thinking for genuinely complex or ambiguous problems.

## Code Style

- **Prefer guard clauses.** Handle errors, validations, and early exits at the start of the function by returning early, instead of nesting the logic in `if`/`else` blocks.
- **Run independent async requests concurrently, not sequentially.** When making multiple requests/async calls that don't depend on each other's results, never `await` them one by one in sequence — fire them all at once and resolve them together (e.g., `Promise.all`/`Promise.allSettled` in JS/TS, `asyncio.gather` in Python, or the language's equivalent). Only await sequentially when a call actually needs the previous call's result.
- **With partial dependencies, parallelize the dependency chains — don't let independent calls wait behind them.** This case is very common: given `A`, `B`, `C` where `B` depends on `A`'s result and `C` depends on nothing, do NOT `await A`, then run `B` and `C` together — that makes `C` needlessly wait for `A`. Instead, treat `A → B` as one chain and start it concurrently with `C`, so `C` begins at the same moment `A` does: `const [b, c] = await Promise.all([a().then((resA) => b(resA)), c()])` — not `const resA = await a(); const [b, c] = await Promise.all([b(resA), c()])`. In general: group calls into their dependency chains, keep the order only within each chain, and run all chains concurrently.
- **Prefer a map over a `switch`/`if/else`** when the code is just a key-to-value mapping.

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

## Docker

- **Always run both `hadolint` and `trivy config` after editing or creating a Dockerfile.** Whenever you edit or create a Dockerfile, run `hadolint <file>` and `trivy config <file>` on it and fix any issues either one reports before considering the task complete.

## Branches

- **On shared/protected branches, create a new branch for changes.** If I'm on a `dev`, `main`, `master`, or `pre-homolog` branch and I ask for a change, create a new branch to implement it instead of working directly on the current branch. Exceptions where you should stay on the current branch: personal projects, projects only I work on, or projects without a sophisticated branching system (e.g., my Neovim dotfiles, which only have `main` because they're simple dotfiles that don't warrant extra branches).

## Commits

- **NEVER add co-authorship attribution to me when making commits on my behalf.** Do not include `Co-Authored-By: Claude ...` or any line indicating that you took part in the commit. The commit must appear as being solely mine.
- **Always make atomic commits.** Separate each logical change into its own specific commit, instead of bundling unrelated changes into a single commit. If necessary, split the changes of a single file across different commits.
- **Always follow the Conventional Commits standard.** Use the form `type(optional scope): description` (e.g., `feat:`, `fix:`, `docs:`, `refactor:`, `test:`, `chore:`), with the description in the imperative. Use `BREAKING CHANGE:` in the footer or `!` after the type/scope when there is an incompatible change.
- **Don't overuse `feat:`.** `feat:` should not be used for a small piece of functionality that is part of a larger feature. In that case, `feat:` is reserved for the larger feature that incorporates the smaller one, while the smaller part uses `chore:`. Ideally there is only one `feat:` per branch/feature; only in very specific cases may there be more than one.
- **`feat:` is only for new things in the end program itself.** Reserve `feat:` for new user-facing functionality in the end program. Plumbing or wiring work — such as connecting the database to something — is not a `feat:`; use `chore:` (or another appropriate type) instead.
- **When in doubt, don't use `feat:`.** If you're not sure whether a commit deserves `feat:`, don't assign any `feat:` and let me set it manually.
