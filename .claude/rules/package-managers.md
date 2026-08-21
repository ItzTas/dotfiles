My package-manager rules. Follow them whenever one is in play: installing dependencies, lockfiles,
package-manager entries in `.prototools`, or editing shared docs/CI that mention a package manager.

## Package managers and personal tooling

- **My package manager is *my* personal choice, not a project convention.** I often use a package
  manager locally (Yarn, pnpm, Bun, uv, whatever) that the rest of the team doesn't use. The
  presence of a lockfile (`yarn.lock`, `pnpm-lock.yaml`, `bun.lockb`, …), its config (`.yarnrc.yml`,
  …), or an entry for it in `.prototools` in my working tree means **I** am using that tool there.
  It does **not** mean the project migrated.
- **By default, do not change a project's documented package manager, and do not rewrite shared docs
  to match my local tooling.** Shared docs (`AGENTS.md`, `README.md`, `CONTRIBUTING.md`, onboarding
  docs, the project's `CLAUDE.md`, CI files, `Dockerfile`, `deploy.sh`) describe what **the whole
  team** uses. Do not swap the documented commands for the ones I run locally, do not rewrite command
  tables, and do not "fix" the deploy/CI to use my package manager.
- **"Use `<tool>` here" is not "migrate the project to `<tool>`".** If I ask you to run or set up a
  package manager without saying anything about conventions or docs, keep the shared docs and CI
  exactly as they are; the change is local to my working tree.
- **Ignore files are the exception: adding my tool's artifacts there is fine.** Appending entries
  like `.yarn/cache`, `.yarn/install-state.gz`, `.yarn/unplugged`, `.pnpm-store/`, `bun.lockb` to
  `.gitignore`, `.dockerignore`, `.npmignore`, etc. isn't changing the convention, it just keeps my
  local artifacts out of the repo/image. Keep it purely additive: never remove or rewrite entries
  that are already there for the team's tooling.
- **If I explicitly ask for the migration or the doc change, do it in full.** "Migrate the project to
  `<tool>`", "update the README to use `<tool>`", etc. is a decision I'm making on purpose: then
  update the docs, CI, and lockfiles consistently, and mention anything you had to leave behind.
- **The more people a repo has, the stronger the default.** On a shared/team project, lean hard
  toward leaving the documented convention alone; a solo/personal repo is far less risky.
- **If a change looks genuinely needed at project level but I didn't ask for it, ask me first** and
  let me decide; never infer it from what's installed on my machine.
