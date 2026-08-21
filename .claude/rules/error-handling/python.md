# Python error handling

`try/except` is idiomatic (EAFP), so suggest an alternative more softly here: offer **result**
(`rustedpy/result`, a simple `Ok`/`Err` typed as `Result[T, E]`) or **returns** (dry-python, a
fuller toolkit with `Result`, `Maybe`, `IOResult` and pipelines via `flow`/`pipe`) for
Result-style pipelines, noting they're less mainstream.

The hygiene rules apply fully: `except SpecificError:`, never bare `except:`, and
`raise X from err` to preserve the cause.
