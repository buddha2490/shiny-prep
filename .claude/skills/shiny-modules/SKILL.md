---
name: shiny-modules
description: Auto-invoked when creating or modifying Shiny modules. Governs the NS/moduleServer pattern, namespace rules, reactivity contracts, and inter-module communication to prevent common errors.
---

# Shiny Modules Skill

## Canonical Module Template

Every module is two functions. Copy this exactly:

```r
# R/mod_example.R

# --- UI ----------------------------------------------------------------------
mod_example_ui <- function(id) {
  ns <- NS(id)                     # create namespace function
  tagList(
    selectInput(ns("choice"), "Pick one:", choices = c("A", "B")),
    tableOutput(ns("result"))
  )
}

# --- Server ------------------------------------------------------------------
mod_example_server <- function(id, data) {   # extra args after id for inputs
  moduleServer(id, function(input, output, session) {
    ns <- session$ns                 # needed for dynamic UI only

    output$result <- renderTable({
      req(input$choice)
      data() %>% filter(group == input$choice)
    })
  })
}
```

Wire in app server:

```r
server <- function(input, output, session) {
  mod_example_server("example", data = some_reactive)
}
```

---

## Namespace Rules

### In the UI function — wrap every input/output ID with `ns()`

```r
mod_example_ui <- function(id) {
  ns <- NS(id)

  tagList(
    # CORRECT — all IDs namespaced
    textInput(ns("name"), "Name"),
    actionButton(ns("submit"), "Submit"),
    plotOutput(ns("plot")),
    uiOutput(ns("dynamic_panel"))
  )
}
```

**Everything that produces an HTML `id` attribute must go through `ns()`.**
This includes: all `*Input()`, all `*Output()`, `uiOutput()`, `htmlOutput()`.

### In the server function — do NOT wrap input/output with ns()

Inside `moduleServer()`, `input`, `output`, and `session` are already scoped to the module. Access them directly:

```r
mod_example_server <- function(id) {
  moduleServer(id, function(input, output, session) {

    # CORRECT — no ns() wrapping
    output$plot <- renderPlot({ ... })
    val <- input$choice

    # WRONG — double-namespacing breaks the binding
    # output[[ns("plot")]] <- renderPlot({ ... })
  })
}
```

### When `ns <- session$ns` IS needed in the server

Only use `session$ns` when generating UI dynamically inside `renderUI()` or `insertUI()`:

```r
mod_example_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns   # needed here because renderUI runs in server scope

    output$dynamic_panel <- renderUI({
      selectInput(ns("sub_choice"), "Sub:", choices = 1:3)
    })

    # Now input$sub_choice works because it was namespaced with session$ns
    output$result <- renderTable({
      req(input$sub_choice)
      data[input$sub_choice, ]
    })
  })
}
```

### Namespace quick reference

| Location | Use `ns()`? | How |
|----------|-------------|-----|
| UI function body | Yes — always | `ns <- NS(id)` at top, wrap every ID |
| Server `output$x <-` | No | Direct — `output$plot <- renderPlot(...)` |
| Server `input$x` | No | Direct — `input$choice` |
| Server `renderUI()` body | Yes | `ns <- session$ns`, wrap IDs in rendered UI |
| Server `insertUI()` content | Yes | Use `session$ns` to wrap IDs |
| Observer `updateSelectInput(session, ...)` | No | `session` is already scoped |

---

## Reactivity Rules

### Pass reactives as functions, not values

```r
# CORRECT — pass the reactive itself (a function)
mod_plot_server("plot", data = filtered_data)

# Inside the module, call it with ()
mod_plot_server <- function(id, data) {
  moduleServer(id, function(input, output, session) {
    output$plot <- renderPlot({
      data()   # call the reactive here
    })
  })
}
```

```r
# WRONG — passing the evaluated value breaks reactivity
mod_plot_server("plot", data = filtered_data())   # drops reactivity
```

### Return a reactive, not a value

```r
mod_filter_server <- function(id, raw_data) {
  moduleServer(id, function(input, output, session) {

    filtered <- reactive({
      req(input$group)
      raw_data() %>% filter(group == input$group)
    })

    return(filtered)   # return the reactive, not filtered()
  })
}

# Caller receives and uses it
server <- function(input, output, session) {
  raw   <- mod_data_server("data")
  clean <- mod_filter_server("filter", raw_data = raw)
  mod_table_server("table", data = clean)   # clean is still a reactive
}
```

### `req()` — guard every reactive that can be NULL

Use `req()` at the top of any reactive or render that depends on user input or upstream reactives:

```r
output$table <- renderTable({
  req(input$choice)          # stops silently if NULL or ""
  req(data())                # stops silently if upstream is NULL
  data() %>% filter(...)
})
```

`req()` short-circuits silently — it does not throw an error. It is the correct way to handle uninitialized inputs.

### `reactive()` vs `eventReactive()` vs `observe()` vs `observeEvent()`

| Function | Use when |
|----------|----------|
| `reactive()` | Computing a value that other things depend on |
| `eventReactive(input$btn, ...)` | Computing a value only when a specific trigger fires |
| `observe()` | Side effects that run whenever dependencies change |
| `observeEvent(input$btn, ...)` | Side effects triggered by a specific event |

Never put side effects (writing files, updating DB, triggering downloads) inside `reactive()`. Use `observe()` or `observeEvent()`.

---

## Inter-Module Communication Patterns

### Pattern 1: Linear data flow (most common)

```r
server <- function(input, output, session) {
  imported  <- mod_import_server("import")
  filtered  <- mod_filter_server("filter",  data = imported)
  summarized <- mod_summary_server("summary", data = filtered)
  mod_plot_server("plot", data = filtered, stats = summarized)
}
```

Each module receives upstream reactives as arguments and returns a reactive downstream.

### Pattern 2: Shared mutable state with reactiveValues

Use when two modules need to write to and read from the same state (bidirectional):

```r
server <- function(input, output, session) {
  shared <- reactiveValues(
    selected_id  = NULL,
    current_tab  = "overview"
  )

  mod_selector_server("selector", shared = shared)   # writes shared$selected_id
  mod_detail_server("detail",     shared = shared)   # reads shared$selected_id
}
```

Inside a module that writes:

```r
mod_selector_server <- function(id, shared) {
  moduleServer(id, function(input, output, session) {
    observeEvent(input$select_btn, {
      shared$selected_id <- input$subject_id   # write to shared state
    })
  })
}
```

Inside a module that reads:

```r
mod_detail_server <- function(id, shared) {
  moduleServer(id, function(input, output, session) {
    output$detail <- renderTable({
      req(shared$selected_id)
      data %>% filter(id == shared$selected_id)   # reactive read
    })
  })
}
```

### Pattern 3: Passing a reactive list (multiple outputs from one module)

```r
mod_data_server <- function(id) {
  moduleServer(id, function(input, output, session) {

    raw   <- reactive({ load_data() })
    meta  <- reactive({ get_metadata() })

    list(
      data = raw,
      meta = meta
    )
  })
}

server <- function(input, output, session) {
  ds <- mod_data_server("data")
  mod_table_server("table", data = ds$data, meta = ds$meta)
}
```

---

## Common Errors and Fixes

### Error: Output not found / input not responding

**Cause:** Forgot `ns()` around an ID in the UI, or used `ns()` inside `output$x` in the server.

**Fix:** UI → always `ns()`. Server `output$x` / `input$x` → never `ns()`.

### Error: Object of type closure is not subsettable

**Cause:** Passing `data()` (the value) where a reactive is expected, then calling it again with `data()()`.

**Fix:** Pass `data` (the reactive function), not `data()` (the value).

### Error: Operation not allowed without an active reactive context

**Cause:** Calling a reactive (e.g., `data()`) outside of `reactive()`, `render*()`, or `observe*()`.

**Fix:** Always call reactives inside a reactive context. Never call them at the top level of `moduleServer`.

### Silent blank output (no error)

**Cause:** A `req()` is failing silently, or an upstream reactive returns NULL.

**Fix:** Add `message("data: ", nrow(data()))` inside the render function temporarily to check what arrives.

### Dynamic UI inputs not found

**Cause:** `renderUI()` created inputs without `ns()`, so Shiny cannot bind them to the namespaced server.

**Fix:** Use `ns <- session$ns` in the server, and wrap all IDs inside `renderUI()` with `ns()`.

---

## Module Checklist

Before finishing a module, verify:

- [ ] `ns <- NS(id)` is the first line of the UI function
- [ ] Every `*Input()` and `*Output()` call in UI uses `ns("id")`
- [ ] `moduleServer(id, function(input, output, session) {...})` wraps all server code
- [ ] Server accesses `input$x` and `output$x` directly (no `ns()`)
- [ ] `session$ns` is declared only when `renderUI()` / `insertUI()` need it
- [ ] All reactive arguments are passed as functions, not values
- [ ] Return value is a reactive (or list of reactives), not a value
- [ ] `req()` guards every render and reactive that depends on nullable inputs
- [ ] No side effects inside `reactive()` — use `observeEvent()` instead
