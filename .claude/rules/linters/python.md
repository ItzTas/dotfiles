# Python linters

- **Always run basedpyright after editing or creating a `.py`/`.pyi` file**, scoped to the files or
  packages you touched (pass the whole package dir if the change is broad).

  - **Run it inside the project's environment**, otherwise every third-party import turns into a
    false `reportMissingImports`. Pick the first option that applies:

    ```bash
    uv run basedpyright <paths>                      # uv project (uv.lock / [tool.uv])
    poetry run basedpyright <paths>                  # poetry project
    .venv/bin/basedpyright <paths>                   # plain venv with it installed
    uvx basedpyright --pythonpath .venv/bin/python <paths>   # not installed: run it ad hoc,
                                                            # still pointed at the project venv
    ```

    If there is no venv at all, use `uvx basedpyright <paths>` and mention that unresolved imports
    in the output are environment noise, not real findings.

  - If the repo configures it (`[tool.basedpyright]` or `[tool.pyright]` in `pyproject.toml`, or a
    `pyrightconfig.json`), that config is authoritative. Run it as-is, don't override
    `typeCheckingMode` or individual rules on the command line.

  - Otherwise let basedpyright use its own default (`recommended`, stricter than pyright's
    `standard`). If that buries the real problems under `reportAny`/`reportExplicitAny` noise in a
    codebase that was never typed, rerun with `--level error` to see what actually breaks, fix
    those, and mention the remaining strict-mode findings instead of silencing them.

  Fix every error it reports in the code you touched before considering the task complete
  (pre-existing findings in files you didn't touch don't block the task, just mention them).
  Exit code `0` = clean, `1` = diagnostics, `2` = fatal/config error.

- **Suppress only with rule-specific comments.** When a finding genuinely must be ignored, use
  `# pyright: ignore[reportUnusedCallResult]` on the offending line, never a bare
  `# pyright: ignore` or `# type: ignore`, which basedpyright flags itself
  (`reportIgnoreCommentWithoutRule`). Prefer fixing the types over ignoring.

- **Never write or update a baseline to make the run pass.** `--writebaseline` records current
  errors in `.basedpyright/baseline.json` and hides them; it's a migration tool for adopting
  basedpyright on a legacy codebase, not a way to clear your own diff. Only run it if I explicitly
  ask for it.

- **Don't swap in a different type checker.** If the repo pins `pyright`, `mypy`, or `ty` in
  `.prototools`/`pyproject.toml`/pre-commit, run that one too and keep it. basedpyright is what I
  want added, not a replacement for a checker the project already depends on.
