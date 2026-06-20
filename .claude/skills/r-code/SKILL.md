---
name: r-code
description: Auto-invoked for any R code request. Governs the write-source-test-validate WORKFLOW and artifact/test structure. Defers Shiny domain patterns (modules, reactives, tables, layout) to the dedicated skills, which take precedence on those topics.
---

# R Code Generation Skill

This skill governs the **workflow** for all R code generation. It is auto-invoked whenever the user requests R code.

Style, packages, naming, and file layout are enforced by project rules (`.claude/rules/`) — they apply to every interaction, not just this skill. This skill defines *how code is produced and validated*.

**Scope — workflow, not domain patterns.** This skill is the always-on backbone: it owns the write → source → test → validate loop and the artifact/test-file structure for *any* R code. It does **not** own Shiny domain patterns. When the work is Shiny-specific — modules (`shiny-modules`), reactivity (`reactive-programming`), tables (`dt-table`/`gt-table`/`reactable-table`/`rhandsontable-table`), layout (`bslib-layout`/`shinydashboard-layout`), async (`mirai`), error handling (`shiny-error-handling`), testing (`shiny-testing`), etc. — the dedicated skill takes precedence on the domain specifics. Apply this skill's workflow *around* whatever pattern that skill prescribes.

## Core Principle

**All generated code must run without errors.** If you wrote it, you run it. No exceptions.

## Function Workflow (3 artifacts)

Every function produces three artifacts:

1. `R/<function_name>.R` — the function file with roxygen2 documentation
2. `tests/testthat/test-<function_name>.R` — a self-contained testthat test file
3. **Validated execution** — both files sourced/run successfully

### Validation Sequence

1. **Write** the function file to `R/`
2. **Source** it in R to confirm it loads without errors
3. **Write** the test file to `tests/testthat/`
4. **Run** the tests: `Rscript -e 'testthat::test_file("tests/testthat/test-<name>.R")'`
5. **If any step fails:** read the error, fix the code, re-run from the failed step
6. **Report** results — confirm what passed, flag anything that needed revision

## Function File Template (`R/*.R`)

```r
#' Title of the Function
#'
#' @description
#' A clear description of what the function does.
#'
#' @param param_name Description of the parameter.
#' @param another_param Description with expected type/format.
#'
#' @return Description of the return value.
#'
#' @examples
#' # Example usage
#' result <- my_function(arg1, arg2)
#'
#' @export
my_function <- function(param_name, another_param) {
  # --- Validate inputs -------------------------------------------------------
  # input validation code

  # --- Main logic -------------------------------------------------------------
  # function body

  # --- Return -----------------------------------------------------------------
  return(result)
}
```

Rules:
- One primary function per file
- Helper functions may live in the same file below the primary function, without `@export`
- All parameters documented with `@param`
- Return value documented with `@return`
- At least one `@examples` block

## Test File Template (`tests/testthat/test-*.R`)

```r
# tests/testthat/test-<function_name>.R

library(testthat)

# Source the function under test (raw Shiny apps only — package-based apps
# like golem/leprechaun load functions automatically via devtools::load_all())
source("R/<function_name>.R")

# --- Factory Functions --------------------------------------------------------
# Build test data with factory functions — each test gets a fresh copy.

make_sample_data <- function() {
  set.seed(12345)
  tibble(
    id    = c("001", "002", "003"),
    value = rnorm(3)
  )
}

# --- Tests --------------------------------------------------------------------

test_that("<function_name> handles normal input", {
  result <- my_function(make_sample_data())
  expect_equal(nrow(result), expected_n)
})

test_that("<function_name> handles edge case: empty input", {
  empty_df <- tibble(id = character(), value = numeric())
  expect_error(my_function(empty_df), "expected error message")
})

test_that("<function_name> handles edge case: missing values", {
  data_with_na <- make_sample_data()
  data_with_na$value[1] <- NA
  # test NA handling
})
```

Rules:
- Test files live in `tests/testthat/` and are named `test-<source_file_name>.R`
- For raw Shiny apps, `source()` the function under test; for package-based apps (golem, leprechaun), use `devtools::load_all()` or `testthat::test_check()`
- **Test data uses factory functions**, not top-level shared objects — each `test_that()` gets a fresh copy
- Place `set.seed()` inside factory functions that generate random data
- No external fixture files — all test data is defined inline
- Test at minimum: normal input, empty input, missing values (NA), and function-specific edge cases
- Do NOT use `rm(list = ls())` — testthat manages test isolation automatically

## Analysis Script Workflow

When the user asks for analysis code (not a reusable function), write it as a standalone `.R` script in `programs/` or a location the user specifies.

1. **Write** the script
2. **Execute** it via `Rscript`
3. **Fix and re-run** until clean execution
4. **Report** results

Analysis scripts do not require a separate test file, but all code must still be executed to confirm it runs.

## Data Dependencies

Some scripts depend on input files that may not exist yet. When this happens:

- **If the input data exists:** Run the script normally.
- **If the input data does not exist:** Tell the user which files are missing. Do not fabricate placeholder files. Offer to generate the prerequisite data or script first.
