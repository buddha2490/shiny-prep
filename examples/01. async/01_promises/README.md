# 01 -- Promises: `.then()` and `.catch()`

## What This Demonstrates

The `{promises}` package brings JavaScript-style async programming to R. A promise is a placeholder for a value that will be available later. This example shows the two fundamental promise operations:

- **`.then(onFulfilled)`** -- runs when the promise resolves successfully
- **`.catch(onRejected)`** -- runs when the promise rejects (errors)

## Key Concepts

- `promise_resolve(value)` creates an already-resolved promise (success path)
- `promise_reject(reason)` creates an already-rejected promise (error path)
- Promises chain with `%>%` -- `.then()` and `.catch()` return new promises
- On their own, promises do **not** provide parallelism -- they just structure async control flow

## When to Use

Promises alone are rarely used in production Shiny apps. This example exists to build intuition for `.then()` / `.catch()` before combining promises with `{future}` in example 02.

## Packages

- `shiny`
- `promises`

## Run

```r
shiny::runApp("examples/async/01_promises")
```

## What to Try

1. Click "Resolve" -- observe `.then()` fires, `.catch()` is skipped
2. Click "Reject" -- observe `.then()` is skipped, `.catch()` fires
