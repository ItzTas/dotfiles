# Kotlin linters

- **Always run both `ktlint` and `detekt` after editing or creating a Kotlin file** (`.kt`, `.kts`),
  scoped to the files/modules you touched. Run ktlint first (formatting), then detekt (static
  analysis), and fix everything they report in the code you touched before considering the task
  complete.

- **Prefer the project's Gradle tasks when they exist** — they carry the repo's own config,
  rulesets and baselines, so they are authoritative:

  ```bash
  ./gradlew ktlintCheck detekt          # jlleitschuh ktlint plugin
  ./gradlew lintKotlin detekt           # kotlinter plugin
  ```

  Check `build.gradle.kts`/`build.gradle` (or the version catalog) for which ktlint plugin is
  applied. Scope to a module when the change is local: `./gradlew :module:ktlintCheck :module:detekt`.

- **Otherwise run the standalone CLIs:**

  ```bash
  ktlint <file-or-glob>
  detekt --input <file-or-dir> --build-upon-default-config
  ```

  If the repo has a detekt config (`detekt.yml`, `config/detekt/detekt.yml`), pass it with
  `--config <path>` instead of relying on defaults. Honor `--baseline <detekt-baseline.xml>` when
  one exists so pre-existing findings don't drown the new ones.

- **ktlint style comes from `.editorconfig`** — if the repo has one, it wins. Never hand-edit
  formatting that ktlint disagrees with; run the formatter instead:

  ```bash
  ktlint -F <file-or-glob>      # or ./gradlew ktlintFormat / formatKotlin
  ```

  Re-run the check afterwards, since `-F` can't fix every rule.

- **Never silence a finding to make the build pass.** Fix the code. Only if a detekt rule is
  genuinely wrong for the case, suppress it narrowly with `@Suppress("RuleName")` on the smallest
  scope possible and say why in the response; don't add entries to the baseline file and don't
  loosen the shared config.

- Pre-existing findings in files you didn't touch don't block the task — just mention them. If
  neither tool is installed and there's no Gradle wrapper, mention that the lint was skipped rather
  than silently declaring the file clean.
