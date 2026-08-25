---
description: Run the project's benchmarks against a saved baseline and flag regressions/improvements, auto-detecting the toolchain
---

Run this project's benchmarks and tell me whether performance moved, comparing against a baseline
so I can see regressions and improvements, not just raw numbers.

Optional argument (`$ARGUMENTS`):
- no argument → run all benchmarks.
- a **filter** → run only benchmarks matching it.
- `--baseline <name>` → compare the run against a previously saved baseline by that name.
- **Flag forms**, all equivalent: `--baseline` = `-baseline` = `-b`.

Separately, I may include **other requests** in the same message; those are not arguments, so do
them first, then benchmark.

Follow exactly these steps:

## 0. Handle any extra requests first
- If I asked for other changes in the same message (before or after `/bench`), carry those out and
  get them working before benchmarking.

## 1. Detect the toolchain and bench tool
Pick the right runner from what the repo contains (respect `.prototools`/proto for tool versions):
- **Rust** (`Cargo.toml` with benches / criterion) → `cargo bench`. If `critcmp` is available, use it
  to compare criterion baselines.
- **CLI binary** to time end-to-end → `hyperfine` (multiple runs, warmup, statistical summary).
- **Node/TS** → a `bench` script in `package.json`, or `vitest bench` / a `tinybench`-based script.
- If you can't find any benchmarks, tell me and stop; don't invent them.

## 2. Establish the comparison baseline
- If `--baseline <name>` was given (or a saved baseline already exists), compare the new run against
  it. For criterion: `cargo bench -- --baseline <name>`.
- If no baseline exists, run once and **save** it (criterion: `cargo bench -- --save-baseline <name>`,
  default name `base`), then tell me how to compare against it later.
- To measure the effect of an **uncommitted change** end-to-end, you may offer to benchmark clean
  `HEAD` vs the working tree: save a baseline, `git stash`, bench, `git stash pop`, bench again, then
  `critcmp`. Offer this; don't do it automatically (stashing touches my working tree).

## 3. Run the benchmarks
- Run the detected command, applying the filter argument if given.
- Let it complete without interrupting; benchmarks need their full sample count to be meaningful.

## 4. Compare and report
- Present a table: benchmark name · baseline · current · delta (%), regressions (slower) marked
  clearly and improvements too.
- **Caveat about noise:** benchmarks are sensitive to background load, CPU scaling, and power state.
  Don't call small deltas (within a few %) real; flag them as noise. If results look noisy,
  recommend re-running on a quieter machine / consistent power with more samples.

## 5. Hygiene
- Don't commit criterion's `target/criterion` output or any generated result files.
- Report which baseline name was saved/compared so I can reproduce it.
