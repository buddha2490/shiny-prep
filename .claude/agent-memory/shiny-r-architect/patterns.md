---
name: module-patterns
description: Shiny module pattern cheat sheet — NS, returned reactives, shared rv, R6 bridge, nesting, dynamic
type: pattern
updated: 2026-06-18
---

# Shiny Module Patterns — Reference Notes

Documented from `examples/03. modules/` build (2026-06-18). Related: [[examples-built]], [[dt-masking]].

## Pattern 1: Basic Module
- NS(id) in UI wraps ALL input/output IDs
- moduleServer(id, function(input, output, session) { ... })
- input/output inside moduleServer are pre-namespaced — no ns() needed inside server
- Pass data as explicit function arguments; modules never reach into global scope

## Pattern 2: Module Communication (returned reactive)
- Producer: `moduleServer()` returns `reactive({ ... })` as the last expression
- Consumer: receives the reactive as a function argument, calls it with `()` to read
- Validation: `if (!is.reactive(data)) stop(...)` in consumer server
- Anti-pattern: passing a plain data frame — it won't update reactively

## Pattern 3: Shared State with reactiveValues
- `rv <- reactiveValues(...)` created ONCE in parent server.R, NOT inside any module
- Writer module: `observe({ rv$field <- input$x })` — side effect write
- Reader modules: read `rv$field` inside `reactive()` or `render*()` to create dependency
- Initial values should be set when creating rv so readers have defined state at startup
- Use when: multiple modules need to read/write the same set of named values

## Pattern 4: Shared State with R6
- `PatientStore$new()` must be called inside server() because it calls `reactiveVal()`
- reactiveVal lives INSIDE the R6 instance (private field)
- Writer calls `store$set_patient(x)` → internally calls `private$.selected_patient(x)`
- Reader calls `store$get_patient()` INSIDE reactive context → reads reactiveVal, creates dependency
- Use when: need encapsulated methods, input validation, testable business logic
- Use when: state is more complex than key-value pairs

## Pattern 5: Nested Modules
- Outer UI: call inner UIs with `ns("inner_id")` as the id argument
  - Produces compound IDs: "outer-inner-output_id"
- Outer server: call inner servers with `session$ns("inner_id")` as the id argument
  - MUST use session$ns(), not plain string — must match what was rendered in UI
- Data flows DOWN: outer filters, inners only display
- Inner modules are standard modules — no special API, fully reusable

## Pattern 6: Dynamic Modules
- Counter pattern: `counter <- reactiveVal(0)` in host; increment on each Add
  - Never reuse IDs in a session
- `insertUI(selector, where = "beforeEnd", ui = div(id = ns(wrap_id), mod_ui(ns(card_id))))`
- Call module server IMMEDIATELY after insertUI()
- `removeUI(selector = paste0("#", ns(wrap_id)))` — target the wrapper div
- `local({ cid <- card_id; observeEvent(...) })` — local() captures loop var by value
  - Without local(), all observers close over same card_id (last value) — silent bug
- Remove signal: card server returns `reactive({ input$remove > 0 })`
- Track active instances in `reactiveVal(character(0))`

## Synthetic Clinical Data Pattern (inline, no CSV)
```r
set.seed(42)
adsl <- data.frame(
  USUBJID = sprintf("SUBJ-%03d", seq_len(50)),
  AGE = sample(18:80, 50, replace = TRUE),
  ...
)
adae <- data.frame(USUBJID = sample(adsl$USUBJID, 200, replace = TRUE), ...)
adae <- adae %>% left_join(adsl %>% select(USUBJID, ARM), by = "USUBJID")
```
