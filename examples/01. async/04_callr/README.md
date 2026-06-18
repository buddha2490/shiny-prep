# 04 -- callr: Direct Background R Processes

## What This Demonstrates

Using `{callr}` directly (without `{future}` or `{promises}`) to run code in a background R process. This gives you a raw process handle that you poll manually with a `reactiveTimer`.

## Key Concepts

- `callr::r_bg(func, args)` -- launches a background R process; returns a process handle immediately
- Process handle methods:
  - `$is_alive()` -- `TRUE` while running
  - `$get_result()` -- retrieves the return value (blocks if still running)
  - `$kill()` -- terminates the process
- Since `r_bg()` doesn't return a promise, you need `reactiveTimer()` to poll for completion
- The function runs in a **clean** R environment -- pass everything through `args`

## Comparison to future_promise (02)

| | `future_promise()` | `callr::r_bg()` |
|---|---|---|
| Returns | Promise (auto-resolves) | Process handle (manual polling) |
| Error handling | `.catch()` | `tryCatch($get_result())` |
| Polling needed | No | Yes (`reactiveTimer`) |
| Complexity | Lower | Higher |
| Control | Less (abstracted) | More (kill, check status) |

## When to Use

Use `callr::r_bg()` when you need:

- Fine-grained control over the process (kill, check status, read stdout/stderr)
- To avoid the `{future}` dependency
- To run CLI tools or scripts that aren't easily wrapped in a `{future}` expression

For most Shiny async, prefer `future_promise()` (02) or `ExtendedTask` (05).

## Packages

- `shiny`
- `callr`

## Run

```r
shiny::runApp("examples/async/04_callr")
```

## What to Try

1. Click "Start background job"
2. Watch the status update from "Launching..." to "Running..." to "Done."
3. The result appears once `$is_alive()` returns `FALSE`
