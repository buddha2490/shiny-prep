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
   **every** nav panel / tab, and asserts the app logged **no `FATAL`/`ERROR`** and
   the browser console has no errors. See
   `examples/05. shinychat/tests/testthat/test-all-tabs-smoke.R` for the pattern.
   This is cheap and broad — it does not assert features, only that nothing throws.
2. **Do not let a single happy-path E2E test stand in for whole-app coverage.** A
   test that only loads the default tab gives false confidence: "all tests pass"
   while 4 of 5 tabs were never rendered. If a tab is too expensive to E2E fully,
   it still gets the smoke visit in Rule 6.1.
3. **Guard external-dependency construction.** Anything built from a key/network/
   service (LLM client, DB pool, file handle) can return the `with_error_handling()`
   fallback (`NULL`). Modules must guard that NULL and fail with a clean message,
   not wire downstream reactives with a broken object. Cover the NULL path.

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
