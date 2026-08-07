# Go code style

Rules specific to Go, on top of my general code style rules. Each section below is independent —
read the ones that apply to what you're writing.

## Concurrency — `errgroup`

- **Prefer `errgroup` where it fits — it isn't the only allowed form of concurrency.** For a
  bounded set of goroutines that can fail and must all finish before the function continues,
  `golang.org/x/sync/errgroup` beats a hand-rolled `sync.WaitGroup` plus an error channel. Outside
  that shape use whatever primitive fits — channels, `select`, `WaitGroup`, `sync.Once`, `atomic`,
  `singleflight`, `semaphore` — and never rewrite working concurrent code just to introduce
  `errgroup`.

  This is the Go form of my general rule "run independent async calls concurrently": several
  independent loads before the real work, a fan-out over a slice, a couple of checks at once.
  The example is an illustration, not a template.

  ```go
  var (
      structure CatalogStructure
      grants    Grants
      perms     []string
  )
  g, gctx := errgroup.WithContext(ctx)
  g.Go(func() (err error) { structure, err = s.structure.Structure(gctx); return err })
  g.Go(func() (err error) { grants, err = s.repo.VisibilityGrants(gctx); return err })
  if userID != "" { // conditional launches are fine; the group only waits for what started
      g.Go(func() (err error) { perms, err = s.repo.UserPermissions(gctx, userID); return err })
  }
  if err := g.Wait(); err != nil {
      return nil, err
  }
  ```

  The one-liner `g.Go(func() (err error) { x, err = call(gctx); return err })` is a nice default
  for simple assignments; use a normal multi-line body when the goroutine does more. Groups nest,
  can be built in a loop, passed down, or mixed with a channel — whatever the situation calls for.

- **With partial dependencies, parallelize the chains — don't serialize the whole function.**
  Given `A`, `B` (depends on `A`) and `C` (independent): keep `A → B` in a single `g.Go` and put
  `C` in another, so `C` starts at the same instant as `A`. Not `a := fetchA(ctx)` first and only
  then a group for `B` and `C` — that makes `C` wait on `A` for nothing. Group calls into
  dependency chains, keep the order only *within* each chain, run every chain concurrently.

- **Worth knowing (not a checklist):**

  - `errgroup.WithContext(ctx)` is what cancels the siblings on the first failure — pass its
    `gctx` to the goroutines, not the parent. Not required: plain `var g errgroup.Group` is good
    when there's no context, or when you want every goroutine to finish regardless.
  - Have each goroutine write to its own variable or its own slice index; a mutex is only for
    results that genuinely must be merged.
  - `g.SetLimit(n)` (before the first `g.Go`) when the goroutine count comes from input length —
    unbounded fan-out over an API or the filesystem is a bug waiting to happen.
  - Always handle `g.Wait()`'s error. Don't reuse a group after `Wait`.
  - **You can collect every error, not just the first.** `g.Wait()` returns the first one, but
    what each goroutine records on the side is up to you — channel, mutex-guarded slice, pre-sized
    `[]error` by index, whatever reads best, then `errors.Join(...)`. Skip `WithContext` there, or
    the first failure cancels the rest and you collect `context.Canceled` instead of real errors.
  - **Goroutines that can't fail, or "first result wins":** either tool is right, take whichever
    reads better. `errgroup` has no *success* trigger, so first-wins needs your own
    `context.WithCancel` — with or without a group on top.

- If `golang.org/x/sync` isn't in `go.mod` yet, add it with `go get golang.org/x/sync` (a
  semi-standard `x/` module, not a heavy third-party dependency).
