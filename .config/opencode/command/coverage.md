---
description: Run test coverage, report the least-covered files with their uncovered lines, and optionally add tests for key gaps
---

Measure how well the tests cover the code and show me where the holes are: the overall numbers plus
the exact uncovered lines/branches that matter most.

Optional argument (`$ARGUMENTS`): a path or module to focus the report on (default: whole project).

Separately, I may include **other requests** in the same message; those are not the argument, so do
them first, then run coverage.

Follow exactly these steps:

## 0. Handle any extra requests first
- If I asked for other changes in the same message (before or after `/coverage`), do those and get
  them working before measuring coverage.

## 1. Determine scope and toolchain
- Resolve the argument to a scope (default: whole project).
- Detect the stack and its coverage tool (respect `.prototools`/proto for versions):
  - **Rust** → `cargo llvm-cov` (fallback `cargo tarpaulin`).
  - **Node/TS** → a `coverage` script in `package.json`, or `vitest --coverage` / `jest --coverage`
    / `c8`.
- If there are no tests to measure, say so and stop.

## 2. Run coverage
- Run the tool over the scope. Prefer a summary plus a per-file/line breakdown (e.g.
  `cargo llvm-cov --summary-only` for the headline, then a full report for the detail; lcov/HTML if
  useful).

## 3. Report the gaps
- Lead with the **overall numbers**: line, branch, and function coverage %.
- List the **least-covered files** and, for each, the specific **uncovered `file:line` ranges**,
  focusing on meaningful gaps, not trivial getters/boilerplate.
- Call out **risky** uncovered code specifically: error/`Err` paths, edge cases, early returns and
  `unwrap`/`panic` branches, the stuff most likely to hide bugs.

## 4. (Optional) fill the gaps, opt-in only
- Offer, but do **not** do automatically: write tests for the most important uncovered paths. Only if
  I say yes, and then follow my `~/.claude/rules/git-conventions.md` (new branch first if I'm on a protected branch), add the
  tests, and re-run coverage to confirm they hit the target lines.

## 5. Hygiene
- Don't commit coverage output (`target/llvm-cov`, `coverage/`, `lcov.info`, HTML reports); make sure
  they're gitignored.
