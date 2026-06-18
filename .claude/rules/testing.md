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
