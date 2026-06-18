# 03 -- future.callr: Fresh R Process Per Task

## What This Demonstrates

An alternative `{future}` backend that launches a **brand-new R process** for each task instead of reusing a persistent worker pool. The Shiny-side code (`future_promise()` + `.then()` / `.catch()`) is identical to example 02.

## Key Concepts

- `plan(callr)` -- each task gets a clean R process (vs. `plan(multisession)` which reuses workers)
- `{future}` auto-detects local variables used inside `future_promise()` and ships them to the new process
- The API is identical to `02_future_promise` -- only the backend changes

## Comparison: `multisession` vs `callr`

| | `plan(multisession)` | `plan(callr)` |
|---|---|---|
| Worker lifecycle | Persistent pool, reused | Fresh process per task |
| Startup cost | One-time (at `plan()`) | Per-task (slower) |
| State isolation | Worker state can carry over | Guaranteed clean environment |
| Use case | General-purpose async | Package isolation, DB drivers |

## When to Use

Prefer `plan(callr)` when:

- You need a guaranteed clean R environment per task
- A package misbehaves in socket workers (e.g., certain database drivers)
- You need process-level isolation for security or reproducibility

## Packages

- `shiny`
- `future`
- `future.callr`
- `promises`

## Run

```r
shiny::runApp("examples/async/03_future_callr")
```
