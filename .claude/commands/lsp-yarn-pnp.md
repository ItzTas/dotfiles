---
description: Load my Yarn PnP LSP setup guide — fix editor/language-server module resolution in Yarn Plug'n'Play projects (Yarn SDKs, vtsls settings, SFC tsserver plugins); never disable PnP
---

This is my guide for making editors/LSPs work in **Yarn Plug'n'Play** projects. Load it whenever
you're dealing with editor or language-server issues in a project that uses PnP.

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
