---
description: Load my PnP LSP guide — fix editor/LSP module resolution in Plug'n'Play projects (editor SDKs, vtsls, workspace TS); never disable PnP
---

This is my guide for making editors/LSPs work in **Plug'n'Play (PnP)** projects. Load it whenever
you're dealing with editor or language-server issues in a project that uses PnP. Yarn is the main
implementation (see the Yarn section below), but the principles apply to any PnP setup.

## PnP in general

PnP replaces `node_modules` resolution with a generated resolver manifest: a `.pnp.cjs` at the
project root (often with `.pnp.data.json` / `.pnp.loader.mjs`) answers every `require`/`import`
directly, and dependencies stay in compressed archives instead of an extracted `node_modules` tree.

- **How to detect it:** a `.pnp.cjs` at the root and **no `node_modules`**.
- **Why tools break:** any tool that resolves modules on its own — language servers, linters,
  formatters, test runners, bundlers, plain `node script.js` — bypasses the PnP runtime and fails
  with `Cannot find module 'x'` / TS `2307` even though the package is installed.
- **General fixes:**
  - Run Node scripts through the package manager's runner (e.g. `yarn node script.js`) or preload
    the runtime: `node --require ./.pnp.cjs script.js`.
  - Point each tool at the **PnP-patched copy** of its dependency (TypeScript, ESLint, Prettier, …)
    instead of a bundled/global one — that's exactly what editor SDKs do.
  - To open files inside zipped dependencies, the editor needs a zip filesystem layer (e.g. the
    **ZipFS** extension in VSCode).
- **Golden rule:** the fix is always to make the tool PnP-aware. **Never** "fix" it by disabling
  PnP, extracting a `node_modules`, or switching the install linker.

## Yarn (`nodeLinker: pnp`)

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
