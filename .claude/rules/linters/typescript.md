# TypeScript / JavaScript linters (tsserver via vtsls)

Covers `.ts`, `.tsx`, `.mts`, `.cts`, `.js`, `.jsx`, `.mjs`, `.cjs`, and the `<script lang="ts">`
blocks of `.svelte`/`.vue`.

## After editing or creating one of these files

- **Run the repo's own type gate**, scoped to what you touched, through the repo's package
  manager. Look it up in `package.json` scripts before inventing a command — usual names are
  `check`, `typecheck`, `type-check` (`yarn check`, `pnpm typecheck`, …). With no script, run
  `npx tsc --noEmit -p tsconfig.json`; a SvelteKit/Vue repo needs `svelte-check` / `vue-tsc`
  instead, since `tsc` does not read SFC templates.
- **Run ESLint** if the repo configures it (`eslint.config.*`, `.eslintrc.*`), scoped to the files:
  `yarn eslint <paths>`. Fix everything reported in code you touched; pre-existing findings
  elsewhere don't block the task, just mention them.
- Both gates report **errors only**. Everything below is what only the language server
  (`vtsls`, or `svelte-language-server` for `.svelte`) reports, under the source tag `ts (…)`.

## Severity decides the response

| Severity | Codes | What it means |
|---|---|---|
| Error / Warning | `1xxx` syntax, `2xxx` semantic, `5xxx` config/compiler options, `7xxx` implicit-any family | Real. `tsc`/`svelte-check` report them too, so they break the gate. Fix them. |
| Hint (faded/underlined) | `80xxx` suggestions, plus unnecessary/deprecated-tagged codes (`6133` unused local, `6385` deprecated symbol, …) | **Language-server only.** `tsc` never emits `80xxx`, so CI stays green either way. Advisory — see below. |

Two hints that are not merely advisory:

- **`6385` (deprecated symbol)** overlaps `@typescript-eslint/no-deprecated`, which several of my
  repos set to `error` — there the same code *does* fail the lint gate. Check the ESLint config
  before calling it cosmetic.
- **`6133` (declared but never read)** is a hint only while `noUnusedLocals` is off; turning that
  flag on promotes it to a build error.

## The `80xxx` suggestion codes

| Code | Message |
|---|---|
| 80001 | File is a CommonJS module; it may be converted to an ES module. |
| 80002 | This constructor function may be converted to a class declaration. |
| 80003 | Import may be converted to a default import. |
| 80004 | JSDoc types may be moved to TypeScript types. |
| 80005 | `require` call may be converted to an import. |
| 80006 | This may be converted to an async function. |
| 80007 | `await` has no effect on the type of this expression. |
| 80008 | Numeric literals with absolute values equal to 2^53 or greater are too large to be represented accurately as integers. |

## Reproducing hints headlessly

No CLI prints `80xxx` — `tsc` computes suggestion diagnostics only inside the language service.
To confirm a hint is still live, and to prove it's gone after the fix, run from the
**project root**:

```bash
node ~/.claude/scripts/ts-suggestions.mjs src/lib/utils/promessa.ts [more files…]
```

It loads the project's own `typescript` and `tsconfig.json` and prints
`file:line:column (code) message`; exit `0` = no suggestions, `1` = suggestions found, `2` =
couldn't run (no `node_modules/typescript` — wrong cwd, or deps not installed). For `.svelte`
files it only sees the compiled TS the plugin generates, so trust the language server's own
diagnostic there instead.

**Never go hunting for `80xxx` proactively.** Act on the ones I report; they're refactor offers,
not defects, and sweeping a codebase for them is churn.

## Applying a suggestion

- **A suggestion is an offer, not a bug report.** Check what the rewrite does to semantics before
  applying; keep the smallest edit that clears the hint.
- **`80006`** — converting a promise chain to `async`/`await` moves cleanup and error timing.
  Dropping a `.finally()` for a post-`await` statement leaks the cleanup on the rejection path.
  Marking the function `async` and awaiting the existing chain is usually enough; a full rewrite
  is optional. Watch the repo's error-handling convention — some of mine ban `try`/`catch`
  outright (`neverthrow`), so `try`/`finally` is not always available as the cleanup form.
- **`80007`** — often a genuine bug, not noise: a missing `async`, a function that forgot to
  return its promise, a `Result` awaited by mistake. Investigate before deleting the `await`.
- **`80001` / `80003` / `80005`** — these change module semantics and interact with
  `esModuleInterop`, `verbatimModuleSyntax` and the CJS/ESM boundary. Never apply them in a file
  the build treats as CommonJS (config files, `.cjs`, a package without `"type": "module"`)
  without checking how it's loaded.
- **Re-run the type gate and ESLint after applying one.** A hint fix routinely trips a real rule —
  `require-await`, `@typescript-eslint/return-await`, `no-floating-promises`,
  `@typescript-eslint/no-misused-promises`.

## Never silence tsserver

- No `@ts-ignore`, `@ts-expect-error`, or `@ts-nocheck` to make a diagnostic go away. They don't
  even apply to `80xxx` hints, and for real errors the fix is the types. If a suppression is
  genuinely warranted, stop and ask me first.
- Don't loosen `tsconfig.json` (`strict`, `noImplicitAny`, `skipLibCheck`, `exclude`) to clear an
  error in code you wrote.

## When the diagnostic is the LSP's fault, not the code's

Treat these as setup regressions and **say so instead of editing the code**:

- `Cannot find module 'x'` / TS `2307` on packages that are installed.
- `';' expected` or template markup parsed as raw TS inside a `.svelte`/`.vue` file.
- A diagnostic that contradicts a passing `tsc --noEmit` / `yarn check` — trust the CLI and report
  the divergence.

Usual cause: the server is running its bundled TypeScript instead of the workspace SDK, or the
framework tsserver plugin isn't registered. Fixes live in `~/.claude/rules/lsp-pnp.md`. Never
work around one by adding casts, `any`, or hand-written module declarations.
