These are my rules for third-party libraries. Load this file **before adding a dependency to a
project or recommending one to me**, in any language and any package manager. The point is simple:
**never add or recommend a library without first checking that it isn't deprecated, unmaintained,
or superseded.**

## When this applies

- Adding a dependency (`npm add`, `go get`, `uv add`, `cargo add`, editing a manifest by hand, …).
- Suggesting a library in an answer, a plan, a comparison, or a code snippet I might copy.
- Scaffolding a new project whose template pulls libraries in.
- Replacing one library with another, or bumping a dependency to a new major.

Applies to plugins, presets, framework adapters, and type packages (`@types/*`) too, not just
top-level runtime deps.

## The check

Before the library's name reaches a manifest or my screen as a recommendation, verify:

1. **Deprecation flag in the registry.** The registry itself usually says so:
   - npm: `npm view <pkg> deprecated` (non-empty output = deprecated), or `npm view <pkg> time.modified dist-tags`.
   - PyPI: the project page / `Development Status :: 7 - Inactive` classifier, or a yanked latest release.
   - Go: `deprecated:` line in the module's `go.mod`, or the deprecation banner on pkg.go.dev.
   - crates.io / Packagist / RubyGems / Maven Central: the yanked/abandoned/relocated markers.
2. **Repository status.** Archived repo, "this project is no longer maintained" in the README,
   a `DEPRECATED`/`UNMAINTAINED` notice, or a redirect to a successor.
3. **Recency.** Last release date and last commit date. Old is not automatically dead: a small,
   finished, single-purpose library can be untouched for years and still be correct. But old
   **plus** open security issues, a stale dependency tree, or no answer to breaking changes in its
   ecosystem (new Node/Python/framework major) means dead.
4. **Successor.** If it's deprecated, find what replaced it and check *that* one the same way,
   since deprecation chains are common (a successor can itself be abandoned).
5. **Security.** Known advisories against the version you'd pin (`npm audit`, `osv.dev`,
   `govulncheck`, GitHub advisories).

**My knowledge cutoff is not a source.** A library that was healthy at training time can be dead
today, and one I remember as "the new hotness" can already be superseded. When the check needs
current facts, actually go get them: the registry CLI, `WebFetch`/`WebSearch` on the repo and
registry page, or the MCP tools available in the session. Don't answer from memory alone.

## Reporting

- **Say what you checked and what you found**, in one line: `zod v4, last release 2 weeks ago, repo
  active, fine`. Not a paragraph, but not silence either.
- **If it's deprecated, don't add it.** Tell me, name the successor, and let me choose, unless I
  explicitly asked for that exact library, in which case say it's deprecated, add it anyway, and
  move on.
- **If you genuinely can't verify** (no network, registry down, obscure package), say so
  explicitly ("couldn't verify `<pkg>`'s status") instead of implying it's fine. An unverified
  library is not a checked library.
- **When comparing options, apply the check to every candidate** before presenting the list, so I'm
  never shown a dead library as a live choice.

## Already in the project

- A deprecated dependency **already in the manifest** is not something to rip out on your own
  initiative. Mention it once, with the successor, and leave the decision to me.
- Exception: if I'm already editing that dependency's usage or bumping it, raise it there and
  then; that's the cheap moment to migrate.
