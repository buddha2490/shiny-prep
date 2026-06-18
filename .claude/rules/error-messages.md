# Error Messages

Standard patterns for the *wording* of user-facing messages in R functions. For
how errors are *caught, coded, logged, and surfaced* in a Shiny app, see
[error-handling](error-handling.md); for the log itself, see [logging](logging.md).

## `stop()` — Fatal errors

Use for invalid inputs or states where the function cannot continue.

```r
stop("`param_name` must be a data frame.", call. = FALSE)
stop("`param_name` must contain at least one row.", call. = FALSE)
stop("Column `id` not found in input dataset.", call. = FALSE)
```

Rules:
- Always set `call. = FALSE` to suppress the call stack in the error message
- Reference the parameter name in backticks
- Be specific about what was expected vs. what was received
- One condition per `stop()` — do not combine multiple checks

## `warning()` — Non-fatal issues

Use when the function can continue but the result may be unexpected.

```r
warning("3 records have end date before start date — durations may be negative.",
        call. = FALSE)
```

Rules:
- Always set `call. = FALSE`
- Include the count or scope of the issue (not just "some records")
- Explain the consequence, not just the fact

## `message()` — Informational output

Use for progress updates and confirmations. Not for errors or warnings.

```r
message("Output written to: ", output_file)
message("Processing dataset: ", name, " (", nrow(data), " records)")
```

Rules:
- Use for file I/O confirmations and progress in long-running scripts
- Do not use `cat()` or `print()` for status messages — use `message()` so output can be suppressed with `suppressMessages()`

## Input Validation Pattern

Place all input checks at the top of the function in a `# --- Validate inputs ---` section. Check in this order:

1. Type checks (`is.data.frame()`, `is.character()`)
2. Content checks (non-empty, required columns present)
3. Value checks (valid ranges, allowed values)
