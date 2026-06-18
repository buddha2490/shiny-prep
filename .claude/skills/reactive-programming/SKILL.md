---
name: reactive-programming
description: Auto-invoked when working with reactive primitives in Shiny applications. Governs reactive(), reactiveVal(), reactiveValues(), observe(), observeEvent(), isolate(), req(), debounce(), throttle(), and bindEvent() — with the reactive graph mental model and common invalidation bugs.
---

# Reactive Programming in Shiny

## Primitive Selection — Decision Table

| Need | Use |
|------|-----|
| Compute a **value** that other things depend on | `reactive()` |
| Compute a **value** only when a specific event fires | `eventReactive()` / `reactive() + bindEvent()` |
| Store a **single mutable value** | `reactiveVal()` |
| Store **multiple named mutable values** | `reactiveValues()` |
| Run **side effects** whenever dependencies change | `observe()` |
| Run **side effects** only when a specific event fires | `observeEvent()` |
| Read a reactive **without taking a dependency** | `isolate()` |
| Guard against NULL / uninitialized inputs | `req()` |
| Limit how often a reactive fires | `debounce()` / `throttle()` |

---

## `reactive()` — Computed values

```r
# Creates a lazy, cached, dependency-tracking expression.
# Re-executes only when its dependencies change.
filtered_data <- reactive({
  req(input$group)
  raw_data() %>% filter(group == input$group)
})

# Downstream consumers call it with ()
output$table <- renderTable({ filtered_data() })
```

**Rules:**
- Never put side effects (writing files, DB updates) inside `reactive()`.
- Always call with `()` — the reactive is a function until evaluated.
- Cached between flushes — multiple callers pay the cost once.

---

## `reactiveVal()` — Single mutable value

```r
# Create with an optional default
counter <- reactiveVal(0L)

# Read
counter()

# Write (call with a new value)
observeEvent(input$increment, {
  counter(counter() + 1L)
})

output$count <- renderText({ counter() })
```

**Rules:**
- Read: `val()`. Write: `val(new_value)`. There is no `$` accessor.
- Prefer `reactiveVal()` over `reactiveValues()` for a single scalar.

---

## `reactiveValues()` — Named mutable state

```r
state <- reactiveValues(
  selected_id = NULL,
  page        = 1L,
  filters     = list()
)

# Read — reactive dependency registered automatically
output$detail <- renderTable({
  req(state$selected_id)
  data %>% filter(id == state$selected_id)
})

# Write inside an observer
observeEvent(input$select, {
  state$selected_id <- input$subject_id
  state$page        <- 1L
})
```

**Rules:**
- Accessing `state$x` registers a reactive dependency on that slot only.
- Writing `state$x <- value` invalidates only dependents of that slot.
- Prefer R6 over `reactiveValues()` for shared state across modules — R6 is testable without Shiny.

---

## `observe()` vs `observeEvent()`

```r
# observe() — runs whenever ANY dependency inside changes
observe({
  message("Input changed: ", input$choice)
})

# observeEvent() — runs ONLY when the specified event fires
# Ignores other reactive reads inside the handler body
observeEvent(input$submit, {
  save_to_db(input$name, input$value)
})

# Multiple triggers
observeEvent(list(input$save, input$export), {
  do_something()
})
```

**Rules:**
- `observe()` for reactive side effects tied to data flow.
- `observeEvent()` for user-initiated actions (button clicks, selections).
- Neither returns a value — use `reactive()` / `eventReactive()` when a value is needed.
- `ignoreNULL = TRUE` (default) — handler does not fire if the event value is NULL.
- `ignoreInit = TRUE` — skip the first execution on app load (useful for buttons).

---

## `isolate()` — Read without dependency

```r
# Without isolate: output re-renders on EVERY input change
output$plot <- renderPlot({
  data <- filtered_data()          # dependency: re-renders when filtered_data() changes
  title <- input$title             # dependency: also re-renders when title changes
  plot(data, main = title)
})

# With isolate: only filtered_data() triggers re-render
output$plot <- renderPlot({
  data  <- filtered_data()
  title <- isolate(input$title)    # read title without registering dependency
  plot(data, main = title)
})
```

**Rules:**
- `isolate()` is the escape hatch — use it deliberately, not reflexively.
- Common use: reading a label, title, or configuration value that should not re-trigger computation.
- Common use: reading `reactiveVal` inside an `observe()` to avoid circular dependencies.

---

## `bindEvent()` — Explicit event binding (Shiny 1.6+)

`bindEvent()` replaces `eventReactive()` and is the preferred modern form.

```r
# eventReactive() — legacy
result <- eventReactive(input$go, {
  compute(input$params)
})

# bindEvent() — preferred (Shiny 1.6+)
result <- reactive({
  compute(input$params)
}) %>% bindEvent(input$go)

# Works with observe() too — replaces observeEvent()
observe({
  save_record(input$name)
}) %>% bindEvent(input$save)
```

**Rules:**
- `bindEvent()` is composable — chain it after `reactive()` or `observe()`.
- `ignoreNULL` and `ignoreInit` arguments work the same as in `observeEvent()`.
- Prefer `bindEvent()` for new code; `eventReactive()` / `observeEvent()` are still valid.

---

## `req()` — Guard against NULL and invalid inputs

```r
output$table <- renderTable({
  req(input$choice)          # stops silently if NULL, NA, FALSE, or ""
  req(nrow(data()) > 0)      # stops silently if condition is FALSE
  req(data())                # stops silently if reactive returns NULL
  data() %>% filter(group == input$choice)
})
```

**Rules:**
- `req()` short-circuits with a silent "silent error" — no red error message shown.
- Use `validate(need(..., message))` when you want to show the user an explanatory message.
- Place `req()` calls at the **top** of `reactive()`, `render*()`, and `observe()` blocks.
- Multiple `req()` calls on separate lines — one condition per call.

```r
# Show a user-facing message instead of blank output
output$plot <- renderPlot({
  validate(
    need(input$group != "", "Select a group to display the plot."),
    need(nrow(data()) > 0,  "No data available for this selection.")
  )
  plot(data())
})
```

---

## `debounce()` / `throttle()` — Limit reactive frequency

```r
# debounce: wait until input is stable for N ms before firing
search_input <- reactive({ input$search }) %>% debounce(500)

# throttle: fire at most once per N ms, ignoring intermediates
scroll_pos <- reactive({ input$scroll_y }) %>% throttle(200)

# Use the debounced/throttled reactive downstream
output$results <- renderTable({
  req(search_input())
  search_data(search_input())
})
```

**Rules:**
- `debounce()` — best for text input that triggers expensive queries.
- `throttle()` — best for continuous signals (scroll position, slider drag).
- Both return a reactive — call with `()` downstream.
- Millisecond values: 300–500 ms for search inputs; 100–200 ms for continuous signals.

---

## Reactive Graph Mental Model

```
input$x  ──►  reactive_a()  ──►  reactive_b()  ──►  output$plot
                    │
              input$y  (also a dependency)
```

**Invalidation:** When `input$x` changes, `reactive_a()` is marked invalid. This cascades — `reactive_b()` and `output$plot` are also invalidated.

**Flushing:** Shiny processes one flush cycle per user event. After all invalidations are marked, Shiny re-executes only what is needed, in dependency order.

**Key implications:**
- A reactive is re-executed **at most once per flush**, even if multiple dependencies change simultaneously.
- Reactives are **lazy** — they only execute when a consumer reads them.
- `observe()` / `observeEvent()` are **eager** — they execute as soon as their trigger fires in the flush cycle.
- Circular dependencies (`a()` depends on `b()` depends on `a()`) throw an error — design the graph as a DAG.

**Visualize the graph:**
```r
# In development — open the reactive log viewer
options(shiny.reactlog = TRUE)
# Run the app, interact, then:
shiny::reactlogShow()
```

---

## Common Errors and Fixes

### "Operation not allowed without an active reactive context"

**Cause:** Calling a reactive (e.g., `data()`) outside `reactive()`, `render*()`, or `observe*()`.

```r
# WRONG — top-level call outside reactive context
server <- function(input, output, session) {
  df <- filtered_data()    # Error
}

# CORRECT — inside a reactive context
server <- function(input, output, session) {
  output$table <- renderTable({ filtered_data() })
}
```

### Reactive fires too often / unexpected re-renders

**Cause:** Reading an input or reactive inside a context that should not depend on it.

**Fix:** Wrap the read in `isolate()`, or restructure to `observeEvent()` / `bindEvent()`.

### `observe()` creates infinite loop

**Cause:** The observer writes to a `reactiveVal` or `reactiveValues` slot that it also reads.

```r
# WRONG — reads and writes counter(), causing a loop
observe({
  counter(counter() + 1L)
})

# CORRECT — trigger only from an event
observeEvent(input$btn, {
  counter(counter() + 1L)
})
```

### `eventReactive` / `bindEvent` fires on app start

**Cause:** `ignoreInit` defaults to `FALSE`, so the handler runs once immediately.

```r
result <- reactive({ compute(input$params) }) %>%
  bindEvent(input$go, ignoreInit = TRUE)
```

### Blank output with no error

**Cause:** `req()` failing silently — an upstream reactive returns NULL or FALSE.

**Fix:** Temporarily add `message("data: ", class(data()))` at the top of the render function to inspect what arrives.

---

## Reactive Primitive Checklist

Before finishing a reactive block, verify:

- [ ] `reactive()` — no side effects inside (use `observe()` for those)
- [ ] `reactiveVal` / `reactiveValues` — written inside `observe*()`, not inside `reactive()`
- [ ] `observeEvent()` — `ignoreNULL` and `ignoreInit` set intentionally
- [ ] `isolate()` used only where a dependency is explicitly not wanted
- [ ] `req()` guards every render and reactive that depends on nullable inputs
- [ ] Text inputs driving expensive queries are wrapped in `debounce()`
- [ ] No reactive called at the top level of `server()` or `moduleServer()`
- [ ] Reactive graph is a DAG — no circular dependencies
