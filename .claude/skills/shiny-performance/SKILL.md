---
name: shiny-performance
description: Auto-invoked when reviewing, profiling, or optimizing Shiny application performance. Governs the measure-first workflow, profiling tools (profvis, reactlog, shiny.tictoc), reactive graph optimization, caching strategy (bindCache, memoise, cachem), data layer performance (pool, dbplyr, arrow), async for blocking work (ExtendedTask, future), and anti-pattern detection.
---

# Shiny Performance & Optimization

## The Performance Review Workflow

Always follow this sequence. Do not optimize without measuring.

```
1. READ the code — understand the reactive graph structure
2. DIAGNOSE — identify which category of problem is present
3. PRIORITIZE — fix in ROI order (reactive graph > caching > data layer > async)
4. MEASURE AGAIN — confirm the fix actually helped
```

**ROI order for fixes:**

| Priority | Category | Typical Gain |
|----------|----------|-------------|
| 1 | Reactive graph — over-invalidation, unnecessary re-renders | High |
| 2 | Caching — expensive reactives re-computed with same inputs | High |
| 3 | Data layer — loading too much data, wrong data format | Medium |
| 4 | Async — blocking the R process for long computations | Medium |
| 5 | UI rendering — large tables without pagination, excessive outputs | Low-Medium |

---

## Phase 1 — Profiling (Measure First)

### profvis — R execution profiler

Use `profvis` to find slow R code. It produces a flame graph that shows time spent per function call.

```r
# Profile a Shiny app interactively
library(profvis)
library(shiny)

profvis({
  runApp("path/to/app", port = 3838)
})
# Interact with the app for the slow scenario, then close the app.
# The flame graph appears automatically.
```

**Reading the flame graph:**
- **Wide bars** = slow (more time spent). These are the targets.
- **Tall stacks** = deep call chains. Look at the widest bar at any depth.
- **Repeated blocks** = the same function called many times — check if it should be cached.

```r
# Profile a specific function, not the full app
p <- profvis({
  for (i in 1:100) {
    expensive_function(data)
  }
})
print(p)
```

**What to look for in a Shiny profvis run:**
- `renderPlot`, `renderTable`, `renderUI` appearing very wide → cache or reduce computation
- Data loading functions (read_csv, dbGetQuery) inside reactive contexts → move to global.R or cache
- dplyr chains that show `collect()` → data is being pulled from DB in full, push filtering down

---

### reactlog — Reactive dependency graph visualizer

Use `reactlog` to find over-invalidation: outputs re-rendering when they should not be.

```r
# In global.R or at the start of a dev session
options(shiny.reactlog = TRUE)

# Run the app, perform the scenario that feels slow, then:
shiny::reactlogShow()
```

**Reading the reactlog:**
- Each node is a reactive (`reactive()`, `render*()`, `observe()`, input).
- Edges show dependencies — who reads whom.
- **Flashes of orange** = invalidation events. Count how many times a node flashes per user interaction.
- A node that flashes 5 times for one button click is invalidating too often.

**Diagnosis patterns:**

| What you see in reactlog | What it means | Fix |
|--------------------------|--------------|-----|
| Output re-renders on every keystroke | Input read directly in render without debounce | `debounce()` the input |
| Many reactives invalidate from one input | Input has too many direct dependents | Extract an intermediate `reactive()` so work is shared |
| A reactive invalidates but its value hasn't changed | No cache — same work done again | `bindCache()` |
| Observer fires unexpectedly | `observe()` picks up unintended reactive reads | Switch to `observeEvent()` or add `isolate()` |

---

### shiny.tictoc — JS-side render timing

`shiny.tictoc` measures time from when Shiny sends a message to when the browser finishes rendering. This catches slow JS rendering (large DT tables, complex plotly charts) that `profvis` misses because profvis only measures R time.

```r
# In global.R
library(shiny.tictoc)

# Wraps all outputs automatically — no code changes needed.
# Open browser console to see timing output:
# [tictoc] output$my_table: 842ms
```

**Use shiny.tictoc when:**
- profvis shows R is fast but the app still feels slow
- Outputs with large JS payloads (DT with 10k+ rows, plotly with dense data)

---

### shinyloadtest — Multi-user load testing

Test how the app performs under concurrent users. Run this before deploying to production.

```r
# Step 1: Record a session
library(shinyloadtest)
record_session("http://localhost:3838", output_file = "recording.log")
# Interact with the app normally, then close the browser.

# Step 2: Replay with N concurrent users
shinycannon("recording.log", "http://localhost:3838",
            workers = 10, loaded_duration_minutes = 2)

# Step 3: Analyze results
df <- load_runs(".")
shinyloadtest_report(df, "load_report.html")
```

**Interpret the report:** Look at `SESSION_DURATION` distribution. If p95 is much higher than p50, some users are waiting on shared resources (DB connections, in-memory data, single-threaded R).

---

## Phase 2 — Reactive Graph Optimization

This is almost always the highest-ROI fix. Before adding caching, verify the reactive graph is correct.

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

---

## Phase 3 — Caching Strategy

### bindCache() — Cache reactive expressions and render outputs

`bindCache()` stores the result of a reactive or render function keyed on one or more reactive expressions. When the key combination has been seen before, the cached value is returned immediately — no re-computation.

```r
# Cache a reactive() — app-level by default
filtered_data <- reactive({
  expensive_filter(data, input$group, input$param)
}) %>% bindCache(input$group, input$param)

# Cache a renderPlot — keyed on the data + plot settings
output$plot <- renderPlot({
  ggplot(filtered_data(), aes(x = visit, y = value)) +
    geom_boxplot()
}) %>% bindCache(filtered_data(), input$plot_type)
```

**Cache scope — critical for correctness:**

```r
# session scope (default for render*) — each user has their own cache
# Use for: user-specific data, personalized views
output$my_plot <- renderPlot({ ... }) %>%
  bindCache(input$group, cache = "session")

# app scope — cache shared across all users
# Use for: expensive computations with the same inputs for all users
# CAUTION: never use app-level cache for user-specific or sensitive data
output$shared_plot <- renderPlot({ ... }) %>%
  bindCache(input$group, cache = "app")
```

**Cache key design rules:**
- Include **every** reactive input that affects the output
- Include **nothing** that doesn't affect the output (adds unnecessary cache misses)
- If the output depends on `filtered_data()`, use `filtered_data()` as the key (not its component inputs)

```r
# WRONG key — misses inputs, returns stale data when param changes
output$table <- renderTable({ build_table(filtered_data()) }) %>%
  bindCache(input$group)   # forgot input$param

# CORRECT key — use the reactive that captures all dependencies
output$table <- renderTable({ build_table(filtered_data()) }) %>%
  bindCache(filtered_data())   # key is the full filtered result
```

**When to add bindCache():**
- Computation takes >100ms
- The same input combination is likely to be re-requested (user flips between tabs, revisits filters)
- The output is deterministic (same inputs → same output)

**When NOT to use bindCache():**
- Output depends on the current time, random numbers, or external state that changes
- App-level cache with user-specific data (privacy/security risk)
- Computation is <10ms — caching overhead exceeds the benefit

---

### Custom cache backends with cachem

```r
# In global.R — configure the cache backend once

# Memory cache with size limit (default is 512MB)
mem_cache <- cachem::cache_mem(max_size = 256 * 1024^2)  # 256MB

# Disk cache — survives app restarts
disk_cache <- cachem::cache_disk(dir = "cache/")

# Layered: check memory first (fast), fall back to disk (persistent)
layered_cache <- cachem::cache_layered(
  cachem::cache_mem(max_size = 128 * 1024^2),
  cachem::cache_disk(dir = "cache/")
)

# Pass to bindCache
output$plot <- renderPlot({ ... }) %>%
  bindCache(input$group, cache = layered_cache)
```

---

### memoise() — Function-level memoization

Use `memoise` for pure R functions called in reactive contexts. Unlike `bindCache`, `memoise` works outside Shiny's reactive system and persists across sessions when stored in `global.R`.

```r
# In global.R — memoized function shared across all sessions
load_study_data <- memoise::memoise(
  function(study_id) {
    # Expensive: reads from DB or disk
    DBI::dbGetQuery(con, glue::glue("SELECT * FROM data WHERE study = '{study_id}'"))
  },
  cache = memoise::cache_memory()   # default: in-memory
)

# Or with a disk cache for persistence across restarts
load_study_data <- memoise::memoise(
  function(study_id) { ... },
  cache = memoise::cache_filesystem("cache/study-data/")
)
```

```r
# In server.R — call the memoized function like any other function
filtered <- reactive({
  req(input$study)
  load_study_data(input$study) %>%   # returns cached result if seen before
    filter(PARAM == input$param)
})
```

**memoise vs bindCache:**

| | `memoise` | `bindCache` |
|--|-----------|-------------|
| Works outside Shiny | Yes | No |
| Integrates with reactive graph | No | Yes |
| Cache invalidation | Manual (`forget()`) | Automatic (reactive key changes) |
| Best for | Pure functions, data loading | reactive() and render*() |

---

## Phase 4 — Data Layer Performance

### pool — Database connection management

Never create a database connection inside `server()`. Each user session would open a new connection, exhausting the database connection limit. Use `pool` in `global.R`.

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

---

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

**Check the SQL being generated:**
```r
# Use show_query() before collect() to verify the query
tbl(pool, "records") %>%
  filter(category == input$category) %>%
  show_query()   # prints the SQL — verify indexes are being used
```

---

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

## Phase 5 — Async for Blocking Computations

When a computation takes >1-2 seconds and cannot be cached (because the inputs vary too much), use async to avoid blocking other users. Shiny is single-threaded — one slow computation blocks everyone.

### ExtendedTask (Shiny 1.8+ — preferred)

```r
# server.R
run_analysis <- ExtendedTask$new(function(data, params) {
  # This runs in a background process — does not block the Shiny session
  future::future({
    expensive_analysis(data, params)
  }, seed = TRUE)
}) %>% bslib::bind_task_button("run_btn")   # auto-manages button state

observeEvent(input$run_btn, {
  run_analysis$invoke(filtered_data(), list(alpha = input$alpha))
})

output$results <- renderTable({
  run_analysis$result()   # reactive — updates when the task completes
})
```

**ExtendedTask rules:**
- The function passed to `$new()` must return a promise (wrap with `future::future()`)
- `$invoke()` starts the task; `$result()` is a reactive that resolves when done
- Use `bslib::bind_task_button()` to disable the button while running
- One task runs at a time per `ExtendedTask` instance — queue multiple calls with separate instances

---

### future_promise() — For older apps

```r
# global.R
library(future)
library(promises)
plan(future.callr::callr, workers = 4)   # 4 background worker processes

# server.R
output$results <- renderTable({
  req(input$run)
  future_promise({
    expensive_analysis(isolate(input$params))
  }) %...>% (function(result) {
    result   # promise resolves to the table data
  })
})
```

**future vs ExtendedTask decision:**

| | `ExtendedTask` | `future_promise` |
|--|----------------|-----------------|
| Shiny version | 1.8+ | Any |
| Syntax | OOP, explicit invoke | Promise chain |
| Button integration | `bind_task_button()` | Manual |
| Preferred for new code | Yes | No (legacy) |

---

## Phase 6 — UI & Rendering Optimization

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

Any output that takes >300ms should show a loading indicator. Perceived performance matters as much as actual performance.

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

Large R objects held in `global.R` or `reactiveValues` grow the process memory and trigger garbage collection pauses.

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

Scan code for these patterns during a performance review:

| Anti-pattern | Symptom | Fix |
|---|---|---|
| Input read directly in `render*()` | Re-renders on every change of that input | Extract to `reactive()` |
| Duplicate filtering in multiple outputs | Same `filter()` code in multiple `render*()` | Single shared `reactive()` |
| `collect()` before `filter()` | Full table loaded into R | Reverse: filter then collect |
| `dbGetQuery` inside `reactive()` with no cache | DB hit on every interaction | `memoise()` or `bindCache()` |
| `server = FALSE` on DT with large data | Browser hangs | `server = TRUE` |
| Text input → expensive computation, no debounce | Fires on every keystroke | `debounce(400)` |
| DB connection created in `server()` | New connection per session | `pool::dbPool()` in `global.R` |
| Long computation blocking the session | Other users wait | `ExtendedTask` |
| `observe()` instead of `observeEvent()` | Observer fires unexpectedly | `observeEvent()` or `bindEvent()` |
| No loading indicator on slow outputs | App feels broken | `withSpinner()` or `waiter` |
| Heavy data prep inside `reactive()` | Repeated per user-interaction | Move to `global.R` or `memoise` |
| `options(shiny.reactlog = TRUE)` left on in production | Memory overhead | Remove before deployment |

---

## Performance Review Checklist

When asked to review or optimize performance, work through this list in order:

### Reactive graph
- [ ] Are inputs read directly inside `render*()` without an intermediate `reactive()`?
- [ ] Is the same filtering/transformation duplicated across multiple outputs?
- [ ] Are `observe()` calls picking up unintended reactive reads? (use `observeEvent()` or `isolate()`)
- [ ] Are text inputs driving expensive operations wrapped in `debounce()`?
- [ ] Is `options(shiny.reactlog = TRUE)` set? (remove from production)

### Caching
- [ ] Are expensive reactives (>100ms) candidates for `bindCache()`?
- [ ] Are data-loading functions called in reactive contexts candidates for `memoise()`?
- [ ] Are cache keys correct — include everything that matters, exclude everything that doesn't?
- [ ] Is app-level cache used for any user-specific or sensitive data? (security risk — must be session-level)

### Data layer
- [ ] Are DB queries issued from `server()` rather than a `pool` defined in `global.R`?
- [ ] Is `collect()` called before `filter()`? (reverse it)
- [ ] Are data files (CSV, Parquet, RDS) read with all columns when only a subset is needed?
- [ ] For files >10MB, has Parquet been considered over CSV/RDS?

### Async
- [ ] Are there computations >1-2 seconds that cannot be cached?
- [ ] Is the app single-user or multi-user? (blocking matters more for multi-user)
- [ ] Has `ExtendedTask` been used for long-running server operations?

### UI rendering
- [ ] Are large DT tables using `server = TRUE`?
- [ ] Are slow outputs (>300ms) wrapped in `withSpinner()` or a waiter?
- [ ] Are `renderPlot` outputs using `height = "auto"`? (causes double-render)

### Memory
- [ ] Are large datasets trimmed to only needed columns in `global.R`?
- [ ] Are large objects stored in `reactiveValues` when they could live in `global.R`?
