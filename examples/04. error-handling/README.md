# Error Handling & Logging Reference App

The worked reference for **logging (log4r)** and **safe error handling** in a pharma/clinical Shiny app. Every risky operation is wrapped so a failure is logged with a code + incident id, shown to the user as a safe message, and *never crashes the session*.

## Quick Start

```r
shiny::runApp("examples/04. error-handling")
```

Requires: `shiny`, `bslib`, `DT`, `log4r`, `mirai`.

Control verbosity with the `LOG_LEVEL` env var (`DEBUG`, `INFO`, `WARN`, `ERROR`, `FATAL`). The app logs to the console and to `logs/error-handling-demo.log` (gitignored).

## The two building blocks

| File | Provides | Drop into any app |
|------|----------|-------------------|
| `R/utils_logger.R` | `init_logger()`, `get_logger()`, `log_event()` — one app-wide log4r logger reached via a getter | ✅ copy as-is |
| `R/utils_error.R` | `with_error_handling()`, error code catalog, `new_incident_id()`, `notify_error()` | ✅ copy + extend the catalog |

These two files are designed to be copied verbatim into a real app. Extend `.error_catalog` in `utils_error.R` with your own `ERR-<DOMAIN>-<NNN>` codes.

## Error identification: code + incident id

Every caught error carries two identifiers:

- **Catalog code** (`ERR-DATA-001`) — stable, identifies the error *type*; maps to a safe user message and a log severity.
- **Incident id** (`20260618T141233-a3f9c1`) — unique per *occurrence*; shown to the user and written to the log so a bug report ties back to one exact log line.

```
ERROR [2026-06-18 14:12:33] File not found: /data/adsl.sas7bdat code=ERR-DATA-001 incident=20260618T141233-a3f9c1 module=safe_load scenario=missing
```

The user sees: *"The data could not be loaded… Reference: 20260618T141233-a3f9c1 (ERR-DATA-001)"* — never the internal path.

---

## Tab 1: Logging (`R/mod_log_demo.R`)

Writes one line through `log_event()` at each level and tails the log file. Shows how the logger threshold discards lower-priority lines.

| Pattern | What it does |
|---------|--------------|
| `get_logger()` | Retrieves the single app logger created in `global.R`. Modules never make their own. |
| `log_event(level, msg, ...)` | Structured logging — extra named args become `key=value` fields. |
| Threshold | `LOG_LEVEL=WARN` discards DEBUG/INFO without code changes. |

## Tab 2: Safe data load (`R/mod_safe_load.R`)

The canonical `with_error_handling()` pattern. Three scenarios (valid / corrupt / missing) — the app survives all of them.

| Pattern | What it does |
|---------|--------------|
| `with_error_handling(expr, code=, fallback=)` | Catches the error, logs it with a code + incident id, notifies the user, returns `fallback`. |
| `fallback = NULL` | Keep the previously loaded value rather than blanking the table. |
| `context = list(...)` | Safe extra fields (module, scenario, row count) added to the log line. No PHI. |

## Tab 3: Validation (`R/mod_validation.R`)

The three different tools for three different situations — they are **not** interchangeable.

| Tool | When | User sees | Logged? |
|------|------|-----------|---------|
| `req(x)` | Input not ready yet | Blank output (silent) | No |
| `validate(need(...))` | Input present but invalid for a known reason | Tidy in-output message | No (expected) |
| `with_error_handling()` | Something unexpected threw | Safe notification + incident id | Yes (ERROR/FATAL) |

## Tab 4: Async (`R/mod_async_task.R`)

Errors in a background worker surface when you *read the result*, not where the work runs. Pattern: watch `task$status()`; on `"error"`, read `task$result()` inside `with_error_handling()` (which re-throws the worker error) to log + notify.

| Pattern | What it does |
|---------|--------------|
| `ExtendedTask$new(...)` + `mirai()` | Run work off the main thread; deps passed explicitly into the worker. |
| `observeEvent(task$status())` | React to `"error"` and surface it. |
| `with_error_handling(task$result())` | Re-throws + logs + notifies; app stays alive. |

---

## Global policy (`global.R`)

```r
options(shiny.sanitize.errors = TRUE)      # never leak internals to the browser
options(shiny.error = function() {          # global safety net for anything
  log_event("FATAL", geterrmessage(),       # that escapes a wrapper
            code = "ERR-APP-999", incident = new_incident_id())
})
```

## Pharma rule: no PHI/PII in logs

Never log subject identifiers, names, dates of birth, or free-text terms tied to a subject. Log *safe* identifiers — error codes, incident ids, row counts, module names, `session$token`. See `.claude/rules/logging.md`.
