---
description: Load my entity-name rules; never infer a company/entity name (LICENSE holder, "data provided by", etc.); ask me, then record it
---

These are my rules for **entity/company names**: the name of the organization that **owns** a
project, and the names of any **other entities** that get credited in it (data providers,
sponsors, partners, upstream sources, etc.).

Getting one of these wrong, above all in a **LICENSE**, can put me in **serious legal trouble**.
So the rule is absolute:

## 1. Never infer an entity name

- **Never guess, derive, or infer** the name of the entity/company responsible for a project, in
  **any** place: `LICENSE` / `COPYING` copyright lines, `README` credits, `package.json`
  `author`/`publisher`, `Cargo.toml`, `pyproject.toml`, `go.mod` module paths, headers, footers,
  docs, code comments, UI strings, `NOTICE`, attribution blocks, anywhere.
- **The repo is not a source of truth for this.** The directory name, the git remote / org slug,
  the GitHub owner, my username, an existing string elsewhere in the code, a similar sibling
  project, or anything I said in another conversation are all **hints, not answers**. A plausible
  match is still a guess.
- The same holds for **other entities** being credited, e.g. "data provided by `<entity>`",
  "powered by `<entity>`", "in partnership with `<entity>`", dataset/API attributions.
- When you need a name and don't have it from the sources in rule 3, **stop and ask me** (rule 2).
  Never write a placeholder (`<Your Company>`, `TODO`, `Acme Inc.`) and move on, and never leave
  the field out to dodge the question.

## 2. Ask me, as choices

- Ask with the **question/choices UI** (`AskUserQuestion`), not free-form prose.
- Offer the **plausible candidates you found as options** (org slug, remote owner, names already
  present in the repo, my name as an individual), clearly labelled as candidates, with where each
  came from in the description. I pick, or I type my own. **Presenting a candidate as an option is
  fine; writing one without my pick is not.**
- Ask **once per entity per role**: one question for the project owner, and one for each other
  entity being credited. If a single change needs several, batch them into one round of questions.
- Ask for the name **exactly as it must be written** (legal form, casing, punctuation: `Ltda.`,
  `Inc.`, `LLC`, accents). If the spelling I give looks ambiguous for a legal context, confirm it
  back in one line before writing it.

## 3. Record it: the exception to rule 1

Once I've decided, the name is **recorded**, and from then on **reading it from that record is not
inferring**. It's the only way you're allowed to have an entity name without asking again.

- **File: `.claude/entities/entities.md`** in the **project's** `.claude/` directory (the one at the
  current repo/project root, not `~/.claude`). Create the folder/file if needed.
- Format: one entry per entity, with the role it plays and where the name is used:

  ```markdown
  # Entities

  ## Owner
  - **Name:** Northwind Software Ltd.
  - **Used in:** LICENSE, README credits, package.json author
  - **Decided:** 2026-07-16

  ## Data provider: Open Data Foundation
  - **Name:** Open Data Foundation (ODF)
  - **Used in:** README attribution line, app footer
  - **Decided:** 2026-07-16
  ```

- **Check this file first**, before every other step. If the entity for that role is already
  recorded, **use it as written**: don't ask again, don't re-derive it, don't "improve" the
  spelling. Append the new usage site to its **Used in** line.
- If the file records a name that **contradicts** what's in the code, don't silently pick a side.
  Tell me and ask which one wins.
- **A record only ever counts for its own project.** Another project's `entities.md` is not a
  source: if this project has no entry, ask me (rule 2), even if a sibling repo has one.

## 4. When this applies

Trigger on **any** work that puts an entity name into a file: creating or editing a `LICENSE`,
scaffolding a new project/package manifest, adding credits/attribution/"data provided by", writing
copyright headers, README/docs boilerplate, UI footers, and equally when a **template** you're
filling has a slot for one.

## On activation

Dispatch on `$ARGUMENTS`:

- **`show`** (or empty): print the entities currently recorded for this project, with their roles
  and usage sites. Don't ask or write anything.
- **`forget <entity>`**: remove that entry from the project file, after confirming which entry
  you're about to delete.
- **Anything else**: treat it as the context that needs a name, and follow the rules above:
  check the record, then ask if it's missing, then write and record.
