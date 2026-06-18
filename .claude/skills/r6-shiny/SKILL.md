---
name: r6-shiny
description: Auto-invoked when working with R6 classes in Shiny applications. Governs R6 class anatomy, reactive bridging patterns, shared state across modules, testing, and when to prefer R6 over reactiveValues.
---

# R6 Classes in Shiny

R6 is the **preferred data structure** for managing state and business logic in Shiny applications. Pass R6 objects between modules by reference rather than wrapping them in reactive chains.

## Why R6 Over reactiveValues

| Dimension | `reactiveValues()` | R6 |
|---|---|---|
| Encapsulation | None — a named list of reactive slots | Private fields, public methods, validation |
| Business logic | Lives outside the values, scattered in server | Lives inside the object (methods) |
| Testability | Requires reactive context (`testServer()`) | Plain `testthat` — no Shiny needed |
| Cross-module sharing | Must be wrapped in `reactive()` | Pass the object reference directly |
| Derived values | Must compute outside | Active bindings compute on demand |

**Prefer `reactiveValues()`** only for simple, local, auto-reactive state in small apps.

**Prefer R6** for shared data stores, business logic, data transformation pipelines, and anything that should be testable without Shiny.

## R6Class() Anatomy

```r
library(R6)

MyClass <- R6::R6Class(
  classname  = "MyClass",
  portable   = TRUE,         # always TRUE — required for cross-package inheritance
  cloneable  = TRUE,         # set FALSE for singletons
  public = list(
    # --- Fields -----------------------------------------------------------
    name = NULL,

    # --- Constructor ------------------------------------------------------
    initialize = function(name) {
      self$name <- name
    },

    # --- Methods ----------------------------------------------------------
    greet = function() {
      cat("Hello, I am", self$name, "\n")
    }
  ),
  private = list(
    # --- Private fields — prefix with . -----------------------------------
    .data = NULL,

    # --- Private methods --------------------------------------------------
    validate = function(x) {
      if (!is.data.frame(x)) stop("`x` must be a data frame.", call. = FALSE)
    },

    # --- Finalizer (runs on GC) -------------------------------------------
    finalize = function() {
      message("Object cleaned up.")
    }
  ),
  active = list(
    # Read-only derived value
    n_rows = function(value) {
      if (!missing(value)) stop("`n_rows` is read-only.", call. = FALSE)
      if (is.null(private$.data)) return(0L)
      nrow(private$.data)
    },
    # Read/write with validation
    data = function(value) {
      if (missing(value)) return(private$.data)
      private$validate(value)
      private$.data <- value
    }
  )
)
```

### Key Rules

1. **Reference fields must be created in `initialize()`**, not as defaults in the class body. Fields defined as defaults are shared across all instances:

```r
# WRONG — all instances share the same list
Bad <- R6::R6Class("Bad", public = list(items = list()))

# CORRECT — each instance gets its own list
Good <- R6::R6Class("Good",
  public = list(
    items = NULL,
    initialize = function() self$items <- list()
  )
)
```

2. Use `self$` to access public members, `private$` for private ones.
3. Return `invisible(self)` from methods to enable chaining: `obj$set_n(10)$apply()`.
4. Active bindings: `missing(value)` is `TRUE` on a read (getter), `FALSE` on a write (setter).

## Reactivity

R6 objects are plain environments — reading or writing fields does **not** register or signal Shiny reactive dependencies. Pair the R6 object with an explicit `reactiveVal` trigger: R6 holds state and logic; the `reactiveVal` serves only as a version counter.

## Core Pattern: Shared Data Store Across Modules

Create **one R6 instance** in `server()`, pass it directly to all module server functions alongside a shared trigger.

```r
library(shiny)
library(R6)
library(dplyr)

# --- R6 data store ----------------------------------------------------------
AppStore <- R6::R6Class("AppStore",
  public = list(
    raw_data     = NULL,
    result_data  = NULL,
    n_rows       = 10L,
    multiplier   = 1,

    initialize = function(data) {
      self$raw_data <- data
    },

    apply_filter = function(n_rows, multiplier) {
      if (!is.numeric(n_rows) || n_rows < 1)
        stop("`n_rows` must be a positive number.", call. = FALSE)
      self$n_rows      <- as.integer(n_rows)
      self$multiplier  <- multiplier
      self$result_data <- self$raw_data %>%
        head(self$n_rows) %>%
        mutate(Sepal.Length = Sepal.Length * self$multiplier)
    }
  )
)

# --- Filter module ----------------------------------------------------------
filter_ui <- function(id) {
  ns <- NS(id)
  tagList(
    numericInput(ns("n_rows"),     "Rows",       10, 1, 150),
    numericInput(ns("multiplier"), "Multiplier", 1),
    actionButton(ns("go"),         "Apply")
  )
}

filter_server <- function(id, store, trigger) {
  moduleServer(id, function(input, output, session) {
    observeEvent(input$go, {
      store$apply_filter(input$n_rows, input$multiplier)
      trigger(trigger() + 1L)       # signal all downstream modules
    })
  })
}

# --- Table module -----------------------------------------------------------
table_ui <- function(id) {
  ns <- NS(id)
  tableOutput(ns("tbl"))
}

table_server <- function(id, store, trigger) {
  moduleServer(id, function(input, output, session) {
    output$tbl <- renderTable({
      trigger()                     # register dependency
      req(!is.null(store$result_data))
      store$result_data
    })
  })
}

# --- App --------------------------------------------------------------------
ui <- fluidPage(
  filter_ui("filters"),
  table_ui("results")
)

server <- function(input, output, session) {
  store   <- AppStore$new(iris)
  trigger <- reactiveVal(0L)

  filter_server("filters", store = store, trigger = trigger)
  table_server("results",  store = store, trigger = trigger)
}

shinyApp(ui, server)
```

**Passing conventions:**
- Pass the **same R6 instance** to all modules — do not clone it for sharing.
- Pass the **same `reactiveVal` trigger** — bump it inside every observer that mutates shared state.
- If modules need independent trigger scopes, create separate named triggers.

## Cloning

- **Shared state** — pass the same reference, no cloning.
- **Snapshot** (undo/redo, branch-compare) — `$clone(deep = TRUE)` for a fully independent copy.
- **Shallow clone for modules** — almost always a bug; mutations to sub-objects in one module silently affect others.

## Testing R6 Classes

The primary advantage of R6: **business logic tests require no reactive context**. Test class methods with plain `testthat`.

```r
# tests/testthat/test-app-store.R
library(testthat)

test_that("apply_filter returns the correct number of rows", {
  store <- AppStore$new(iris)
  store$apply_filter(n_rows = 5, multiplier = 2)
  expect_equal(nrow(store$result_data), 5)
})

test_that("apply_filter errors on invalid n_rows", {
  store <- AppStore$new(iris)
  expect_error(
    store$apply_filter(n_rows = 0, multiplier = 1),
    "`n_rows` must be a positive number."
  )
})
```

For Shiny wiring, use `testServer()` — keep it thin; business logic is already covered above:

```r
test_that("filter module updates store and fires trigger", {
  store   <- AppStore$new(iris)
  trigger <- reactiveVal(0L)

  testServer(
    filter_server,
    args = list(store = store, trigger = trigger),
    {
      session$setInputs(n_rows = 5, multiplier = 2, go = 1)
      expect_equal(nrow(store$result_data), 5)
      expect_gt(trigger(), 0L)
    }
  )
})
```

## Key Conventions

1. **One R6 instance per store** — create in `server()`, pass to modules by reference.
2. **Pair with a `reactiveVal` trigger** — bump it inside every observer that mutates shared state.
3. **Private fields prefixed `.`** — e.g., `private$.data`.
4. **Reference fields in `initialize()`** — never as class-body defaults (shared-instance bug).
5. **Active bindings for read-only derived values** — keeps derivation logic inside the class.
6. **Test R6 logic with plain `testthat`** — no reactive context needed.
7. **Test Shiny wiring with `testServer()`** — thin tests that verify the module calls the store and bumps the trigger.
8. **Deep clone for snapshots only** — shared state passes the same reference.
