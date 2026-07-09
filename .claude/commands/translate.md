---
description: Implement translations in the project — add/fill localized strings across every locale using whatever localization mechanism the repo uses (i18n or otherwise)
argument-hint: [key] [text...]
allowed-tools: Read, Edit, Write, Glob, Grep, Bash
---

Implement translations in this project, using **whatever localization mechanism it already uses**
— vue-i18n / react-i18next, Keycloak `messages_*.properties`, gettext `.po`, Rails/`*.yml`,
Laravel `lang/`, `.arb`, `.xlf`, plain `en.json`/`pt.json`, etc. Don't assume a specific library.

Arguments (optional): `$ARGUMENTS` — you may pass a **key** and/or the **source text**
(e.g. `buttons.save Save`). The full intent can also come from **the rest of my message**, before
or after `/translate` (e.g. "`/translate` add a Save button label", "translate the login page",
"add Spanish support") — treat that as the work to do.

**If I pass no key/text and no request at all, translate the WHOLE project** — localize every
user-facing string in the codebase and fill in all missing translations (see step 3).

## Steps

### 1. Detect the localization setup
- Find how this project localizes: the library/config, the **locale files** and where they live,
  the **base/reference locale** (usually `en` or the project's default), and the full set of
  target languages. The repo may have several — handle all of them.
- If you genuinely can't find any localization setup and I didn't say which to use, **ask me**
  before creating one from scratch.

### 2. Learn the existing conventions
Match what's already there, don't impose your own:
- Key style — nested vs flat, `dot.notation` vs `camelCase`, grouping.
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
  Also fill in all existing missing/untranslated keys. Skip non-user-facing strings (logs, config
  keys, code identifiers, URLs, test fixtures). This can be large — work through the codebase
  systematically and report scope; if it's huge, tell me how you're batching it.
- **New string:** add the key to the base locale, then add it to **every** other locale with an
  accurate translation into that language.
- **Fill gaps:** find keys present in the base locale but missing (or left untranslated) in the
  others and translate them.
- **New language:** create the new locale file with the full key set translated.
- Always **preserve placeholders, ICU/plural structures and HTML tags exactly** — translate only
  the human-readable text around them. Keep pluralization forms correct per language.
- If I'm not confident about a specific language, don't guess — flag that value (e.g. a clear
  TODO) or ask, rather than shipping a wrong translation.

### 4. Keep locales in sync
- After the changes, **every locale must have the same set of keys**, in the same order as the
  base file. No locale left with missing or orphan keys.

### 5. Wire it up (if asked)
- If I also asked to *use* the string (not just define it), reference the key in the relevant
  component/template/code with the project's translation call (`t('…')`, `$t('…')`, `<Trans>`,
  message lookup, etc.).

### 6. Verify
- Validate the files (well-formed JSON/YAML/properties). If the repo has an i18n check/lint or
  types (e.g. vue-i18n eslint, `i18n-check`, generated message types), run it and fix what it flags.

### 7. Summary
- Show which keys were added/updated, across which locales, any new language files created, and
  anything flagged for me to review (uncertain translations, placeholders to double-check).
