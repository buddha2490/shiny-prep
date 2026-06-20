---
name: codebase
description: Project structure facts for r-test-developer — where things live, test runner commands, key utilities
type: codebase-fact
updated: 2026-06-19
---

## Project layout

- Examples at `examples/NN. name/` — each is a standalone Shiny app (global.R, ui.R, server.R)
- Reusable error/logging helpers at `R/utils_error.R` and `R/utils_logger.R` in each app
- AppState R6 class in `R/app_state.R` — holds `reactiveVal` wrapping an ellmer Chat client
- Tests in `tests/testthat/` per example app

## Key example apps

- `examples/04. error-handling/` — reference for utils_error.R / utils_logger.R (copy verbatim)
- `examples/05. shinychat/` — shinychat + ellmer reference app, 5 tabs, tested 2026-06-19

## Test runner commands

```r
# Unit + testServer tests only (from app dir):
setwd('examples/05. shinychat')
testthat::test_dir('tests/testthat')

# Full suite including AppDriver (requires NOT_CRAN=true):
# Run from project root:
NOT_CRAN=true Rscript -e "
  source('renv/activate.R')
  setwd('examples/05. shinychat')
  library(shinytest2)
  test_app('.')
"
```

## Package availability

- shinytest2 0.5.1 is installed (added 2026-06-19, recorded in renv.lock)
- ellmer, shinychat, log4r, R6, promises, coro, scales all available

## Error catalog codes used in examples/05. shinychat

- ERR-LLM-001: LLM API call failed
- ERR-LLM-002: Structured output parse failure
- ERR-LLM-003: Markdown stream failure
- ERR-CALC-001: Calculation error (turn parsing, token summary)
- ERR-IO-001: Export failure
- ERR-APP-999: Fatal startup error

See [[shinychat-patterns]] for testing patterns.
