# Go linters

- **Always run golangci-lint after editing or creating a `.go` file**, scoped to the packages you
  touched (use `./...` if the change is broad).

  - If the repo has a golangci-lint config (`.golangci.yml`/`.yaml`/`.toml`/`.json`), it is
    authoritative — run it as-is:

    ```bash
    golangci-lint run <pkg-dir>/...
    ```

  - Otherwise run the full standard set (errcheck, govet, ineffassign, staticcheck, unused):

    ```bash
    golangci-lint run --no-config --default=standard <pkg-dir>/...
    ```

  Fix every issue it reports in the code you touched before considering the task complete
  (pre-existing findings in unrelated packages don't block the task — just mention them).
  If `golangci-lint` is not installed, fall back to running `go vet <pkg>` plus the standalone
  `errcheck <pkg>` (and `staticcheck <pkg>` if available).

- **Also run `gopls check` on every `.go` file you edited or created**, from inside the module
  (it needs the `go.mod` in scope). It catches what `golangci-lint` doesn't: real type-check
  errors and the gopls-only analyzers (`unusedparams`, `unusedvariable`, `modernize`, …).

  ```bash
  gopls check <file1>.go <file2>.go
  ```

  Recent `gopls` versions also accept package patterns (`gopls check ./...`); if that errors,
  fall back to listing the file paths explicitly.

  By default it only prints `warning` and above — to see the hint-level suggestions too:

  ```bash
  gopls check -severity=hint <file>.go
  ```

  Fix everything it reports in the code you touched. Hint-level findings are advisory: apply
  them when they're clearly right, otherwise mention them.

  - **If `gopls` is not installed, ask me whether to install it** (in choices, with the exact
    install command — normally `go install golang.org/x/tools/gopls@latest`). Never install it
    unprompted.
  - **If I say no, write that down in memory** as a `feedback` memory file (plus its one-line
    `MEMORY.md` pointer) — then skip the `gopls` step from that point on and stop asking. Check
    memory for that decision *before* asking, so I'm only asked once.
  - If I say yes, install it, then run the check.
