---
description: Scaffold a new file/component/module of the given kind, mirroring the structure and conventions of an existing sibling in the project
argument-hint: <type> <name>
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
---

Create a new file / component / module that fits **this project's** conventions, by mirroring an
existing example of the same kind — not a generic template.

Arguments: `$ARGUMENTS`
- First token → the **type/kind** to create (e.g. `component`, `page`, `handler`, `service`,
  `model`, `route`, `store`, `hook`, `test`).
- Following token(s) → the **name** (e.g. `UserCard`, `CreateOrder`).
Any extra detail can also come from **the rest of my message** (e.g. "`/scaffold component
ConfirmDialog` a modal with confirm/cancel") — treat that as part of the spec.

## Steps

### 1. Understand what to create
- From `$ARGUMENTS` and my message, determine the **kind**, the **name**, and any specifics I gave.
- If the kind or where it belongs is genuinely ambiguous, **ask me** rather than guessing wildly.

### 2. Prefer the project's own generator, if any
- If the repo has a scaffolding tool configured (e.g. `plop`, `hygen`, a framework CLI like
  `nest g` / `rails g` / `php artisan make:` / `vue` generators, or a `Makefile`/`just` target),
  **use it** — that's the project's blessed path. Honor `.prototools`/`proto` for versions.

### 3. Otherwise, mirror a sibling
- Find an **existing example of the same kind** in the repo and copy its shape:
  - the **full set of files** siblings come with (e.g. component + test + story + style), not just one,
  - **location** (put the new one where its siblings live),
  - **naming/casing** (PascalCase component, kebab-case filename, etc. — match the repo),
  - imports, boilerplate, section order, and code style.
- Fill in the new name everywhere. Leave clear `TODO` markers for the parts that need real logic —
  don't invent business behavior.
- **Never overwrite an existing file.** If the target already exists, stop and tell me.

### 4. Wire it up
- Register the new thing the way siblings are registered: barrel/index exports, router entries,
  store modules, DI/providers, menu/nav entries, etc. Match exactly how an existing sibling is wired.

### 5. Follow conventions
- Respect my `CLAUDE.md` code style (guard clauses over nesting, a map over `switch`/`if-else` for
  simple key→value) and any per-project conventions already in the codebase.

### 6. Verify
- Run a quick typecheck/lint on the new files if a fast one exists, and fix anything it flags.

### 7. Summary
- List the file(s) created and where, the sibling you mirrored, the wiring you added, and any
  `TODO`s left for me to fill in.
