---
name: translate
description: Add/fill localized strings across every locale using the repo's localization mechanism
argument-hint: [key] [text...]
allowed-tools: Read, Edit, Write, Glob, Grep, Bash, Bash(~/.claude/skills/translate/scripts/*)
---

Implement translations in this project, using **whatever localization mechanism it already uses**:
vue-i18n / react-i18next, Keycloak `messages_*.properties`, gettext `.po`, Rails/`*.yml`,
Laravel `lang/`, `.arb`, `.xlf`, plain `en.json`/`pt.json`, etc. Don't assume a specific library.

Arguments (optional): `$ARGUMENTS`, where you may pass a **key** and/or the **source text**
(e.g. `buttons.save Save`). The full intent can also come from **the rest of my message**, before
or after `/translate` (e.g. "`/translate` add a Save button label", "translate the login page",
"add Spanish support"), and that's the work to do.

**If I pass no key/text and no request at all, translate the WHOLE project**: localize every
user-facing string in the codebase and fill in all missing translations (see step 3).

## The locale diff script

```
~/.claude/skills/translate/scripts/i18n-diff.py --dir <locales-dir> [--base <locale>]
~/.claude/skills/translate/scripts/i18n-diff.py <base-file> [other-locale-files…]
```

Reads JSON (nested keys → dotted), ARB, `.properties`, `.po`/`.pot`, and YAML when `yq` is
installed; `--dir` pairs files by name (`en.json`/`pt-BR.json`, `messages_en.properties`,
`app_en.arb`, `en/translation.json`, `pt_BR/LC_MESSAGES/x.po` + `x.pot`, `devise.en.yml`) into
groups and picks the base (`--base`, else the `.pot`, else `en*`). Output, one JSON object:

```
{"in_sync", "groups": [{"pattern", "format", "base": {"locale", "file", "keys"}, "base_guessed",
  "locales": [{"locale", "file", "keys", "missing", "orphan", "untranslated", "same_as_base",
               "placeholder_mismatches": [{"key", "missing", "extra"}], "order_differs",
               "fuzzy" (po), "counts", "in_sync"}]}],
 "unsupported": [{"file", "reason"}], "errors": [{"file", "error"}], "skipped": [files]}
```

Exit `0` all in sync, `1` something out of sync or unparseable (`errors`), `2` usage error or
nothing comparable. `same_as_base` may be legit (brand names, "OK"); review it, don't blindly
translate it. Formats it can't read (`unsupported`, `.xlf`, Laravel PHP arrays, TS modules) you
compare by hand.

## Steps

### 1. Detect the localization setup
- Find how this project localizes: the library/config, the **locale files** and where they live,
  the **base/reference locale** (usually `en` or the project's default), and the full set of
  target languages. The repo may have several, so handle all of them. Run the script with `--dir`
  on each locale directory to get the groups, base and current gaps; check that its `base` is the
  project's real reference locale (`base_guessed: true` means it guessed; rerun with `--base`).
- If you genuinely can't find any localization setup and I didn't say which to use, **ask me**
  before creating one from scratch.

### 2. Learn the existing conventions
Match what's already there, don't impose your own:
- Key style: nested vs flat, `dot.notation` vs `camelCase`, grouping.
- File format and **key ordering** (alphabetical? by section? match the base file).
- Interpolation/placeholder syntax (`{name}`, `{{name}}`, `%s`, `%1$s`, ICU `{count, plural, …}`)
  and any HTML/markup in values.

### 3. Apply the translation work
Depending on what I asked:
- **Whole project (no argument and no request):** go through the **entire codebase** and localize
  every user-facing string. Find hardcoded human-readable text (labels, messages, titles,
  placeholders, alt/aria text, errors, etc.) that isn't localized yet, extract each into the
  localization system under a sensible key following the project's conventions, replace the
  hardcoded usage with the translation call, and add the translated value to **every** locale.
  Also fill in every `missing`/`untranslated` key the script reports. Skip non-user-facing
  strings (logs, config keys, code identifiers, URLs, test fixtures). This can be large, so work
  through the codebase systematically and report scope; if it's huge, tell me how you're batching
  it.
- **New string:** add the key to the base locale, then add it to **every** other locale with an
  accurate translation into that language.
- **Fill gaps:** translate the script's `missing` and `untranslated` keys (and `fuzzy` ones for
  gettext).
- **New language:** create the new locale file with the full key set translated.
- Always **preserve placeholders, ICU/plural structures and HTML tags exactly**, translating only
  the human-readable text around them. Keep pluralization forms correct per language.
- If I'm not confident about a specific language, don't guess. Flag that value (e.g. a clear
  TODO) or ask, rather than shipping a wrong translation.

### 4. Keep locales in sync
- After the changes, **rerun the script**: every locale must have the same set of keys, in the same
  order as the base file (`missing`, `orphan` and `order_differs` clean), with no
  `placeholder_mismatches`. Exit `0` is the target.

### 5. Wire it up (if asked)
- If I also asked to *use* the string (not just define it), reference the key in the relevant
  component/template/code with the project's translation call (`t('…')`, `$t('…')`, `<Trans>`,
  message lookup, etc.).

### 6. Verify
- The script's `errors` list covers malformed JSON/ARB; validate other files yourself. If the repo
  has an i18n check/lint or types (e.g. vue-i18n eslint, `i18n-check`, generated message types),
  run it and fix what it flags.

### 7. Summary
- Show which keys were added/updated, across which locales, any new language files created, and
  anything flagged for me to review (uncertain translations, placeholders to double-check,
  `same_as_base` values left as-is).
