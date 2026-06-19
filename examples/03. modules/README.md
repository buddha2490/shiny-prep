# Shiny Modules Reference App

A comprehensive reference application demonstrating all major Shiny module patterns in a pharma/clinical context. Each tab implements a distinct module architecture pattern for future reuse.

## Quick Start

```r
shiny::runApp("examples/03. modules")
```

Requires: `shiny`, `bslib`, `DT`, `dplyr`, `R6`.

## Data

Synthetic CDISC ADaM datasets built inline in `global.R` with `set.seed(42)`:

| Dataset | Description | Rows | Key Columns |
|---------|-------------|------|-------------|
| `adsl` | Subject-level demographics | 50 | USUBJID, AGE, SEX, RACE, ARM, COUNTRY |
| `adae` | Adverse events | 200 | USUBJID, AEDECOD, AESEV, AESTDTC, AESER, ARM |
| `adlb` | Lab results | 500 | USUBJID, PARAMCD, PARAM, AVAL, VISITNUM, VISIT, BASE, CHG |

---

## Tab 1: Basic Module (`R/mod_demographics.R`)

The minimal, foundational Shiny module. A demographics table with an ARM filter dropdown.

### Patterns

| Pattern | What it does | Where in code |
|---------|-------------|---------------|
| **`NS(id)`** | Creates a namespace function. Every input/output ID in the UI MUST be wrapped with `ns()`. Prevents collisions when multiple instances exist. | `ns <- NS(id)` at top of UI function |
| **`moduleServer(id, ...)`** | Server counterpart. Inside the callback, `input`, `output`, and `session` are pre-namespaced. Write `input$arm_filter`, not `input[["demo-arm_filter"]]`. | Server function body |
| **Data as argument** | Modules receive data as explicit arguments, never reaching into global scope. Makes modules testable and reusable. | `mod_demographics_server("demo", adsl = adsl)` |
| **Input validation** | `is.data.frame(adsl)` check before entering reactive graph. Surfaces errors at startup, not inside a render. | Top of server function |

### Key rules

- Every ID in the UI → wrap with `ns()`
- Every `moduleServer()` id → must match the UI function's id
- Modules are just functions — nothing magic
- Pass data in, never access global objects

---

## Tab 2: Module Communication (`R/mod_filter.R` + `R/mod_listing.R`)

A filter module RETURNS a reactive; a listing module CONSUMES it. The standard inter-module communication pattern.

### Patterns

| Pattern | What it does | Where in code |
|---------|-------------|---------------|
| **Returning a reactive** | `moduleServer()` returns whatever its inner function returns. Returning a `reactive()` makes the module a "producer." | `mod_filter.R` — last line: `filtered_data` |
| **Receiving a reactive argument** | Consumer module accepts the reactive as a function argument and calls it with `()` to read the current value. | `mod_listing_server("listing", data = filtered_subjects)` |
| **`is.reactive()` validation** | Guards against the common mistake of passing a plain data frame instead of a reactive. | `mod_listing.R` — input validation |
| **Parentheses convention** | `data` = reactive object (function). `data()` = current value (data frame). Forgetting `()` passes a function to `datatable()` — silent breakage. | All `data()` calls in `mod_listing.R` |

### Wiring in server.R

```r
# Producer returns a reactive
filtered_subjects <- mod_filter_server("filter", adsl = adsl)

# Consumer receives the reactive (not the value!)
mod_listing_server("listing", data = filtered_subjects)
```

### When to use this pattern

- Two modules need a one-way data flow (producer → consumer)
- The consumer doesn't need to know how the data was produced
- One producer, one or few consumers
- Compare: for one producer + many consumers, consider reactiveValues (Tab 3)

---

## Tab 3: Shared State with reactiveValues (`R/mod_ae_filters.R` + `R/mod_ae_table.R` + `R/mod_ae_summary.R`)

Three modules share a single `reactiveValues` object. One writer sets filter selections; two readers display filtered data.

### Patterns

| Pattern | What it does | Where in code |
|---------|-------------|---------------|
| **Parent-owned rv** | `reactiveValues()` is created in `server.R`, not inside any module. Parent owns shared state; children receive it. | `server.R` — `rv <- reactiveValues(...)` |
| **rv as argument** | All three modules receive the same `rv` object. The writer updates fields; readers react. | `mod_ae_filters_server("ae_filters", rv = rv)` |
| **Writer pattern** | `observe({ rv$severity_filter <- input$severity })`. Side effect that fires eagerly when input changes. | `mod_ae_filters.R` — observe blocks |
| **Reader pattern** | `reactive({ if (rv$severity_filter != "All") ... })`. Reads rv fields, creating automatic dependencies. | `mod_ae_table.R` — filtered_ae reactive |
| **`is.reactivevalues()` check** | Validates the rv argument is actually a reactiveValues object. Catches wiring errors early. | Top of each module server |
| **Sentinel values** | `"ALL"` means "no filter active." Readers check for sentinels to skip filtering. Cleaner than NULL checks. | `rv$selected_subjects` handling |

### Architecture

```
server.R
  └── rv <- reactiveValues(severity_filter, serious_only, selected_subjects)
        ├── mod_ae_filters  [WRITES to rv]
        ├── mod_ae_table    [READS rv, renders DT table]
        └── mod_ae_summary  [READS rv, renders value boxes]
```

### When to use reactiveValues vs returning reactives

| Use reactiveValues when... | Use returned reactives when... |
|---------------------------|-------------------------------|
| Multiple modules read the same state | One-way producer → consumer flow |
| Multiple fields need to be grouped together | Single value being communicated |
| State needs to be written from one module, read from many | Consumer doesn't need to write back |
| You want a "shared bus" pattern | You want loose coupling and clear contracts |

---

## Tab 4: Shared State with R6 (`R/R6_PatientStore.R` + `R/mod_r6_selector.R` + `R/mod_r6_details.R`)

An R6 class manages selected patient state with reactive bridging. More structured than raw reactiveValues.

### Patterns

| Pattern | What it does | Where in code |
|---------|-------------|---------------|
| **R6 class with reactiveVal bridge** | A `reactiveVal()` stored in a private field provides reactive invalidation. External code calls methods; the reactiveVal handles Shiny reactivity internally. | `R6_PatientStore.R` — `private$.selected_patient` |
| **`set_patient()` / `get_patient()`** | Public methods wrap the reactiveVal. `set_patient()` writes (invalidates dependents); `get_patient()` reads (creates dependency). | `R6_PatientStore.R` — public methods |
| **Input validation in R6** | `set_patient()` validates the USUBJID against `valid_ids`. Business logic lives with the data, not scattered across modules. | `set_patient()` validation block |
| **Instance created in server.R** | Must be inside `server()` because `reactiveVal()` requires an active reactive domain. | `server.R` — `store <- PatientStore$new(...)` |
| **Same instance, multiple modules** | Selector writes via `store$set_patient()`; details reads via `store$get_patient()`. Both receive the same `store` object. | `server.R` wiring |

### R6 class anatomy

```r
PatientStore <- R6::R6Class(
  public = list(
    valid_ids = NULL,
    initialize = function(valid_ids) {
      private$.selected_patient <- reactiveVal(NULL)  # reactive bridge
    },
    set_patient = function(usubjid) {
      # validate, then write
      private$.selected_patient(usubjid)
    },
    get_patient = function() {
      private$.selected_patient()  # read = create dependency
    }
  ),
  private = list(
    .selected_patient = NULL
  )
)
```

### When to use R6 vs reactiveValues

| Use R6 when... | Use reactiveValues when... |
|----------------|--------------------------|
| State has business logic (validation, derived values) | Simple key-value storage |
| You want encapsulated methods | You just need fields that modules read/write |
| State needs to be unit-testable outside Shiny | Testing within Shiny context is sufficient |
| Complex state transitions (undo, history, computed fields) | Flat, independent fields |

---

## Tab 5: Nested Modules (`R/mod_patient_profile.R` + `R/mod_profile_*.R`)

An outer module contains three inner modules. Demonstrates namespace nesting and top-down data flow.

### Patterns

| Pattern | What it does | Where in code |
|---------|-------------|---------------|
| **NS nesting in UI** | Outer UI calls inner module UIs with `ns("inner_id")`. This produces compound IDs like `"patient_profile-header-content"`. | `mod_patient_profile_ui` — `mod_profile_header_ui(ns("header"))` |
| **Short id in server** | Inside `moduleServer()`, call inner servers with the SHORT id (`"header"`), NOT `session$ns("header")`. `moduleServer()` automatically nests under the parent namespace. Using `session$ns()` would double-namespace. | `mod_patient_profile_server` — `mod_profile_header_server("header", ...)` |
| **Data flows down** | Outer module filters datasets for the selected patient, passes pre-filtered reactives to inner modules. Inner modules never touch full datasets. | `patient_row`, `patient_labs`, `patient_aes` reactives |
| **Inner modules are standard** | Inner modules have no special "inner" API. They are normal modules that accept reactive data and render outputs. They can be used standalone. | All `mod_profile_*.R` files |
| **`updateSelectInput`** | Outer module populates patient dropdown at runtime using `updateSelectInput()` in an `observe()`. | `mod_patient_profile_server` — observe block |

### Namespace nesting diagram

```
server.R calls:
  mod_patient_profile_server("patient_profile", ...)
    └── moduleServer("patient_profile", ...)
          ├── input$patient  →  "patient_profile-patient"
          ├── mod_profile_header_server("header", ...)        # SHORT id
          │     └── moduleServer auto-nests → ns "patient_profile-header"
          │           └── output$header_content  →  "patient_profile-header-header_content"
          ├── mod_profile_labs_server("labs", ...)             # SHORT id
          │     └── moduleServer auto-nests → ns "patient_profile-labs"
          └── mod_profile_aes_server("aes", ...)              # SHORT id
                └── moduleServer auto-nests → ns "patient_profile-aes"
```

### The UI/server asymmetry for nested modules

| Context | Use `ns()` / `session$ns()`? | Why |
|---------|------------------------------|-----|
| Outer **UI** calling inner UI | Yes: `mod_inner_ui(ns("id"))` | UI functions don't auto-nest; `ns()` produces the full compound id |
| Outer **server** calling inner server | No: `mod_inner_server("id", ...)` | `moduleServer()` auto-nests under the parent session |
| **insertUI** (dynamic modules) | Yes for UI: `mod_card_ui(session$ns("id"))` | Raw DOM insertion, no auto-nesting |
| **insertUI** server call after | No: `mod_card_server("id", ...)` | `moduleServer()` still auto-nests |

### Common nesting mistakes

1. **Double-namespacing**: Using `session$ns("header")` in server calls — `moduleServer()` already nests, so you get `"parent-parent-header"` instead of `"parent-header"`
2. **Forgetting `ns()` in UI**: Passing `"header"` instead of `ns("header")` in the outer UI — inner module's DOM ids won't match the server
3. **Inner module accessing parent's inputs**: Inner modules should receive data as arguments, not reach up into the parent namespace

---

## Tab 6: Dynamic Modules (`R/mod_dynamic_host.R` + `R/mod_dynamic_card.R`)

Add and remove module instances at runtime. Each instance is an independent AE comparison card.

### Patterns

| Pattern | What it does | Where in code |
|---------|-------------|---------------|
| **Counter for unique IDs** | `reactiveVal(0)` increments with each new instance. `paste0("card_", counter)` generates IDs. Never reuse IDs — Shiny's reactive graph remembers removed IDs. | `mod_dynamic_host.R` — `counter` reactiveVal |
| **`insertUI()`** | Adds a DOM element at a CSS selector anchor. Use `session$ns("container_id")` for the selector. `where = "beforeEnd"` appends inside the container. | `insertUI(selector = ..., ui = ...)` |
| **`removeUI()`** | Removes a DOM element by CSS selector. Wrap each inserted card in a `div(id = ...)` so it can be targeted for removal. | `removeUI(selector = ...)` |
| **Server call after insertUI** | Call the card's `moduleServer()` immediately after `insertUI()`. Use the SHORT id (not `session$ns()`), because `moduleServer()` auto-nests. The UI must exist in the DOM before the server binds to it. | Steps 2 and 3 in the observeEvent |
| **Instance tracking** | `reactiveVal(character(0))` holds active instance IDs. Add on create, remove on destroy. Drives the instance count display. | `active_ids` reactiveVal |
| **`local()` for closures** | Inside a loop/observer chain, `local({ cid <- card_id; ... })` captures the loop variable by value. Without `local()`, all closures share the same variable (classic R bug). | Per-instance remove observer |
| **Card returns remove signal** | Card module returns `reactive(input$remove > 0)`. Host observes this to trigger removal. Card doesn't know about insertUI/removeUI. | `mod_dynamic_card.R` — return value |

### Dynamic module lifecycle

```
1. User clicks "Add Comparison"
2. counter increments → card_id = "card_3"
3. insertUI() adds card UI to DOM
4. mod_dynamic_card_server(session$ns(card_id), ...) registers reactive bindings
5. observeEvent(remove_signal(), ...) watches for the card's Remove button
6. active_ids updated: c("card_1", "card_2", "card_3")

When "Remove" is clicked on card_3:
7. remove_signal() fires TRUE
8. removeUI() removes the wrapper div from DOM
9. active_ids updated: c("card_1", "card_2")
```

### Production considerations

- Module server-side reactives persist in memory after `removeUI()`. For apps with many dynamic instances, implement a destroy pattern or use `session$onSessionEnded` for cleanup.
- Never reuse IDs within a session, even after removal — Shiny's internal reactive graph retains references.
- Consider a maximum instance limit for memory-constrained deployments.

---

## Architecture Notes

### File structure

```
examples/03. modules/
  global.R                    # packages, sources, inline synthetic data
  ui.R                        # page_navbar with 6 tabs, teaching cards
  server.R                    # thin wiring harness — rv, R6, module calls
  R/
    mod_demographics.R        # Tab 1: basic NS + moduleServer
    mod_filter.R              # Tab 2: producer (returns reactive)
    mod_listing.R             # Tab 2: consumer (receives reactive)
    mod_ae_filters.R          # Tab 3: reactiveValues writer
    mod_ae_table.R            # Tab 3: reactiveValues reader (table)
    mod_ae_summary.R          # Tab 3: reactiveValues reader (summary)
    R6_PatientStore.R         # Tab 4: R6 class with reactive bridge
    mod_r6_selector.R         # Tab 4: R6 writer
    mod_r6_details.R          # Tab 4: R6 reader
    mod_profile_header.R      # Tab 5: inner module (demographics)
    mod_profile_labs.R        # Tab 5: inner module (lab table)
    mod_profile_aes.R         # Tab 5: inner module (AE table)
    mod_patient_profile.R     # Tab 5: outer module (patient selector + inners)
    mod_dynamic_card.R        # Tab 6: per-instance card module
    mod_dynamic_host.R        # Tab 6: host (insertUI/removeUI, lifecycle)
```

### Module pattern decision tree

```
How do modules need to communicate?
  ├── No communication needed
  │     → Tab 1: Basic module (each module is self-contained)
  │
  ├── One module produces data, another consumes it
  │     → Tab 2: Return a reactive from the producer
  │
  ├── Multiple modules share the same state
  │     ├── Simple key-value state (filters, selections)
  │     │     → Tab 3: reactiveValues passed from parent
  │     └── Complex state with business logic / validation
  │           → Tab 4: R6 class with reactiveVal bridge
  │
  ├── One module contains other modules (composition)
  │     → Tab 5: Nested modules with ns()/session$ns()
  │
  └── Number of modules is dynamic (user adds/removes)
        → Tab 6: Dynamic modules with insertUI/removeUI + counter
```

### Universal module rules

1. **Every input/output ID** in a module UI must be wrapped with `ns()`
2. **`moduleServer()` id** must match the id passed to the UI function
3. **Data flows in via arguments** — modules never access global objects directly
4. **Validate arguments** before entering the reactive graph (`is.data.frame()`, `is.reactive()`, `is.reactivevalues()`)
5. **Keep server.R thin** — it wires modules together; logic lives inside the modules
6. **Returning values from `moduleServer()`** is how modules communicate outward
7. **`session$ns()`** in server builds a namespaced id (the server-side equivalent of `ns()`) — use it for dynamically inserted UI and JS/custom-message targets. Do **NOT** use it for nested module **server** calls: pass the SHORT id (e.g. `mod_inner_server("header")`). `moduleServer()` auto-nests, so `session$ns()` would double-namespace.
