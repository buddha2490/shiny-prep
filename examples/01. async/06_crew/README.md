# 06 -- crew: Worker Pool Task Orchestration

## What This Demonstrates

`{crew}` manages a persistent pool of R worker processes (a "controller"). Unlike `{future}`, crew gives you explicit control over the worker lifecycle and lets you submit many tasks to the pool, tracking them individually.

## Key Concepts

- `crew_controller_local(workers = n)` -- creates a local controller with `n` workers
- `controller$start()` -- launches the worker processes
- `controller$push(command, data, name)` -- submits a task (non-blocking)
- `controller$pop()` -- retrieves one completed result (non-blocking); returns `NULL` if nothing ready
- `controller$terminate()` -- shuts down all workers (call in `onStop()`)
- Results come back as a one-row tibble; the value is in `$result[[1]]`
- Requires `reactiveTimer` for polling (like `callr` in example 04)

## Comparison to future (02)

| | `future_promise()` | `crew` |
|---|---|---|
| Worker management | Implicit (via `plan()`) | Explicit controller |
| Task tracking | Per-promise | Named tasks, queue visibility |
| Multi-task queuing | Limited | Built-in (push many, pop as done) |
| Scalability backends | `multisession`, `callr` | Local, HPC (`crew.cluster`), cloud (`crew.aws.batch`) |
| Complexity | Lower | Higher |

## When to Use

Use `{crew}` when you need:

- A managed worker pool with explicit lifecycle control
- To submit many tasks and process results as they complete
- To scale to HPC or cloud backends (same API, different controller)
- Integration with `{targets}` pipelines (crew is targets' default backend)

For simple one-off async, prefer `future_promise()` (02) or `ExtendedTask` (05).

## Packages

- `shiny`
- `crew`

## Run

```r
shiny::runApp("examples/async/06_crew")
```

## What to Try

1. Click "Submit task" -- task goes to a worker
2. After 3 seconds, result appears
3. Click multiple times quickly -- tasks queue and resolve independently
