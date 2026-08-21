# Java error handling

- **Vavr** (`Try`, `Either`) when a library is fine.
- Or a small in-house Result: `sealed interface Result<T> permits Ok, Err` + records +
  pattern-matching `switch` (Java 17+). Works great without dependencies.

Preserve the cause with chained exceptions (`new X(msg, err)`).
