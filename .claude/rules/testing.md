# Testing Rules

These rules apply to all R and Shiny code in this project.

## Rule 1 — What to test

Every function with non-trivial logic gets a unit test.

**Decision rule:** If you can write a meaningful assertion about a function's output given controlled inputs, write a unit test.

- Pure functions → `testthat` unit tests, always
- R6 class methods → `testthat` unit tests, always
- Module server reactive logic → `testServer()` tests
- UI functions (`mod_*_ui`) → covered at the `AppDriver` layer, not unit tested
- Thin one-line wrappers that delegate entirely to a well-tested package → no test required

## Rule 2 — Directory structure

```
tests/
  testthat/        # testthat unit tests + testServer() tests
  shinytest2/      # AppDriver E2E tests and _snaps/ snapshots
```

Run with `testthat::test_dir("tests/testthat")` for raw Shiny apps; `devtools::test()` for package-based apps (golem, leprechaun).

No external fixture files. All test data lives inside the test files.

## Rule 3 — Test data

Build test data with factory functions, not top-level objects. Factory functions return a fresh copy for each test, preventing shared mutable state between `test_that()` blocks.

```r
# CORRECT — factory function, fresh copy per test
make_sample_data <- function() {
  tibble(
    id       = c("001", "002"),
    category = c("A", "B")
  )
}

# WRONG — top-level object shared across all tests
ae_data <- tibble(...)
```

Place `set.seed()` at the top of any factory that generates random data. Use the same seed consistently within a file.

## Rule 4 — Test maintenance

When any code changes, update the corresponding tests. Always run the **full test suite**, not just tests for the modified file — a change to a utility function can break downstream module tests.

## Rule 5 — Remediation on failure

After any code change, run all tests. If failures occur:

1. Diagnose whether the **code** broke a contract or the **test** reflects old behavior that was intentionally changed — fix the right thing
2. Attempt remediation and re-run
3. Repeat up to **3 rounds total**
4. After 3 rounds, stop. Report what failed, what was attempted, and surface the issue to the user — do not continue modifying code blindly

## Rule 6 — Every tab/output gets runtime coverage (no dark corners)

A passing `testServer()` test proves reactive *logic*; it does NOT prove an output
renders or an observer survives its first flush in a real browser. A unit test on a
helper proves the helper; it says nothing about the module that calls it. Many
runtime failures live only in the wired, rendered app: an output that errors on
render, an observer that crashes on first flush, a NULL/failed client cascading
into a cryptic `object of type 'closure' is not subsettable`, a UI control passed
the wrong object type (e.g. a `bsicons::bs_icon()` into `actionButton(icon=)`,
which fails `validateIcon` and blocks startup).

Therefore, for any app with **more than one tab / screen / major output**:

1. **Ship a startup smoke test** (`AppDriver`) that launches the real app, visits
   **every** nav panel / tab, **exercises each tab's primary interaction** (click
   the button / change the input, then `wait_for_idle()` — a render error only
   fires when its reactive actually executes), and then asserts **nothing threw**.
   See `examples/06. tables/tests/testthat/test-all-tabs-smoke.R` +
   `helper-shiny-smoke.R` for the canonical pattern. It is cheap and broad — it
   does not assert features, only that nothing threw.

   **"Nothing threw" must be a POSITIVE check, not the absence of a signal that
   may not fire.** Two intuitive assertions are *false-pass traps*:
   - ❌ "the browser console has no errors" — a Shiny **render** error
     (`renderDT`/`render_gt`/`renderUI` throwing) is caught by Shiny and shown in
     the output element; it is **never written to the browser console**.
   - ❌ "the output element is non-empty" — a failed render leaves a non-empty
     `shiny-output-error` `<div>` behind, so "got some HTML" passes while the
     output is broken.

   The signal that **does** fire on a render error is the app's **stderr**: Shiny
   prints `Warning: Error in <fn>: ...`, which `shinytest2` captures in
   `app$get_logs()` under `location == "shiny"`. Assert on all three:
   1. **`app$get_logs()` has no `location == "shiny"` line matching `Error`** —
      the universal catch; needs no output IDs or per-widget markers.
   2. **No `.shiny-output-error` element exists** (`app$get_html(".shiny-output-error")`
      returns `NULL`) — belt-and-braces in the DOM.
   3. **No browser-console errors** (`level == "error"`) — catches client-side JS.
   If the app uses the log4r logger, *also* assert the log has no `FATAL`/`ERROR`
   (per [logging](logging.md)) — but never *instead* of the stderr scan, because a
   render error that is not wrapped in `with_error_handling()` is shown, not logged.
   `expect_no_shiny_errors(app)` in `helper-shiny-smoke.R` bundles 1–3; copy it in.
2. **Do not let a single happy-path E2E test stand in for whole-app coverage.** A
   test that only loads the default tab gives false confidence: "all tests pass"
   while 4 of 5 tabs were never rendered. If a tab is too expensive to E2E fully,
   it still gets the smoke visit in Rule 6.1. And a green smoke count proves
   nothing if its assertions can't fail — when you write or change a gate, **break
   the feature once and confirm the gate goes red**, then restore.
3. **Guard external-dependency construction.** Anything built from a key/network/
   service (LLM client, DB pool, file handle) can return the `with_error_handling()`
   fallback (`NULL`). Modules must guard that NULL and fail with a clean message,
   not wire downstream reactives with a broken object. Cover the NULL path.
4. **Continuously-busy apps never go idle — don't `wait_for_idle()` while they
   run.** An app with a running `invalidateLater()` loop, a poll, or a live
   `ExtendedTask`/stream keeps Shiny perpetually busy, so `app$wait_for_idle()`
   does **not** return — it aborts with "An error occurred while waiting for Shiny
   to be stable" and the smoke test fails for the wrong reason. Drive these apps
   by **starting the activity, sleeping a fixed wall-clock interval to let frames
   fire (`Sys.sleep(n)`), then stopping/pausing it BEFORE any `wait_for_idle()`**
   so the reactive graph can settle and assertions can read final values. Read
   live values mid-run with `app$get_value()` (no idle wait needed). Worked
   reference: `examples/09. annimation/tests/testthat/test-app-smoke.R`.

## Rule 7 — Verify in the locked environment, the way it will be run

Tests (and any smoke run) must execute against the **renv library**, not a stray
session. Run from the project root with renv active
(`source("renv/activate.R")`), e.g.
`NOT_CRAN=true Rscript -e 'source("renv/activate.R"); setwd(<app>); library(shinytest2); source("global.R"); testthat::test_dir("tests/testthat")'`.
Running an app from a long-lived REPL/IDE session that loaded packages before renv
activated can resolve a dependency to a **different version** than `renv.lock` — the
classic symptom is an error naming a symbol that does not exist in the locked
package (e.g. an old DT internal). If a failure cannot be reproduced under a fresh
renv-activated process, suspect environment drift before chasing a code bug.

Run from the **project root**, not the app subdirectory. Sourcing
`source("renv/activate.R")` with the working directory set inside an app folder
(e.g. `examples/09. annimation/`) makes renv fail to find its project and try to
**re-bootstrap itself over the network** ("Bootstrapping renv … Downloading renv …
FAILED"), which then halts the run. Activate at the root, then `setwd()` into the
app — exactly as the command above does.
