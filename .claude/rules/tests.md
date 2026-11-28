# Tests

These are my rules for writing tests, in any language and any framework. Load this file whenever
you're about to **write, edit, or delete tests**, and apply it on top of whatever the repository
already does.

## A test describes the present, never the past

- **Write every test as if the code under test had just been written for the first time.** The test
  says what the function/component/endpoint *does now*. It never mentions or checks what the code
  used to do.
- **Never write a test whose assertion is the absence of an old behavior.** If a button's padding
  goes from `16px` to `8px`, the test is `padding === 8px`, not `padding !== 16px`. If an argument
  is dropped from a function, the test calls the function with its current signature and checks the
  result; it does not assert the old parameter is gone. Same for a removed field, a deleted route,
  a dropped config key.
- **These "ghost tests" are worse than no test**, because they pass even when the real behavior is
  broken. `padding !== 16px` is green at `0px`, at `40px`, and on a button that never renders.
- **Don't test the diff.** After a change, the question is never "did my edit apply?" but "does
  this thing behave correctly as it stands?". The diff is already visible in git; the test suite is
  for behavior.

## When changing an existing feature

- **Prefer throwing the old tests away and writing new ones from the current behavior**, whenever
  that's possible. Don't patch the old test file until it agrees with the new code, and don't
  *append* a couple of extra cases pinned to what changed. Read the feature as it is now, and
  cover it.
- **Cover the whole current behavior, not just the part that moved.** A rewritten test file is a
  full description of the feature, not the description of an edit.
- **Deleted a feature? Delete its tests.** No leftover test asserting it's gone.

## Implicit coverage: drop the redundant test

When you write several tests for the same code, some of them end up exercising a feature that
another test already exercises on the way to its own assertion. Call **test A** the one that is
covered implicitly, and **test B** the bigger one that covers it while doing something else.

- **B clearly covers A? Delete A.** No need to keep both, and don't keep A "just in case".
- **A is a very simple check?** Then removing it costs nothing. If A does one trivial assertion and
  B goes through the same thing implicitly, drop A precisely because it's that simple.
- **A and B test quite different things but still overlap? Use your judgment.** Keep A when its
  failure tells you something B's failure wouldn't, and drop it when the overlap is the whole
  point of A.

This is about redundancy inside the current suite, so it doesn't loosen anything above: the tests
that stay still describe the present behavior, and coverage of the feature stays complete.

## Security and regression tests

- **The same rule applies to them.** Write security tests against the current state of the feature:
  this input is rejected, this route requires this permission, this payload is escaped. Not "the
  old hole is closed".
- **The default is no dedicated regression test.** Fixing a bug or closing a hole is not, by
  itself, a reason to add a test pinned to that bug. Treat the fix like any other change to the
  feature (see "When changing an existing feature"): cover its current behavior as a whole. If the
  input that triggered the bug is a meaningful case of that behavior, it goes in as an ordinary
  case, named after what the code does ("rejects a path containing `../`"), not after the bug
  ("regression for #123"), and not as an extra test appended on top of the suite.
- **The exception is rare and needs evidence you can point to, not a feeling.** A targeted
  regression test is allowed only when at least one of these is true:
  - git history shows this same behavior has already broken and been fixed more than once (earlier
    fix commits, `git log -S` / `git log -L` on the code, a reopened issue);
  - I explicitly asked for a regression test;
  - the repository's own conventions require one for every fix.
- **"Subtle", "tricky", "security-related" or "could come back" don't qualify on their own.** Every
  bug you just fixed looks like that from up close, which is exactly why this exception used to
  fire every single time. Without one of the three conditions above, you're not in the exception.
- **When you do use the exception, tell me which condition applies**, with the evidence (the
  commits, the issue, my message). If you can't name it, don't write the test.
- **Even then, write it as a positive statement about current behavior.** "Rejects a path
  containing `../`" is a real test. "Doesn't have CVE-XXXX anymore" is a ghost test. Link the
  history in a comment if the context helps; keep it out of the assertion.
