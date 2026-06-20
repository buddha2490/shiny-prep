---
name: codebase-facts
description: Existing examples structure, global.R patterns, renv package state, reusable helpers
type: codebase-fact
updated: 2026-06-19
---

## Examples built so far

- `examples/01. async/` — 7 async patterns (promises, future, ExtendedTask, mirai)
- `examples/02. plotly/` — 5-tab plotly reference app (scattergl, proxy, ggplotly, crosstalk)
- `examples/03. modules/` — 6-tab module reference app (NS, returned reactives, R6, nested, dynamic)
- `examples/04. error-handling/` — 4-tab logging + error handling reference (log4r, with_error_handling)
- `examples/05. shinychat/` — PLANNED (2026-06-19); see [[shinychat-ellmer-api]]

## Reusable drop-in helpers (examples/04. error-handling/R/)

Copy verbatim into new apps:
- `utils_logger.R` — `init_logger()`, `get_logger()`, `log_event()` (log4r wrapper, threshold from LOG_LEVEL env)
- `utils_error.R` — `with_error_handling()`, `.error_catalog`, `new_incident_id()`, `notify_error()`

## global.R policy (standard for all apps)

```r
options(shiny.sanitize.errors = TRUE)
options(shiny.error = function() {
  log_event("FATAL", geterrmessage(), code = "ERR-APP-999", incident = new_incident_id())
})
mirai::daemons(2); onStop(function() mirai::daemons(0))
```

## renv.lock package state (2026-06-19)

Packages PRESENT: shiny, bslib, DT, log4r, mirai, promises, later, htmltools, R6, S7,
  crew, shinycssloaders, crosstalk, data.table, ggplot2, plotly, testthat, shinytest2

Packages NOT IN renv.lock (need install + snapshot before examples/05):
- `shinychat` — NOT present
- `ellmer`    — NOT present
- `coro`      — NOT present (async generator dependency of shinychat)
- `bsicons`   — NOT present (may be needed for icons)

## App structure rule

Three-file layout always: global.R / ui.R / server.R. Never app.R.
All library() calls in global.R only. No data loading in server.R.
