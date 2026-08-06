# Tailwind-style utility class linting

Applies to any file carrying Tailwind-shaped class attributes — `.svelte`, `.html`, `.jsx`/`.tsx`,
`.vue`, `.astro` — whether the engine is Tailwind itself or UnoCSS (`presetWind*`, `presetUno`).

## Where the diagnostics come from

I run `tailwindcss-language-server` in Neovim (Mason install, wired by `nvim-lspconfig`), so
class-attribute problems reach you as LSP diagnostics I paste in, shaped like:

```
Planilha.svelte
  ├╴W 'relative' applies the same CSS properties as 'sticky'.  (cssConflict) [1409, 22]
  └╴W The class `break-words` can be written as `wrap-break-word`  (suggestCanonicalClasses) [1746, 38]
```

The position is `[line, column]`, 1-based, from my buffer — re-read the line before editing, other
sessions may have shifted it.

**The language server validates against the Tailwind version it bundles, not the one the project
compiles with.** It also attaches to UnoCSS projects, which ship no Tailwind at all — lspconfig
matches on filetype and the class syntax is Tailwind-shaped. Treat every version-sensitive
suggestion as unverified until checked against the project's real engine.

## `cssConflict` — apply as-is

Two utilities in the same class attribute set the same CSS property. Always real: the last one
wins and the other is dead weight. Delete the losing utility (the one appearing *earlier* in the
attribute), keep the one that takes effect.

## `suggestCanonicalClasses` — never apply blindly

My `lsp.lua` sets this rule to `"ignore"` on roots that hold a `uno.config.*` **and** no Tailwind
(no `tailwind.config.*`, no `tailwindcss` dependency), so on my UnoCSS-only projects it should
never reach me. If one shows up there anyway, the LSP config regressed — say so instead of acting
on the suggestion.

On a root where both engines are installed the rule stays on, because nothing tells the server
which engine compiles the file at hand. There the suggestion may well be right: verify against
both engines before applying, and if they disagree, ask me which one owns that file.


A rename suggestion, and the one that bites. Applying a newer-Tailwind name to an older engine
silently produces **no CSS at all** — the class lands in the markup and generates nothing, with no
build error. Verify first, then apply or reject.

### Verify on UnoCSS

Ask the project's own generator, with the project's own config (presets, theme extensions and
custom rules included):

```bash
node -e "
import('@unocss/config').then(async ({ loadConfig }) => {
  const { config } = await loadConfig(process.cwd())
  const { createGenerator } = await import('unocss')
  const uno = await createGenerator(config)
  const r = await uno.generate('CLASS_A CLASS_B CLASS_C', { preflights: false })
  console.log('matched:', [...r.matched])
})"
```

Anything missing from `matched:` generates nothing — do not put it in the markup.

Known trap: `presetWind3` is Tailwind **v3**-compatible. Tailwind v4.1 names like `wrap-break-word`,
`wrap-anywhere`, `wrap-normal` don't exist there — `break-words` remains correct.

### Verify on Tailwind

Check the installed major (`npm ls tailwindcss`) and only accept suggestions that exist in it. When
unsure, compile the class and confirm a rule comes out:

```bash
echo '<div class="CLASS_A CLASS_B"></div>' > /tmp/probe.html
npx tailwindcss -i <project-css-entry> -o - --content /tmp/probe.html | grep -c 'CLASS_A'
```

### When a suggestion is rejected

Keep the original class and say the suggestion was rejected as incompatible with the project's
engine version. Do not leave the file in a half-applied state, and check whether the same bad
rename already leaked into other files (`grep -rn '<bad-class>' src/`) — these apply silently, so
an earlier accepted suggestion can already be live and unnoticed.
