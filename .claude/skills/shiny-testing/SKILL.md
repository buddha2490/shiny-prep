---
name: shiny-testing
description: Auto-invoked when writing or modifying tests for Shiny applications. Governs the three-layer testing hierarchy (unit → testServer → integration), testthat patterns, testServer() for reactive logic, shinytest2::AppDriver for E2E tests, snapshot testing, and dependency injection for reproducible tests.
---

# Shiny Testing Skill

## Testing Hierarchy — Decision Table

| Layer | Tool | Tests | When to Use |
|-------|------|-------|-------------|
| **Unit** | `testthat` | Pure functions, R6 methods, data transforms | Always — fast, no Shiny needed |
| **Module server** | `shiny::testServer()` | Reactive logic, observer side-effects, module outputs | When testing server behavior without a browser |
| **Integration (E2E)** | `shinytest2::AppDriver` | Full UI interactions, cross-module flows, visual snapshots | Before release; slower, requires headless browser |

**Start at the bottom of the stack.** Write unit tests first. Add `testServer()` tests for reactive logic. Reserve `AppDriver` for flows that cannot be verified any other way.

---

## Layer 1 — Unit Tests (`testthat`)

Test pure R functions and R6 class methods completely independently of Shiny.

### File layout

```
tests/
  testthat/
    test-utils-filter.R       # tests for R/utils_filter.R
    test-mod-summary-logic.R  # tests for business logic extracted from a module
    test-r6-patient-model.R   # tests for R6 class
```

### Canonical test file

```r
# tests/testthat/test-utils-filter.R

library(testthat)
library(dplyr)

source("R/utils_filter.R")

# --- Test data ----------------------------------------------------------------

make_records <- function() {
  tibble(
    id       = c("001", "001", "002"),
    term     = c("Alpha", "Beta", "Alpha"),
    severity = c("LOW", "MEDIUM", "HIGH"),
    flagged  = c(FALSE, FALSE, TRUE)
  )
}

# --- Normal cases -------------------------------------------------------------

test_that("filter_records returns all rows when no filters applied", {
  result <- filter_records(make_records(), sev = NULL, flagged_only = FALSE)
  expect_equal(nrow(result), 3L)
})

test_that("filter_records filters by severity correctly", {
  result <- filter_records(make_records(), sev = "LOW", flagged_only = FALSE)
  expect_equal(nrow(result), 1L)
  expect_equal(result$term, "Alpha")
})

test_that("filter_records returns only flagged rows when flagged_only = TRUE", {
  result <- filter_records(make_records(), sev = NULL, flagged_only = TRUE)
  expect_equal(nrow(result), 1L)
  expect_equal(result$id, "002")
})

# --- Edge cases ---------------------------------------------------------------

test_that("filter_records returns zero-row tibble when no rows match", {
  result <- filter_records(make_records(), sev = "CRITICAL", flagged_only = FALSE)
  expect_equal(nrow(result), 0L)
  expect_s3_class(result, "data.frame")
})

test_that("filter_records errors on non-data-frame input", {
  expect_error(filter_records("not a df"), "`data` must be a data frame")
})

test_that("filter_records errors when severity column is missing", {
  bad <- tibble(id = "001", term = "Alpha")
  expect_error(filter_records(bad, sev = "LOW"), "Column `severity` not found")
})
```

### Rules

- One `test_that()` block per behavior — do not bundle multiple assertions into one block
- Test data defined as a **factory function** (e.g., `make_records()`), not a bare object — makes it easy to modify per-test
- Always test: normal input, zero-row result, wrong type, missing required column
- Match error messages to the exact strings produced by `stop()` — partial matching is fine with `expect_error(., regexp = "...")`

---

## Layer 2 — Module Server Tests (`testServer()`)

`testServer()` runs a module's server function in a simulated reactive context without a browser. It can set inputs, flush the reactive graph, and inspect outputs and return values.

### Canonical `testServer()` pattern

```r
# tests/testthat/test-mod-filter.R

library(testthat)
library(shiny)
library(dplyr)

source("R/mod_filter.R")
source("R/utils_filter.R")

# --- Shared test data ---------------------------------------------------------

sample_data <- reactive({
  tibble(
    id       = c("001", "002"),
    term     = c("Alpha", "Beta"),
    severity = c("LOW", "HIGH"),
    flagged  = c(FALSE, TRUE)
  )
})

# --- Tests --------------------------------------------------------------------

test_that("mod_filter_server returns all rows on initial load", {
  testServer(mod_filter_server, args = list(data = sample_data), {
    session$flushReact()
    result <- session$getReturned()
    expect_equal(nrow(result()), 2L)
  })
})

test_that("mod_filter_server filters when severity input changes", {
  testServer(mod_filter_server, args = list(data = sample_data), {
    session$setInputs(severity = "HIGH")
    session$flushReact()
    result <- session$getReturned()
    expect_equal(nrow(result()), 1L)
    expect_equal(result()$term, "Beta")
  })
})

test_that("mod_filter_server filters flagged rows only", {
  testServer(mod_filter_server, args = list(data = sample_data), {
    session$setInputs(flagged_only = TRUE)
    session$flushReact()
    result <- session$getReturned()
    expect_equal(nrow(result()), 1L)
    expect_true(result()$flagged)
  })
})

test_that("mod_filter_server output$count reflects filtered row count", {
  testServer(mod_filter_server, args = list(data = sample_data), {
    session$setInputs(severity = "LOW")
    session$flushReact()
    expect_equal(output$count, "1 record")
  })
})
```

### `testServer()` API reference

| Call | Purpose |
|------|---------|
| `session$setInputs(id = value)` | Set one or more input values |
| `session$flushReact()` | Force the reactive graph to flush (run pending observers) |
| `session$getReturned()` | Get the value returned by `moduleServer()` |
| `output$id` | Read a rendered output value (text, table data, etc.) |
| `session$userData` | Access session-scoped storage set by the module |

### Rules

- Always call `session$flushReact()` after `session$setInputs()` — inputs do not auto-propagate in tests
- Reactive arguments to the module must be wrapped in `reactive({...})` at the test level
- `session$getReturned()` returns the reactive — call it with `()` to get the value
- `testServer()` cannot test UI rendering (HTML output, JS interactions) — use `AppDriver` for those
- Do not test `input$*` directly — test the observable consequences (outputs, return values)

---

## Layer 3 — Integration Tests (`shinytest2::AppDriver`)

`AppDriver` launches the full app in a headless Chromium browser. Use it to verify end-to-end user flows and to lock in visual snapshots of outputs.

### Canonical `AppDriver` test

```r
# tests/testthat/test-app-ae-flow.R

library(testthat)
library(shinytest2)

test_that("AE filter flow: selecting severity updates table and count", {
  app <- AppDriver$new(
    app_dir = system.file("app", package = "myapp"),  # or "." for raw Shiny
    name    = "ae-filter-flow",
    seed    = 12345
  )
  on.exit(app$stop(), add = TRUE)

  # Verify initial state
  app$expect_values(output = "ae_count")   # snapshot on first run, compare on later runs

  # Interact
  app$set_inputs(`ae_filter-severity` = "SEVERE")
  app$wait_for_idle()

  # Assert specific value
  count_text <- app$get_value(output = "ae_count")
  expect_match(count_text, "^\\d+ event")

  # Snapshot the table output
  app$expect_values(output = "ae_table")
})

test_that("Download button produces a non-empty CSV", {
  app <- AppDriver$new(".", name = "download-test", seed = 12345)
  on.exit(app$stop(), add = TRUE)

  app$set_inputs(`ae_filter-severity` = "MILD")
  app$wait_for_idle()

  # Trigger download and capture bytes
  download <- app$get_download("ae_download")
  expect_gt(file.size(download), 0L)
})
```

### All-tabs smoke test — assert *nothing threw* (the no-dark-corners gate)

For any app with more than one tab/screen, ship a smoke test that visits **every**
tab, exercises each tab's primary interaction, and asserts the app threw nothing.
The trap: a Shiny **render** error (`renderDT`/`render_gt`/`renderUI` throwing) is
**not** written to the browser console and leaves a non-empty `shiny-output-error`
`<div>` behind — so "console is clean" and "output is non-empty" are *false-pass
traps*. The signal that **does** fire is the app's stderr, captured in
`app$get_logs()` under `location == "shiny"`.

```r
# helper-shiny-smoke.R  (testthat auto-sources helper-*.R; runs in the test process)
`%||%` <- function(a, b) if (is.null(a)) b else a

expect_no_shiny_errors <- function(app) {
  logs <- as.data.frame(app$get_logs())
  have <- nrow(logs) > 0 && all(c("location", "message") %in% names(logs))

  # 1. Shiny stderr — render/runtime errors land here even when they never reach
  #    the browser console. The universal catch: no output IDs needed.
  shiny_err <- if (have) {
    logs$message[logs$location == "shiny" & grepl("Error( in |:)", logs$message)]
  } else character(0)
  testthat::expect_identical(shiny_err, character(0),
    info = paste0("App logged Shiny errors:\n", paste(shiny_err, collapse = "\n")))

  # 2. No output rendered into an error state (DOM).
  dom_err <- tryCatch(app$get_html(".shiny-output-error"), error = function(e) NULL)
  testthat::expect_null(dom_err,
    info = paste0("An output is in an error state:\n", dom_err %||% ""))

  # 3. Browser console errors (client-side JS).
  if (have && "level" %in% names(logs)) {
    console_err <- logs$message[!is.na(logs$level) & logs$level == "error" &
                                  logs$location == "chromote"]
    testthat::expect_identical(console_err, character(0),
      info = paste0("Browser console errors:\n", paste(console_err, collapse = "\n")))
  }
  invisible(app)
}
```

```r
# test-all-tabs-smoke.R
test_that("every tab opens and renders without throwing", {
  app <- AppDriver$new(".", name = "all-tabs-smoke", seed = 42L)
  on.exit(app$stop(), add = TRUE)

  for (tab in c("Overview", "DT", "reactable", "gt")) {     # the navbar input id
    app$set_inputs(nav = tab); app$wait_for_idle()
  }
  # Exercise each tab's primary interaction — a render error only fires when the
  # reactive actually runs (e.g. a proxy update, a radio switch, a save click).
  app$set_inputs(nav = "DT"); app$wait_for_idle()
  app$click("dt-worsen");     app$wait_for_idle()

  expect_no_shiny_errors(app)
})
```

**Validate the gate itself:** when you write or change a smoke test, break the
feature once and confirm the gate goes **red**, then restore. A green count from
assertions that cannot fail is worthless (this is exactly how a `formatStyle()`
crash shipped behind a "65 tests pass" smoke test that only checked the console).

### Input ID syntax for namespaced modules

When the app uses modules, the input ID in `AppDriver` is `"module_id-input_id"`:

```r
# Module called with mod_ae_filter_server("ae_filter", ...)
# Input inside the module: input$severity
# AppDriver reference:
app$set_inputs(`ae_filter-severity` = "SEVERE")
```

### Screenshot / snapshot testing

```r
test_that("KM plot renders without error", {
  app <- AppDriver$new(".", name = "km-snapshot", seed = 12345)
  on.exit(app$stop(), add = TRUE)

  app$set_inputs(treatment_arm = "Active")
  app$wait_for_idle()

  # Capture and store a screenshot snapshot
  app$expect_screenshot()

  # Or snapshot just one output's value
  app$expect_values(output = "km_plot")
})
```

On the **first run**, `expect_screenshot()` and `expect_values()` write reference snapshots to `tests/testthat/_snaps/`. On subsequent runs, they compare against those references. Update snapshots intentionally:

```r
# Regenerate all snapshots (run in console, not in CI)
shinytest2::snapshot_review("tests/testthat")
```

### Rules

- Always set `seed` in `AppDriver$new()` — ensures reproducible random state
- Always call `app$wait_for_idle()` after interactions that trigger server computation
- Use `on.exit(app$stop(), add = TRUE)` immediately after `AppDriver$new()` — ensures cleanup even if the test fails
- Scope integration tests narrowly — one user flow per `test_that()` block
- Do not duplicate `testServer()` assertions in `AppDriver` tests — integration tests verify the UI glue, not the logic

---

## R6 Class Testing

R6 classes that encapsulate business logic are tested entirely with `testthat` — no Shiny required.

```r
# tests/testthat/test-r6-data-store.R

library(testthat)
library(R6)

source("R/DataStore.R")

test_that("DataStore initializes with correct row count", {
  df <- tibble(id = c("S01", "S02", "S03"), group = c("A", "B", "A"))
  store <- DataStore$new(df)
  expect_equal(store$n_rows(), 3L)
})

test_that("DataStore$filter_group returns only matching rows", {
  df <- tibble(id = c("S01", "S02"), group = c("A", "B"))
  store <- DataStore$new(df)
  filtered <- store$filter_group("A")
  expect_equal(nrow(filtered$data), 1L)
  expect_equal(filtered$data$group, "A")
})

test_that("DataStore$filter_group returns clone, not mutation", {
  df <- tibble(id = c("S01", "S02"), group = c("A", "B"))
  store <- DataStore$new(df)
  filtered <- store$filter_group("A")
  expect_equal(store$n_rows(), 2L)   # original unchanged
})

test_that("DataStore errors on missing id column", {
  bad <- tibble(group = "A")
  expect_error(DataStore$new(bad), "Column `id` not found")
})
```

**Rules:**
- Test `$clone()` behavior explicitly — verify that mutations on a clone do not affect the original
- Test public methods only — do not reach into `private$` fields in tests
- R6 tests run orders of magnitude faster than `testServer()` — extract business logic into R6 wherever possible

---

## Dependency Injection for Reproducible Tests

Avoid hard-coded data sources in modules. Accept data as a reactive argument so tests can supply controlled data.

### Pattern — injectable data source

```r
# Module accepts data as a reactive argument (injectable)
mod_summary_server <- function(id, data) {
  moduleServer(id, function(input, output, session) {
    output$table <- renderTable({ data() })
  })
}

# Production wiring — passes a real reactive
server <- function(input, output, session) {
  real_data <- reactive({ load_from_db() })
  mod_summary_server("summary", data = real_data)
}

# Test wiring — passes controlled test data
test_that("mod_summary renders table rows", {
  test_data <- reactive({
    tibble(id = "S01", value = 42)
  })
  testServer(mod_summary_server, args = list(data = test_data), {
    session$flushReact()
    expect_equal(nrow(output$table), 1L)
  })
})
```

### Mock for external calls

```r
# Wrap external calls in an injectable function argument
mod_loader_server <- function(id, fetch_fn = load_from_db) {
  moduleServer(id, function(input, output, session) {
    data <- reactive({ fetch_fn() })
    output$table <- renderTable({ data() })
  })
}

# Test with a mock function — no DB needed
test_that("mod_loader renders mock data", {
  mock_fetch <- function() tibble(ID = 1:3, VALUE = c(10, 20, 30))
  testServer(mod_loader_server, args = list(fetch_fn = mock_fetch), {
    session$flushReact()
    expect_equal(nrow(output$table), 3L)
  })
})
```

---

## Running Tests

```r
# Run all tests
testthat::test_dir("tests/testthat")

# Run a single file
testthat::test_file("tests/testthat/test-mod-ae-filter.R")

# Run tests matching a pattern
testthat::test_dir("tests/testthat", filter = "ae")

# For package-based apps (golem / leprechaun)
devtools::test()

# Regenerate snapshots after intentional UI changes
shinytest2::snapshot_review("tests/testthat")
```

---

## Common Errors and Fixes

### `testServer()`: "Can't call `session$flushReact()` outside of a reactive context"

**Cause:** `flushReact()` called before the server function body initializes.

**Fix:** Call `session$flushReact()` inside the `testServer()` block body, after `session$setInputs()`.

### `testServer()`: Output is `NULL` after `setInputs()`

**Cause:** `session$flushReact()` not called after `setInputs()`.

**Fix:** Always follow `setInputs()` with `session$flushReact()` before asserting outputs.

### `AppDriver`: Test flaky — passes and fails on alternate runs

**Cause:** Timing issue — `wait_for_idle()` not called after an interaction, or missing `seed`.

**Fix:** Add `app$wait_for_idle()` after every `set_inputs()` or click. Set `seed` in `AppDriver$new()`.

### `AppDriver`: Input ID not found

**Cause:** Module namespace prefix missing. Module input `severity` inside `"ae_filter"` module must be referenced as `"ae_filter-severity"`.

**Fix:** Use the `"module_id-input_id"` syntax in all `AppDriver` input references.

### Snapshot test fails unexpectedly

**Cause:** Intentional UI change was made and the old snapshot is now stale.

**Fix:** Run `shinytest2::snapshot_review()` in the console, review the diff, and accept the new snapshot. Never delete `_snaps/` to "fix" a failing snapshot — review it first.

### `expect_error()` does not catch the error

**Cause:** The error message pattern does not match, or `call. = FALSE` was not set (adds extra text).

**Fix:** Always set `call. = FALSE` in `stop()`. Use a partial match string in `expect_error(., "partial text")`.

---

## Testing Checklist

### Unit tests
- [ ] One `test_that()` block per behavior
- [ ] Test data created via factory function, not bare object
- [ ] Covers: normal input, zero-row result, wrong type, missing required column
- [ ] `set.seed()` set before any random data generation
- [ ] Error strings match what `stop(., call. = FALSE)` actually produces

### `testServer()` tests
- [ ] Reactive arguments passed as `reactive({...})` objects
- [ ] `session$setInputs()` followed by `session$flushReact()` before assertions
- [ ] Return value accessed via `session$getReturned()()` (called with `()`)
- [ ] Outputs inspected via `output$id`, not `session$output$id`
- [ ] No duplication of unit-test logic — `testServer()` tests reactive wiring only

### `AppDriver` tests
- [ ] `seed` set in `AppDriver$new()`
- [ ] `on.exit(app$stop(), add = TRUE)` immediately after `AppDriver$new()`
- [ ] `app$wait_for_idle()` after every interaction
- [ ] Module input IDs use `"module_id-input_id"` syntax
- [ ] Snapshots reviewed and committed intentionally — never auto-deleted
- [ ] One flow per `test_that()` block — no mega-tests
- [ ] Multi-tab app has an all-tabs smoke test that visits every tab AND exercises
      each tab's primary interaction
- [ ] Smoke test asserts on `app$get_logs()` `location == "shiny"` errors + absence
      of `.shiny-output-error` — NOT just "console clean / output non-empty"
- [ ] Gate validated: breaking the feature once makes the smoke test go red
