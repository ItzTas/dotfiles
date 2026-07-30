# Go code style

- **Use `errgroup` for concurrency wherever it fits.** `golang.org/x/sync/errgroup` is my default
  way to run goroutines — prefer it over a hand-rolled `sync.WaitGroup` plus an error channel (or,
  worse, a `WaitGroup` that silently drops errors). It waits for every goroutine, propagates the
  first non-nil error, and — with `WithContext` — cancels the rest.

  This is the Go form of my general rule "run independent async calls concurrently": when two or
  more calls don't depend on each other's results, don't run them one after another.

  ```go
  g, ctx := errgroup.WithContext(ctx)

  var user User
  g.Go(func() error {
      var err error
      user, err = fetchUser(ctx, id)
      return err
  })

  var orders []Order
  g.Go(func() error {
      var err error
      orders, err = fetchOrders(ctx, id)
      return err
  })

  if err := g.Wait(); err != nil {
      return nil, err
  }
  ```

  - **Prefer `errgroup.WithContext(ctx)` over `new(errgroup.Group)`** whenever the goroutines take a
    `context.Context`, and pass the group's derived `ctx` (not the parent) into them — that's what
    cancels the still-running work as soon as one goroutine fails.
  - **Each goroutine writes to its own variable / its own slice index.** No shared writes, no mutex
    for what can be a per-index write: `results := make([]T, len(items))` then `results[i] = ...`
    inside `g.Go`. Only reach for a mutex when the result genuinely has to be merged.
  - **Bound fan-out with `g.SetLimit(n)`** when the number of goroutines comes from input length
    (a slice of items, rows from a query, files from a walk) — unbounded fan-out over a remote API
    or the filesystem is a bug waiting to happen. Call it before the first `g.Go`.
  - **Always `g.Wait()`** and return/handle its error. A group whose error is discarded is the same
    bug as an ignored `err`.
  - Don't reuse a group after `Wait`, and don't call `g.Go` from inside a goroutine of the same
    group.

  Where `errgroup` is *not* the answer: fire-and-forget background work that outlives the caller,
  pipelines/streaming where you need channels and per-stage cancellation, and cases where you must
  collect **every** error instead of the first one — there, use `sync.WaitGroup` with a
  `[]error`/`errors.Join`, and say why in a short comment.

  If `golang.org/x/sync` isn't in `go.mod` yet, add it with `go get golang.org/x/sync` (it's a
  semi-standard `x/` module, not a heavy third-party dependency).
