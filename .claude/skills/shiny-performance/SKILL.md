---
name: shiny-performance
description: Auto-invoked when reviewing or optimizing Shiny application performance. The entry point for a perf review — governs the measure-first workflow, ROI ordering, reactive-graph optimization, data-layer performance (pool/dbplyr/arrow), UI-rendering and memory, plus the cross-cutting anti-pattern quick reference and review checklist. Defers the tool-heavy specializations to dedicated skills: shiny-profiling (profvis/reactlog/tictoc/loadtest), shiny-caching (bindCache/memoise/cachem), shiny-async (ExtendedTask/future).
---

# Shiny Performance & Optimization

This skill is the **entry point** for a performance review: the workflow, the
order to fix things in, the reactive-graph and data-layer guidance, and the
cross-cutting anti-pattern reference and checklist used to scan code. The
tool-heavy phases live in focused sibling skills so they only load when needed:

| Deep-dive | Skill | Covers |
|-----------|-------|--------|
| **Measure first** | `shiny-profiling` | profvis, reactlog, shiny.tictoc, shinyloadtest |
| **Cache results** | `shiny-caching` | bindCache, cachem backends, memoise |
| **Off-thread work** | `shiny-async` | ExtendedTask, future_promise (+ the `mirai` skill) |

---

## The Performance Review Workflow

Always follow this sequence. Do not optimize without measuring.

```
1. READ the code — understand the reactive graph structure
2. DIAGNOSE — identify which category of problem is present (use shiny-profiling)
3. PRIORITIZE — fix in ROI order (reactive graph > caching > data layer > async)
4. MEASURE AGAIN — confirm the fix actually helped
```

**ROI order for fixes:**

| Priority | Category | Typical Gain | Where |
|----------|----------|-------------|-------|
| 1 | Reactive graph — over-invalidation, unnecessary re-renders | High | This skill |
| 2 | Caching — expensive reactives re-computed with same inputs | High | `shiny-caching` |
| 3 | Data layer — loading too much data, wrong data format | Medium | This skill |
| 4 | Async — blocking the R process for long computations | Medium | `shiny-async` |
| 5 | UI rendering — large tables without pagination, excessive outputs | Low-Medium | This skill |

---

## Reactive Graph Optimization

This is almost always the highest-ROI fix. Before adding caching, verify the
reactive graph is correct. (Diagnose over-invalidation with `reactlog` — see
`shiny-profiling`.)

### Anti-pattern: reading inputs directly in outputs

```r
# SLOW — output re-renders whenever input$group OR input$title changes
output$plot <- renderPlot({
  data %>%
    filter(group == input$group) %>%
    ggplot(aes(x = visit, y = value)) +
    geom_boxplot() +
    labs(title = input$title)   # This causes a re-render just for a title change
})
```

```r
# CORRECT — separate concerns; plot only re-renders when filtered data changes
filtered_data <- reactive({
  req(input$group)
  data %>% filter(group == input$group)
})

output$plot <- renderPlot({
  ggplot(filtered_data(), aes(x = visit, y = value)) +
    geom_boxplot() +
    labs(title = isolate(input$title))   # read title without dependency
})
```

### Anti-pattern: one input invalidating everything

```r
# SLOW — every downstream reactive re-runs when ANY of these inputs change
output$table <- renderTable({
  data %>%
    filter(group == input$group,
           visit == input$visit,
           param == input$param)
})

output$plot <- renderPlot({
  data %>%
    filter(group == input$group,   # duplicate filtering — done twice
           visit == input$visit,
           param == input$param) %>%
    ggplot(...)
})
```

```r
# CORRECT — single reactive, computed once, shared by all consumers
filtered_data <- reactive({
  req(input$group, input$visit, input$param)
  data %>%
    filter(group == input$group,
           visit == input$visit,
           param == input$param)
})

output$table <- renderTable({ filtered_data() })
output$plot  <- renderPlot({ ggplot(filtered_data(), aes(x = visit, y = value)) + geom_point() })
```

### Anti-pattern: observe() with unintended reactive reads

```r
# WRONG — fires whenever input$group OR df() changes, even if only df() is needed
observe({
  df <- df()
  message("Rows: ", nrow(df), " Group: ", input$group)   # input$group is an unintended dep
})
```

```r
# CORRECT — only fire on df() changes; read input$group without dependency
observe({
  df <- df()
  message("Rows: ", nrow(df), " Group: ", isolate(input$group))
})
```

### debounce() for text inputs driving expensive queries

```r
# Without debounce: fires on every keystroke
output$results <- renderTable({
  req(input$search)
  search_database(input$search)   # called on every keystroke — very slow
})
```

```r
# With debounce: waits until typing stops for 400ms
search_debounced <- reactive({ input$search }) %>% debounce(400)

output$results <- renderTable({
  req(search_debounced())
  search_database(search_debounced())
})
```

> For the full reactive-primitive mental model (`reactive` vs `observe` vs
> `eventReactive`, invalidation, `isolate`), see the `reactive-programming` skill.

---

## Data Layer Performance

### pool — Database connection management

Never create a database connection inside `server()`. Each user session would
open a new connection, exhausting the database connection limit. Use `pool` in
`global.R`.

```r
# global.R — one pool shared across all sessions
pool <- pool::dbPool(
  drv      = RPostgres::Postgres(),
  dbname   = Sys.getenv("DB_NAME"),
  host     = Sys.getenv("DB_HOST"),
  user     = Sys.getenv("DB_USER"),
  password = Sys.getenv("DB_PASSWORD"),
  minSize  = 2,   # always keep 2 connections warm
  maxSize  = 10   # never exceed 10 connections
)

# Close pool when app stops
shiny::onStop(function() pool::poolClose(pool))
```

```r
# server.R — query using pool like a regular DBI connection
filtered <- reactive({
  req(input$category)
  pool %>%
    dplyr::tbl("app_data") %>%                    # lazy — no data fetched yet
    dplyr::filter(category == input$category) %>% # pushed to DB
    dplyr::collect()                               # fetch only the filtered rows
})
```

**Transactions require explicit checkout:**

```r
observeEvent(input$save, {
  conn <- pool::poolCheckout(pool)
  on.exit(pool::poolReturn(conn))   # always return the connection
  DBI::dbWithTransaction(conn, {
    DBI::dbExecute(conn, "INSERT INTO audit_log ...", ...)
    DBI::dbExecute(conn, "UPDATE record ...", ...)
  })
})
```

### dbplyr — Push filtering to the database

Never `collect()` a full table and then filter in R. Always filter before collecting.

```r
# WRONG — pulls entire table into R memory, then filters
all_data <- tbl(pool, "records") %>% collect()
filtered  <- all_data %>% filter(category == input$category)   # filter in R
```

```r
# CORRECT — filter executes in the database, only matching rows transferred
filtered <- tbl(pool, "records") %>%
  filter(category == input$category,
         type %in% input$types,
         date >= input$date_min) %>%
  select(id, category, type, value, date) %>%   # only needed columns
  collect()
```

```r
# Use show_query() before collect() to verify the query
tbl(pool, "records") %>%
  filter(category == input$category) %>%
  show_query()   # prints the SQL — verify indexes are being used
```

### arrow / Parquet — Fast file-based data

Parquet is 5-20x faster than CSV and 2-5x faster than RDS for large datasets.

```r
# global.R — read only needed columns at startup
app_data <- arrow::read_parquet(
  "data/app_data.parquet",
  col_select = c("id", "category", "type", "value", "date", "flag")
)

# Or use Arrow's lazy evaluation for very large files (>500MB)
data_ds <- arrow::open_dataset("data/app_data/")   # partitioned parquet directory

# Query lazily — predicate pushdown avoids reading the full file
filtered <- data_ds %>%
  dplyr::filter(category == "A", type == "primary") %>%
  dplyr::collect()
```

**File format decision table:**

| Format | Read speed | File size | Use when |
|--------|-----------|-----------|----------|
| CSV | Slow | Large | Never for production apps |
| RDS | Medium | Medium | Small datasets, R-only |
| Parquet | Fast | Small | Default for large app data |
| Feather/Arrow IPC | Fastest | Medium | In-memory transfer between processes |

---

## UI & Rendering Optimization

### Large tables — always use server-side processing

```r
# WRONG — sends all rows to the browser as JSON; browser freezes for >5k rows
output$table <- DT::renderDT({
  large_dataset    # 50,000 rows
}, server = FALSE)

# CORRECT — only sends the current page; browser stays fast
output$table <- DT::renderDT({
  large_dataset
}, server = TRUE)   # default — explicit for clarity
```

### renderPlot — set explicit dimensions

```r
# Triggers an extra render on load when height = "auto"
output$plot <- renderPlot({ ... }, height = "auto")   # avoid

# Explicit dimensions prevent double-render
output$plot <- renderPlot({ ... })
# In UI: plotOutput("plot", height = "400px")
```

### shinycssloaders / waiter — perceived performance

Any output that takes >300ms should show a loading indicator. Perceived
performance matters as much as actual performance.

```r
# Wrap outputs in UI — zero server changes needed
library(shinycssloaders)

# Spinner wraps output automatically
withSpinner(plotOutput("slow_plot"), type = 4)
withSpinner(DTOutput("large_table"), color = "#0dc5c1")
```

```r
# waiter — for full-page or app-startup loading screens
library(waiter)

ui <- fluidPage(
  useWaiter(),
  ...
)

server <- function(input, output, session) {
  w <- Waiter$new(html = spin_fading_circles())

  observeEvent(input$run, {
    w$show()
    on.exit(w$hide())
    # ... long computation
  })
}
```

---

## Memory Management

Large R objects held in `global.R` or `reactiveValues` grow the process memory
and trigger garbage collection pauses.

```r
# Inspect object sizes during development
lobstr::obj_size(app_data)                    # accurate size including shared references
pryr::object_size(app_data)                   # similar, different algorithm

# In global.R — only keep columns the app needs
app_data <- arrow::read_parquet("data/app_data.parquet") %>%
  select(id, category, type, value, date, flag)
```

**Memory anti-patterns:**
- Storing the full dataset inside `reactiveValues` when it could stay in `global.R`
- Reading files with all columns when only a subset is used
- Accumulating history in an `observe()` that appends to a `reactiveVal` without a size limit

---

## Anti-Pattern Quick Reference

Scan code for these patterns during a performance review. The "Fix" column points
to where the remedy is detailed.

| Anti-pattern | Symptom | Fix |
|---|---|---|
| Input read directly in `render*()` | Re-renders on every change of that input | Extract to `reactive()` (this skill) |
| Duplicate filtering in multiple outputs | Same `filter()` code in multiple `render*()` | Single shared `reactive()` (this skill) |
| `collect()` before `filter()` | Full table loaded into R | Reverse: filter then collect (this skill) |
| `dbGetQuery` inside `reactive()` with no cache | DB hit on every interaction | `memoise()`/`bindCache()` (`shiny-caching`) |
| Reactive recomputes with unchanged inputs | Same work repeated | `bindCache()` (`shiny-caching`) |
| `server = FALSE` on DT with large data | Browser hangs | `server = TRUE` (this skill) |
| Text input → expensive computation, no debounce | Fires on every keystroke | `debounce(400)` (this skill) |
| DB connection created in `server()` | New connection per session | `pool::dbPool()` in `global.R` (this skill) |
| Long computation blocking the session | Other users wait | `ExtendedTask` (`shiny-async`) |
| `observe()` instead of `observeEvent()` | Observer fires unexpectedly | `observeEvent()`/`bindEvent()` (this skill) |
| No loading indicator on slow outputs | App feels broken | `withSpinner()` or `waiter` (this skill) |
| Heavy data prep inside `reactive()` | Repeated per user-interaction | Move to `global.R` or `memoise` (`shiny-caching`) |
| `options(shiny.reactlog = TRUE)` left on in production | Memory overhead | Remove before deployment (`shiny-profiling`) |

---

## Performance Review Checklist

When asked to review or optimize performance, work through this list in order.
The deep-dive skill for each section is noted in parentheses.

### Reactive graph (this skill)
- [ ] Are inputs read directly inside `render*()` without an intermediate `reactive()`?
- [ ] Is the same filtering/transformation duplicated across multiple outputs?
- [ ] Are `observe()` calls picking up unintended reactive reads? (use `observeEvent()` or `isolate()`)
- [ ] Are text inputs driving expensive operations wrapped in `debounce()`?
- [ ] Is `options(shiny.reactlog = TRUE)` set? (remove from production)

### Caching (`shiny-caching`)
- [ ] Are expensive reactives (>100ms) candidates for `bindCache()`?
- [ ] Are data-loading functions called in reactive contexts candidates for `memoise()`?
- [ ] Are cache keys correct — include everything that matters, exclude everything that doesn't?
- [ ] Is app-level cache used for any user-specific or sensitive data? (security risk — must be session-level)

### Data layer (this skill)
- [ ] Are DB queries issued from `server()` rather than a `pool` defined in `global.R`?
- [ ] Is `collect()` called before `filter()`? (reverse it)
- [ ] Are data files (CSV, Parquet, RDS) read with all columns when only a subset is needed?
- [ ] For files >10MB, has Parquet been considered over CSV/RDS?

### Async (`shiny-async`)
- [ ] Are there computations >1-2 seconds that cannot be cached?
- [ ] Is the app single-user or multi-user? (blocking matters more for multi-user)
- [ ] Has `ExtendedTask` been used for long-running server operations?

### UI rendering (this skill)
- [ ] Are large DT tables using `server = TRUE`?
- [ ] Are slow outputs (>300ms) wrapped in `withSpinner()` or a waiter?
- [ ] Are `renderPlot` outputs using `height = "auto"`? (causes double-render)

### Memory (this skill)
- [ ] Are large datasets trimmed to only needed columns in `global.R`?
- [ ] Are large objects stored in `reactiveValues` when they could live in `global.R`?
