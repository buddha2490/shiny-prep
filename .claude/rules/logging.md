# Logging

Every Shiny app in this project uses **log4r** for structured logging. Logging is not optional — it is how we trace what an app did in production, and (with [error-handling](error-handling.md)) how every caught error becomes traceable.

The worked reference is `examples/04. error-handling/` (`R/utils_logger.R`). The reusable helpers there are designed to be copied verbatim into a real app.

## Rule 1 — One logger, reached via a getter

Create exactly one logger at startup in `global.R`, stored in a private environment, and reach it everywhere through a getter. Modules never create their own logger and never receive one as an argument.

```r
# global.R
init_logger(app_name = "my-app", log_dir = "logs",
            threshold = Sys.getenv("LOG_LEVEL", "INFO"))
```

```r
# anywhere (module, helper, server)
log_event("INFO", "Data loaded", code = "DATA-LOAD", rows = nrow(x))
```

`get_logger()` must return a working logger even if `init_logger()` was never called (e.g. inside a unit test) — logging must never itself throw.

## Rule 2 — Threshold from the environment

The logger threshold comes from the `LOG_LEVEL` env var, defaulting to `INFO`. The same code runs verbose in dev (`LOG_LEVEL=DEBUG`) and quiet in production (`LOG_LEVEL=WARN`) with no edits. Never hard-code the threshold.

## Rule 3 — Use the right level

| Level | Use for |
|-------|---------|
| `DEBUG` | Developer detail — reactive fired, branch taken. Off in production. |
| `INFO`  | Normal lifecycle — app started, session started/ended, data loaded, export written. |
| `WARN`  | Recoverable oddity — empty result set, fell back to a default, deprecated path. |
| `ERROR` | A caught failure that prevented an operation (always paired with a catalog code). |
| `FATAL` | A failure that escaped all handlers and reached Shiny's top level. |

## Rule 4 — Log structured, greppable lines

Pass extra context as named fields, rendered as `key=value` (logfmt). Always include the `code` for anything error-related, and an `incident` id for caught errors (see [error-handling](error-handling.md)).

```r
log_event("ERROR", conditionMessage(e),
          code = "ERR-DATA-001", incident = id, module = "ae_table")
```

```
ERROR [2026-06-18 14:12:33] File not found code=ERR-DATA-001 incident=20260618T141233-a3f9c1 module=ae_table
```

Console appender for humans tailing the app; file appender for persistence and aggregation. Use a JSON layout (`log4r::json_log_layout()`) only when a log aggregator requires it.

## Rule 5 — Log the lifecycle

At minimum every app logs: application start (in `global.R`), session start and end (in `server.R`, keyed by `session$token`). This bounds production activity to a window of log lines.

## Rule 6 — NEVER log PHI/PII (pharma)

This is the one rule that overrides convenience. Log files are stored in plain text and shipped to aggregators — they are **not** a safe place for patient data.

**Never log:** `USUBJID` or other subject identifiers, subject names, dates of birth, site-identifying free text, raw rows of CDISC data, verbatim adverse-event terms tied to a subject.

**Safe to log:** error codes, incident ids, row/record counts, module names, parameter codes (`PARAMCD`), treatment arm names, `session$token`, timings.

When in doubt, log the *count* and the *code*, not the *data*. If a message would help debugging only by including patient data, log a reference (incident id) instead and keep the detail out of the file.

## Rule 7 — `logs/` is gitignored

Log files are runtime artifacts. Add `logs/` and `*.log` to the app's `.gitignore`. Never commit log output.
