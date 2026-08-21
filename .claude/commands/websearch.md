---
description: Search the web for how to accomplish the request I pass in, then apply what you find
argument-hint: [what to do...]
allowed-tools: WebSearch, WebFetch, Read, Grep, Glob, Bash, Edit, Write
effort: high
---

Search the web for **how to do** whatever I ask below and, based on what you find, carry out the task.

Instructions I passed with the command: `$ARGUMENTS`

- If I passed instructions above (e.g. `/websearch do this, that and the other thing`), the goal is to **accomplish exactly that**.
- If `$ARGUMENTS` is empty, use the rest of my message (before or after `/websearch`) as the task. If there's still nothing, **ask me** what to research before continuing.

## Steps

### 1. Understand the request
- Restate to yourself what needs to be done and identify what you **don't** know for sure or that may have changed (tool versions, APIs, syntax, current best practices).

### 2. Search the web
- Use `WebSearch` to find out **how to do** what was asked. Prefer official, recent sources (documentation, repositories, changelogs).
- Dig deeper with `WebFetch` on the most relevant pages to read the details (step-by-step, flags, examples, deprecation notices).
- Run additional searches if the first ones aren't enough. Prefer current information over your memory; your knowledge base may be out of date.

### 3. Execute
- Apply what you learned to carry out the task in the current project/context, following my `CLAUDE.md` and the conventions already present in the repository.
- If the research reveals more than one path, pick the one best suited to my context and move forward (don't just list options).
- If anything is risky, irreversible, or ambiguous, confirm with me first.

### 4. Verify
- Confirm that what you did works (run lint/tests/relevant commands when it makes sense).

### 5. Summary
- Tell me what was done, **cite the sources** (with URLs) that backed the solution, and flag any caveats or manual steps left for me.
