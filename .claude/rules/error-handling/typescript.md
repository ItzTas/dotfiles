# TypeScript / JavaScript error handling

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
