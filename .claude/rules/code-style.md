These are my personal code style rules. Whenever you are about to **write or edit code** — in any
project — load this file and apply every rule below. They complement (never replace) the
conventions of the repository you're working in.

## Per-language rules

Some languages have extra rules of their own, split into separate files to keep context small.
Whenever you write or edit a file of one of the types below, **read only the matching rule file**
and apply it on top of the general rules here. Don't read rule files for types you're not touching.

| File type | Rule file to read |
|-----------|-------------------|
| Go (`.go`) | `~/.claude/rules/code-style/go.md` |

If a change touches several of these types, read each matching file. If a file type isn't listed
here, only the general rules below apply.

## Error handling

- **Whenever you're about to write or edit a `try`/`catch` block (in any language), or you're initializing a new project in a language whose main error mechanism is try/catch, load `~/.claude/rules/error-handling.md`** (rule file) and follow it — in short: for new projects, suggest a Result/errors-as-values alternative first; in existing try/catch codebases proceed normally, applying the try/catch hygiene rules (small `try` blocks, distinct error types, errors handled at boundaries).

## Code Style

- **Prefer guard clauses.** Handle errors, validations, and early exits at the start of the function by returning early, instead of nesting the logic in `if`/`else` blocks.
- **Prefer extracting functions over `else` branches when the code stays readable that way.** If the branching logic can be expressed by splitting it into well-named functions (combined with guard clauses/early returns) instead of `if`/`else` blocks, and the result is readable, prefer the functions.
- **Run independent async requests concurrently, not sequentially.** When making multiple requests/async calls that don't depend on each other's results, never `await` them one by one in sequence — fire them all at once and resolve them together (e.g., `Promise.all`/`Promise.allSettled` in JS/TS, `asyncio.gather` in Python, or the language's equivalent). Only await sequentially when a call actually needs the previous call's result.
- **With partial dependencies, parallelize the dependency chains — don't let independent calls wait behind them.** This case is very common: given `A`, `B`, `C` where `B` depends on `A`'s result and `C` depends on nothing, do NOT `await A`, then run `B` and `C` together — that makes `C` needlessly wait for `A`. Instead, treat `A → B` as one chain and start it concurrently with `C`, so `C` begins at the same moment `A` does: `const [b, c] = await Promise.all([a().then((resA) => b(resA)), c()])` — not `const resA = await a(); const [b, c] = await Promise.all([b(resA), c()])`. In general: group calls into their dependency chains, keep the order only within each chain, and run all chains concurrently.
- **Prefer a map over a `switch`/`if/else`** when the code is just a key-to-value mapping.
- **When possible, prefer a loop combined with a hashmap over sequential `if`/`else if`/`else` chains.** When a series of consecutive conditionals applies the same kind of logic to different cases, define the cases in a hashmap and loop over its entries, instead of writing the conditionals one by one. This is not a blanket rule — it's meant for more specific situations where the chain is genuinely repetitive/data-driven; use judgment.
- **Declare those maps where they're used — scope follows usage, not habit.** A map/hashmap that only one function needs, and that nothing else will ever reuse, belongs **inside that function**, right where it's used. Don't hoist it to module/class scope just because "constants go at the top": that pollutes the outer scope, separates the data from the logic that reads it, and suggests a reuse that doesn't exist. Move it out only when there's a real reason: another function needs it too, it's part of the module's public API, it's genuinely large, or the function is hot enough that rebuilding the map on every call actually matters (measured, not guessed). Same idea in any language — a local `const` object in TS/JS, a `dict` inside the function in Python, a package-level `var` in Go only when it's shared or costly to rebuild.
