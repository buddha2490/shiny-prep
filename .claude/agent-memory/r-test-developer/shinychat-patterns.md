---
name: shinychat-patterns
description: Testing patterns for shinychat + ellmer apps — DOM submission, shinytest2 runner, reactive context pitfalls discovered in examples/05. shinychat/
type: pattern
updated: 2026-06-20
---

## shinychat chat_ui() submission via AppDriver

The shinychat `chat_ui()` textarea uses `data-shiny-no-bind-input="true"`. Standard `app$set_inputs()` does NOT trigger message submission. Must use JavaScript:

```r
submit_chat_message <- function(app, textarea_id, message) {
  js <- sprintf("
    (function() {
      var ta = document.getElementById('%s');
      var setter = Object.getOwnPropertyDescriptor(
        window.HTMLTextAreaElement.prototype, 'value').set;
      setter.call(ta, '%s');
      ta.dispatchEvent(new Event('input', { bubbles: true }));
      ta.dispatchEvent(new KeyboardEvent('keydown', {
        bubbles: true, cancelable: true, key: 'Enter', code: 'Enter', keyCode: 13
      }));
    })()", textarea_id, gsub("'", "\\\\'", message))
  app$run_js(js)
}
```

## AppDriver JavaScript return values

- `app$run_js(js)` — executes JS, returns `self` (not the JS result value)
- `app$get_js(js)` — executes JS and returns the evaluated value as R object
- Use `get_js()` when you need to read a DOM value (e.g., textarea content)

## shinytest2 0.5.1 test runner location

In shinytest2 0.5+, `test_app()` scans `tests/testthat/` ONLY. AppDriver tests go in `tests/testthat/`, NOT `tests/shinytest2/`. The `tests/shinytest2/` directory is legacy convention.

Run command: `NOT_CRAN=true Rscript -e "source('renv/activate.R'); setwd('examples/05. shinychat'); library(shinytest2); test_app('.')"`

The `NOT_CRAN=true` env var is required to prevent AppDriver$new() from calling `skip_on_cran()`.

## get_screenshot() requires showimage

`app$get_screenshot()` without a `file` argument requires the `showimage` package (interactive display). Always pass `file = tempfile(fileext = ".png")` in automated tests.

## reactiveVal read requires reactive context

Reading a `reactiveVal` (calling it as a function) REQUIRES a reactive context. If called in module server body code that is NOT inside `reactive()`, `observe()`, or `isolate()`, it throws `Operation not allowed without an active reactive context`. Use `shiny::isolate()` for one-time reads at module startup.

**Bug found in examples/05. shinychat server.R**: `make_client` lambda read `app_state$client()` without `isolate()`, causing app failure under shinytest2. Fixed by wrapping with `shiny::isolate()`.

## AppState$new() — reactiveVal() outside session

`reactiveVal()` can be CREATED outside a Shiny session (no error) but READING it (`rv()`) outside a reactive context throws. Use `shiny::isolate(rv())` to safely read outside reactive scopes.

## local_mocked_bindings for ellmer::chat_anthropic

Mock the real API call with:
```r
local_mocked_bindings(
  chat_anthropic = function(...) make_mock_chat(),
  .package = "ellmer"
)
```
The mock chat object needs `get_model()`, `get_system_prompt()`, `set_turns()`, `get_turns()` methods.

## testServer() renderUI output access

In `testServer()`, `output$id` for a `renderUI()` returns a **named list** with two elements:
- `$html` — the rendered HTML as an `html`/`character` vector
- `$deps`  — HTML dependencies list

Access HTML with `as.character(output$id$html)`, NOT `output$id[[1]]`.
Confirmed in bslib 0.9.0 / shiny 1.11.1 under renv.

## with_error_handling() in unit tests

Pass `session = NULL` and `notify = FALSE` to suppress Shiny session requirements and notification side effects in unit tests. The function does not throw when session is NULL.
