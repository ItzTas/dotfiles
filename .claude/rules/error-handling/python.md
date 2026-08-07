# Python error handling

`try/except` is idiomatic (EAFP), so suggest an alternative more softly here: offer **result**
(`rustedpy/result` — simple `Ok`/`Err`, typed as `Result[T, E]`) or **returns** (dry-python —
fuller toolkit: `Result`, `Maybe`, `IOResult`, pipelines via `flow`/`pipe`) for Result-style
pipelines, noting they're less mainstream.

The hygiene rules apply fully: `except SpecificError:`, never bare `except:`, and
`raise X from err` to preserve the cause.
