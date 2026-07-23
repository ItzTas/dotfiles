---
description: Load my error-handling rules — when writing try/catch (any language) or starting a new project in a try/catch language; prefer Result/errors-as-values, plus try/catch hygiene
---

These are my error-handling rules for **every language whose main error mechanism is
`try`/`catch`** (or an equivalent: `try/except` in Python, `begin/rescue` in Ruby, `do/catch` in
Swift, …). Load this file whenever you are about to **write or edit a `try`/`catch` block** or to
**initialize/scaffold a new project** in one of these languages. They complement (never replace)
the conventions of the repository you're working in.

Reference model: languages where errors are already plain values — Go (`val, err := f()`), Rust
(`Result<T, E>`), Zig (error unions), Elixir (`{:ok, v} | {:error, r}`), Haskell (`Either`) — need
none of this; they are the style the rules below try to approximate.

## Choosing the strategy

- **Initializing a NEW project in a try/catch language? Always suggest an errors-as-values
  alternative first.** Offer a `Result<T, E>`/`Either` library (or the language's built-in — see
  the sections below), or at minimum a Go-style "return the error as a value" convention, with a
  one-line rationale (explicit, typed, compiler-checked error paths — no invisible throws). It's a
  suggestion: I make the call, and if I pick try/catch, that's fine — apply the hygiene rules
  below.
- **Existing repository that already uses try/catch (especially a large one)? Proceed normally.**
  Keep using try/catch following the codebase's established style — do not introduce a Result
  library or mix paradigms on your own initiative. Apply the hygiene rules below to the try/catch
  you write. (If I explicitly ask about migrating, then discuss it.)
- **Repository already using a Result/Either library? Stick to it** for all new error paths; don't
  fall back to bare try/catch except at interop boundaries (wrapping third-party throwing code).

## try/catch hygiene

When try/catch is what the code uses, write it well:

- **Keep `try` blocks minimal.** Wrap only the statement(s) that can actually throw — never a big
  conglomerate of unrelated logic inside one `try`. If a block covers several distinct failure
  points that need different handling, split it (multiple small try/catch blocks or extracted
  functions).
- **Use distinct error types for distinct failure situations.** Create/use specific error classes
  (`ValidationError`, `NotFoundError`, `TimeoutError`, …) and catch them specifically —
  `except TimeoutError:` / `catch (e) { if (e instanceof ValidationError) … }` — instead of one
  generic catch-all treating every failure the same way.
- **Catch only what you can handle; let the rest propagate.** A catch that can't do anything
  meaningful at that level (recover, translate, add context) shouldn't exist at that level.
- **Never write a try/catch whose catch only rethrows the error as-is.** `catch (e) { throw e; }`
  (or the language's equivalent) adds nothing — no context, no translation, no recovery — so don't
  write the try/catch at all; the exception propagates by itself.
- **Never swallow errors.** No empty catch blocks, no catch-and-continue without at least logging
  with context or rethrowing. Note the difference: **not catching is fine, swallowing is not** —
  it's perfectly reasonable to not handle an error at all and let it propagate to the caller, when
  it's an error that doesn't need to be dealt with at this level; what's forbidden is catching it
  and ignoring it, killing the error so no one above ever sees it.
- **Preserve the original error when wrapping/rethrowing.** `new Error(msg, { cause: err })` in
  JS/TS, `raise X from err` in Python, inner/chained exceptions in Java/C#. Never lose the root
  cause or its stack.
- **Handle errors at boundaries.** Centralize catch/translate logic near entry points (HTTP
  handler/middleware, CLI `main`, queue consumer, UI action). Inner layers either return
  Result-style values or let exceptions bubble — don't scatter try/catch through every layer.
- **Don't use exceptions for expected control flow.** Predictable outcomes (validation failures,
  "not found" lookups, parse attempts) should be modeled as return values; exceptions are for
  exceptional situations.
- **Use the language's cleanup constructs for cleanup** — `finally`, `using`/try-with-resources,
  context managers — not catch blocks.

## TypeScript / JavaScript

In TS, `catch (err)` is `unknown` — always narrow with a type guard (`err instanceof Error`)
before touching `.message`/`.stack`; never `as any`. Wrap with `new Error(msg, { cause: err })`.

Libraries to suggest (rough order of preference):

- **neverthrow** — pragmatic default. `Result`/`ResultAsync`, excellent inference,
  `.map`/`.andThen`/`.match` chaining; `fromThrowable`/`fromPromise` wrap throwing code cleanly.
- **effect** — full effect system: typed errors, retries, concurrency, DI, scheduling. Heavy —
  suggest when failure handling is a core concern (payments, orchestration, infra), not for a
  simple CRUD.
- **ts-results-es** — maintained fork of `ts-results`; Rust-flavored `Result` + `Option`
  (`Ok`/`Err`, `unwrapOr`, `Some`/`None`).
- **true-myth** — friendly, well-documented `Result` + `Maybe`.
- **oxide.ts** — closest mimic of Rust's API (`match`, `unwrap`, `Option`).
- **purify-ts** — FP toolkit (`Either`, `Maybe`, `EitherAsync`) when the codebase leans
  functional.
- **@swan-io/boxed** — `Result`/`Option`/`Future`/`AsyncData`; nice fit for front-end state.
- **fp-ts** — `Either`/`TaskEither`; powerful but steeper curve and ecosystem merging into Effect
  — prefer it only when the repo already uses it.
- **Go-style tuple, no library** — when a full Result type is too much ceremony: `await-to-js`
  (`const [err, data] = await to(promise)`) or a ~10-line in-repo helper returning
  `[error, value]`. Cheapest way out of nested try/catch.

The native `try` operator (`const result = try f()`) is only a TC39 proposal
(`arthurfiorette/proposal-try-operator`, formerly the `?=` safe-assignment operator) — track it,
don't use it in production.

## Other try/catch languages

- **Python** — `try/except` is idiomatic (EAFP), so suggest more softly here: offer **returns**
  (dry-python) or **result** (rustedpy) for Result-style pipelines, noting they're less
  mainstream; the hygiene rules above apply fully (`except SpecificError:`, never bare
  `except:`).
- **Java** — **Vavr** (`Try`, `Either`); or a small in-house Result — `sealed interface Result<T>
  permits Ok, Err` + records + pattern-matching `switch` (Java 17+) — works great without
  dependencies.
- **Kotlin** — built-in `kotlin.Result` + `runCatching`; **kotlin-result** (michaelbull) or
  **Arrow** (`Either`, `Raise`) for richer APIs.
- **C#** — **ErrorOr**, **CSharpFunctionalExtensions** (`Result`), **OneOf**, **FluentResults**;
  **LanguageExt** if the team wants full FP.
- **Swift** — built-in `Result<Success, Failure>` and typed `throws` (Swift 6); no library
  needed.
- **Dart** — **fpdart** (`Either`/`TaskEither`), **result_dart**, **multiple_result**.
- **C++** — `std::expected` (C++23); pre-23: **tl::expected**, **Boost.Outcome**,
  **absl::StatusOr**.
- **Ruby** — **dry-monads** (`Result`/`Maybe`, `Do` notation).
- **PHP** — **azjezz/psl** (`Psl\Result`), **prewk/result**.
- **Scala** — stdlib `Try`/`Either` first; **cats**/**ZIO** when an effect system is wanted.
