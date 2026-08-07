This is my rule for working across projects. Whenever I ask you to work in a **different
repository/project** than the one you're currently in, load this file and follow it.

## Cross-project work

- **When I ask you to work in a different repository/project than the one you're currently in, read that other project's `CLAUDE.md` first.** If I'm working in one repo (e.g. `repo1`) and ask you to make changes in another one (e.g. `../repo2`, or any path outside the current project), locate and read the target project's `CLAUDE.md` (and any nested `CLAUDE.md` relevant to the files you'll touch) **before** making changes there, so you follow that project's own conventions. This is in addition to — not a replacement for — my global `CLAUDE.md`.

## Keep it loaded, not just read once

- **Treat the target project's `CLAUDE.md` exactly like the current project's one.** Reading it isn't
  a one-off step you tick off — it becomes standing instructions with the same weight and the same
  staying power as the `CLAUDE.md` that's auto-injected for the repo I'm sitting in. It stays in
  force for every action you take in that project, for as long as the work there lasts.
- **Keep it fresh at the same frequency the harness keeps the local one fresh.** The local
  `CLAUDE.md` is re-injected into context regularly; do the equivalent by hand for the foreign one —
  **re-read it** whenever the context has been summarized/compacted, whenever you come back to that
  project after working somewhere else, and before starting a new batch of edits there. If you can't
  say what its rules are without guessing, re-read it before you touch anything.
- **On conflict, that project's `CLAUDE.md` wins for files inside that project** — my global
  `~/.claude/CLAUDE.md` still applies on top for everything about *me* (git conventions, entity
  names, package managers, style). Two projects in the same session means two rule sets: apply each
  one only to its own files, and don't leak a convention from one repo into the other.
- **Nested `CLAUDE.md` files count too.** If a subdirectory you're editing has its own, it's in
  force for those files and takes priority over the repo root one.
