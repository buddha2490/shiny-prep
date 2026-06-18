# 02 -- future + promises: Non-Blocking Async Computation

## What This Demonstrates

The core async pattern for Shiny: `future_promise()` runs an R expression in a background worker process and returns a promise immediately. The Shiny session stays responsive while the work runs.

Without this, a long-running computation (e.g., `Sys.sleep(5)`) inside `observeEvent()` would block the **entire** Shiny process -- no user could interact with the app.

## Key Concepts

- `plan(multisession)` -- sets up a pool of background R worker processes (call once at app startup, not inside `server()`)
- `future_promise({ expr })` -- sends `expr` to a worker; returns a promise immediately
- `.then(function(value) ...)` -- runs when the background work completes
- `.catch(function(err) ...)` -- runs if the background work errors
- Workers in `multisession` are **persistent** -- they stay alive and are reused across tasks

## When to Use

This is the **default production pattern** for async in Shiny. Use it for:

- Slow database queries
- File I/O (reading/writing large files)
- API calls to external services
- Any computation > ~1 second that would block the UI

## Packages

- `shiny`
- `future`
- `promises`

## Run

```r
shiny::runApp("examples/async/02_future_promise")
```

## What to Try

1. Click "Start Task" (5-second background job)
2. Immediately click "Still Alive?" multiple times -- the ping counter increments, proving the main thread is not blocked
3. After 5 seconds, the task result appears
