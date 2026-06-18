# 07 -- mirai: Minimalist Async Evaluation

## What This Demonstrates

`{mirai}` ("future" in Japanese) is a lightweight, high-performance async framework built on nanonext (NNG sockets). It has lower overhead than `{future}` and a minimal API.

## Key Concepts

- `daemons(n)` -- starts `n` persistent background daemon processes (call at app startup)
- `mirai({ expr }, ...)` -- evaluates `expr` asynchronously; returns a mirai object immediately
- **Variables are NOT auto-detected** -- you must pass everything explicitly as named arguments
- `m$data` -- the result; holds `unresolved()` sentinel while still running
- `unresolved(m)` -- `TRUE` while running, `FALSE` when done
- Requires `reactiveTimer` for polling (like `callr` and `crew`)
- `daemons(0)` shuts down all daemons

## Critical Difference from future

In `{future}`, local variables used inside `future_promise()` are auto-detected and shipped to the worker. In `{mirai}`, you **must** pass them explicitly:

```r
# future -- x is auto-detected
future_promise({ x^2 })

# mirai -- x must be passed explicitly
mirai({ x^2 }, x = x)
```

Forgetting to pass a variable is a common source of "object not found" errors.

## When to Use

Use `{mirai}` when you need:

- Maximum performance with minimal overhead
- Simple API without the `{future}` abstraction layer
- Direct integration with `{crew}` (crew can use mirai as its backend)
- Scalable distributed computing (mirai supports remote daemons)

## Packages

- `shiny`
- `mirai`

## Run

```r
shiny::runApp("examples/async/07_mirai")
```

## What to Try

1. Click "Run async task" -- expression is sent to a daemon
2. After 2 seconds, result appears (5^3 = 125)
3. Note the polling mechanism -- `reactiveTimer(300)` checks `unresolved()` every 300ms
