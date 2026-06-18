# 05 -- ExtendedTask: Shiny 1.8+ Native Async

## What This Demonstrates

`ExtendedTask` is Shiny's built-in, first-class solution for non-blocking tasks (Shiny >= 1.8.0). It wraps a promise-returning function in a structured object that Shiny understands natively -- no manual polling, no `reactiveTimer`.

**This is the recommended pattern for new Shiny apps.**

## Key Concepts

- `ExtendedTask$new(func)` -- `func` must return a promise (typically via `future_promise()`)
- `task$invoke(...)` -- starts the task with named arguments; returns immediately
- `task$status()` -- reactive: `"idle"` | `"running"` | `"success"` | `"error"`
- `task$result()` -- reactive: the resolved value (or error object)
- Calling `invoke()` while the task is already running is a no-op (built-in guard)
- No `reactiveTimer` or manual polling needed -- Shiny handles it

## Comparison to future_promise (02)

| | `future_promise()` + `.then()` | `ExtendedTask` |
|---|---|---|
| Status tracking | Manual (`reactiveVal`) | Built-in (`task$status()`) |
| Result access | In `.then()` callback | Reactive (`task$result()`) |
| Re-invocation guard | Manual | Built-in (no-op if running) |
| Polling | None needed | None needed |
| Shiny version | Any | >= 1.8.0 |

## When to Use

Use `ExtendedTask` for any user-triggered async operation in Shiny >= 1.8.0:

- Button-triggered computations
- Long-running queries initiated by the user
- File processing after upload

It pairs well with `bslib::input_task_button()` for automatic button state management.

## Packages

- `shiny` (>= 1.8.0)
- `future`
- `promises`

## Run

```r
shiny::runApp("examples/async/05_extended_task")
```

## What to Try

1. Click "Run task" -- status changes from "idle" to "running"
2. After 3 seconds, status becomes "success" and result appears
3. Click again -- new invocation starts cleanly
