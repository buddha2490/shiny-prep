---
name: shiny-error-handling
description: Auto-invoked when adding logging or error handling to a Shiny app — log4r setup, the with_error_handling() wrapper, error code catalog + incident ids, req()/validate()/tryCatch() selection, sanitized production errors, the global shiny.error safety net, async (ExtendedTask/mirai) error capture, and the pharma no-PHI-in-logs rule. Use whenever code can fail at runtime (data loads, I/O, DB, parsing, computation, async) or when wiring logging into global.R/server.R/modules.
---

# Shiny Error Handling & Logging Skill

Make every Shiny app **fail safe, not silent**: a runtime failure is logged with a code + incident id, surfaced to the user as a safe message, and never crashes the session. Governed by `.claude/rules/error-handling.md` and `.claude/rules/logging.md`.

The worked reference is `examples/04. error-handling/` — a 4-tab app. Its `R/utils_logger.R` and `R/utils_error.R` are designed to be **copied verbatim** into a real app, then the error catalog extended. Open them when you need a full example.

## The two helper files

Always start by ensuring these exist in the app's `R/` and are sourced in `global.R`:

- **`utils_logger.R`** — `init_logger()`, `get_logger()`, `log_event(level, msg, ...)`. One app-wide log4r logger in a private env, reached via a getter. Modules never make their own.
- **`utils_error.R`** — `with_error_handling()`, the `.error_catalog`, `new_incident_id()`, `notify_error()`.

## Wiring it into `global.R`

```r
library(log4r)
source("R/utils_logger.R")
source("R/utils_error.R")

init_logger(app_name = "my-app", log_dir = "logs",
            threshold = Sys.getenv("LOG_LEVEL", "INFO"))

options(shiny.sanitize.errors = TRUE)        # never leak internals to the browser
options(shiny.error = function() {            # global safety net
  log_event("FATAL", geterrmessage(),
            code = "ERR-APP-999", incident = new_incident_id())
})

log_event("INFO", "Application started", code = "APP-START")
```

And the session lifecycle in `server.R`:

```r
log_event("INFO", "Session started", code = "SESSION-START",
          session_token = session$token)
session$onSessionEnded(function() {
  log_event("INFO", "Session ended", code = "SESSION-END",
            session_token = session$token)
})
```

## The core pattern: `with_error_handling()`

Wrap anything that can fail at runtime — data loads, file I/O, DB queries, parsing, non-trivial computation.

```r
data <- with_error_handling(
  read_dataset(path),
  code     = "ERR-DATA-001",                 # from the catalog
  context  = list(module = "ae_table"),      # SAFE log fields only — no PHI
  fallback = NULL,                           # returned on failure
  session  = session
)
```

On error: a fresh incident id, a log line at the catalog severity with `code` + `incident`, a safe user notification, and `fallback` returned. The session keeps running. Warnings are logged and muffled.

Never write a bare `tryCatch()` that swallows an error without logging it — that is the silent failure this skill exists to prevent.

## Choosing the right tool (do not mix these up)

| Situation | Tool | User sees | Logged? |
|-----------|------|-----------|---------|
| Input not ready (NULL/""/unselected) | `req(x)` | Blank, silent | No |
| Input present but invalid, user-fixable | `validate(need(cond, "msg"))` | In-output message | No |
| Something unexpected threw | `with_error_handling()` | Notification + incident id | Yes |

```r
output$summary <- renderText({
  req(input$arm)                                       # not ready -> silent
  validate(need(input$n > 0, "n must be positive."))   # invalid -> tidy message
  with_error_handling(                                 # unexpected -> caught
    compute_summary(input$arm, input$n),
    code = "ERR-CALC-001", fallback = "(unavailable)", session = session
  )
})
```

## Error codes

`ERR-<DOMAIN>-<NNN>` (domains: `DATA CALC RENDER IO ASYNC NET AUTH APP`). Each lives in `.error_catalog` with a **safe user message** and a **severity**. Add a code to the catalog rather than inventing a string at the call site:

```r
.error_catalog[["ERR-IO-002"]] <- list(
  user = "The report could not be generated.", severity = "ERROR"
)
```

Pair the stable **catalog code** with a unique **incident id** (`new_incident_id()`, shown to the user) so a bug report maps to one exact log line.

## Async (ExtendedTask + mirai)

A worker's error surfaces only when you **read the result**. Watch the status; read inside the wrapper:

```r
observeEvent(task$status(), {
  if (task$status() == "error") {
    with_error_handling(task$result(),        # re-throws the worker error
      code = "ERR-ASYNC-001", session = session)
  }
})
```

## Pharma rule — no PHI/PII in logs

Never log `USUBJID`, subject names, DOBs, or free-text tied to a subject. Log safe identifiers — error codes, incident ids, row counts, module names, `PARAMCD`, arm names, `session$token`. Log the *count* and the *code*, not the *data*. Gitignore `logs/`.

## Checklist when adding error handling

- [ ] `utils_logger.R` + `utils_error.R` present and sourced in `global.R`
- [ ] `init_logger()`, `shiny.sanitize.errors`, `shiny.error` set in `global.R`
- [ ] Session lifecycle logged in `server.R`
- [ ] Every risky op wrapped in `with_error_handling()` with a catalog code
- [ ] New error types added to `.error_catalog` with safe user messages
- [ ] `req()` / `validate(need())` used for "not ready" / "invalid", not for real errors
- [ ] Async results read inside a wrapper
- [ ] No PHI/PII in any log line; `logs/` gitignored
- [ ] Unit tests for the helpers (success path, fallback on error, error is logged)
