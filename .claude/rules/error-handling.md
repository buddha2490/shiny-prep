# Error Handling

How errors are *controlled* in a Shiny app: caught, coded, logged, and surfaced safely so the session never crashes. This is the control-flow companion to [error-messages](error-messages.md) (which governs the *wording* of `stop()`/`warning()`/`message()`) and [logging](logging.md) (which governs the log itself).

The worked reference is `examples/04. error-handling/` (`R/utils_error.R`). The reusable helpers there are designed to be copied verbatim.

## Principle — Fail safe, not silent

A failure in one output or observer must not take down the user's whole session, and must never vanish without trace. Every caught error is **logged** (with a code + incident id) and, when user-facing, **surfaced** as a safe message. Nothing is swallowed silently.

## Rule 1 — Wrap risky operations in `with_error_handling()`

Any operation that can fail at runtime — data loads, file I/O, DB queries, parsing, non-trivial computation, reading an async result — is wrapped so the error is logged and the app keeps running.

```r
result <- with_error_handling(
  read_dataset(path),                       # the risky expression
  code     = "ERR-DATA-001",                # catalog code (see Rule 3)
  context  = list(module = "ae_table"),     # SAFE extra log fields — no PHI
  fallback = NULL,                          # value returned on failure
  session  = session                        # for the user notification
)
```

On error this: generates an incident id, logs the real message at the catalog severity with `code` + `incident`, shows the user a safe notification referencing the incident, and returns `fallback`. Warnings are logged and muffled.

Do **not** scatter bare `tryCatch()` calls that swallow errors without logging — that is exactly the silent failure this rule exists to prevent.

## Rule 2 — Pick the right tool

`req()`, `validate()`, and `with_error_handling()` are **not** interchangeable.

| Situation | Tool | User sees | Logged? |
|-----------|------|-----------|---------|
| Input not ready yet (NULL, "", unselected) | `req(x)` | Blank output (silent) | No |
| Input present but invalid for a **known, expected** reason | `validate(need(cond, "message"))` | Tidy in-output message | No — expected |
| Something **unexpected** threw | `with_error_handling()` | Safe notification + incident id | Yes (ERROR/FATAL) |

`req()` is for "not yet" — never use it to hide a real error. `validate(need())` is for input the user can fix. `with_error_handling()` is for the genuinely unexpected.

## Rule 3 — Every caught error has a code + an incident id

Two identifiers, two purposes:

- **Catalog code** `ERR-<DOMAIN>-<NNN>` — stable, identifies the error *type*. Lives in `.error_catalog` with a safe user message and a log severity. Domains: `DATA`, `CALC`, `RENDER`, `IO`, `ASYNC`, `NET`, `AUTH`, `APP`.
- **Incident id** `<UTC timestamp>-<6 hex>` — unique per *occurrence*. Shown to the user and written to the log, so a user's report ties back to one exact log line.

Add new codes to the catalog rather than inventing ad-hoc strings at the call site. The catalog is the single registry of what can go wrong and what the user is told.

## Rule 4 — The user never sees internals

The notification shows the catalog's safe message plus the incident reference. The real error text (paths, SQL, stack detail, **patient data**) goes only to the log. In `global.R`:

```r
options(shiny.sanitize.errors = TRUE)   # strip internals from any error that
                                         # reaches the browser unhandled
```

## Rule 5 — A global safety net

Anything that escapes every wrapper and reaches Shiny's top level must still be logged, not lost. In `global.R`:

```r
options(shiny.error = function() {
  log_event("FATAL", geterrmessage(),
            code = "ERR-APP-999", incident = new_incident_id())
})
```

## Rule 6 — Async errors must be read and logged

In a worker (`future`/`mirai` inside `ExtendedTask`), an error surfaces only when you **read the result**. Watch `task$status()`; when it is `"error"`, read `task$result()` inside `with_error_handling()` — accessing it re-throws the worker's error, which is then logged and surfaced. Never leave a failed async task with its error unread.

## Rule 7 — Validate inputs at the boundary

Functions still validate their inputs up front per [error-messages](error-messages.md) (`stop(..., call. = FALSE)`). Those `stop()`s are then *caught* by the `with_error_handling()` wrapper at the call site — boundary validation and safe catching work together, they are not alternatives.
