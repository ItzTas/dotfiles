These are my error-handling rules for **every language whose main error mechanism is
`try`/`catch`** (or an equivalent: `try/except` in Python, `begin/rescue` in Ruby, `do/catch` in
Swift, …). Load this file whenever you are about to **write or edit a `try`/`catch` block** or to
**initialize/scaffold a new project** in one of these languages. They complement (never replace)
the conventions of the repository you're working in.

Reference model: languages where errors are already plain values, such as Go (`val, err := f()`),
Rust (`Result<T, E>`), Zig (error unions), Elixir (`{:ok, v} | {:error, r}`) and Haskell
(`Either`). They need none of this; they are the style the rules below try to approximate.

## Per-language rules

The concrete Result/Either options per language live in separate files to keep context small.
**Read only the file matching the language you're writing**, and apply it on top of the general
rules here. Don't read files for languages you're not touching.

| Language | Rule file to read |
|----------|-------------------|
| TypeScript / JavaScript | `~/.claude/rules/error-handling/typescript.md` |
| Python | `~/.claude/rules/error-handling/python.md` |
| Java | `~/.claude/rules/error-handling/java.md` |
| Kotlin | `~/.claude/rules/error-handling/kotlin.md` |
| C# | `~/.claude/rules/error-handling/csharp.md` |
| Swift | `~/.claude/rules/error-handling/swift.md` |
| Dart | `~/.claude/rules/error-handling/dart.md` |
| C++ | `~/.claude/rules/error-handling/cpp.md` |
| Ruby | `~/.claude/rules/error-handling/ruby.md` |
| PHP | `~/.claude/rules/error-handling/php.md` |
| Scala | `~/.claude/rules/error-handling/scala.md` |

If a change touches several of these languages, read each matching file. If a language isn't
listed here, only the general rules below apply.

## Choosing the strategy

- **Initializing a NEW project in a try/catch language? Always suggest an errors-as-values
  alternative first.** Offer a `Result<T, E>`/`Either` library (or the language's built-in, see
  the sections below), or at minimum a Go-style "return the error as a value" convention, with a
  one-line rationale: explicit, typed, compiler-checked error paths, with no invisible throws.
  It's a suggestion. I make the call, and if I pick try/catch, that's fine, just apply the
  hygiene rules below.
- **Existing repository that already uses try/catch (especially a large one)? Proceed normally.**
  Keep using try/catch following the codebase's established style, and do not introduce a Result
  library or mix paradigms on your own initiative. Apply the hygiene rules below to the try/catch
  you write. (If I explicitly ask about migrating, then discuss it.)
- **Repository already using a Result/Either library? Stick to it** for all new error paths; don't
  fall back to bare try/catch except at interop boundaries (wrapping third-party throwing code).

## try/catch hygiene

When try/catch is what the code uses, write it well:

- **Keep `try` blocks minimal.** Wrap only the statements that can throw, never a big
  conglomerate of unrelated logic inside one `try`. If a block covers several distinct failure
  points that need different handling, split it (multiple small try/catch blocks or extracted
  functions).
- **Use distinct error types for distinct failure situations.** Create/use specific error classes
  (`ValidationError`, `NotFoundError`, `TimeoutError`, …) and catch them specifically
  (`except TimeoutError:`, `catch (e) { if (e instanceof ValidationError) … }`) instead of one
  generic catch-all treating every failure the same way.
- **Catch only what you can handle; let the rest propagate.** A catch that can't do anything
  meaningful at that level (recover, translate, add context) shouldn't exist at that level.
- **Never write a try/catch whose catch only rethrows the error as-is.** `catch (e) { throw e; }`
  (or the language's equivalent) adds nothing: no context, no translation, no recovery. Don't
  write the try/catch at all; the exception propagates by itself.
- **Never swallow errors.** No empty catch blocks, no catch-and-continue without at least logging
  with context or rethrowing. Note the difference: **not catching is fine, swallowing is not.**
  It's perfectly reasonable to not handle an error at all and let it propagate to the caller,
  when it's an error that doesn't need to be dealt with at this level; what's forbidden is
  catching it and ignoring it, killing the error so no one above ever sees it.
- **Preserve the original error when wrapping/rethrowing.** `new Error(msg, { cause: err })` in
  JS/TS, `raise X from err` in Python, inner/chained exceptions in Java/C#. Never lose the root
  cause or its stack.
- **Handle errors at boundaries.** Centralize catch/translate logic near entry points (HTTP
  handler/middleware, CLI `main`, queue consumer, UI action). Inner layers either return
  Result-style values or let exceptions bubble; don't scatter try/catch through every layer.
- **Don't use exceptions for expected control flow.** Predictable outcomes (validation failures,
  "not found" lookups, parse attempts) should be modeled as return values; exceptions are for
  exceptional situations.
- **Use the language's cleanup constructs for cleanup**, meaning `finally`,
  `using`/try-with-resources and context managers, not catch blocks.
