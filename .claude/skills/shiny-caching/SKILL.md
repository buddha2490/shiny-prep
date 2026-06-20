---
name: shiny-caching
description: Auto-invoked when caching expensive work in a Shiny app — storing results so they are not recomputed for inputs already seen. Governs bindCache() for reactives and render outputs (with cache-scope correctness), cachem backends (memory/disk/layered), and memoise() for pure functions and data loading. Use after shiny-profiling shows a reactive recomputing with unchanged inputs.
---

# Shiny Caching Strategy

This skill is Phase 3 of the `shiny-performance` workflow: once `shiny-profiling`
shows a reactive or output recomputing the same work for inputs already seen,
cache it. **Verify the reactive graph is correct first** (see the reactive-graph
optimization in `shiny-performance`) — caching a wrongly-wired reactive just
caches the wrong thing.

| Tool | Caches | Lives in the reactive graph? |
|------|--------|------------------------------|
| `bindCache()` | `reactive()` and `render*()` results | Yes — auto-invalidates on key change |
| `cachem` | The backend store behind `bindCache` / `memoise` | n/a (storage layer) |
| `memoise()` | Pure R function calls | No — works outside Shiny |

---

## bindCache() — Cache reactive expressions and render outputs

`bindCache()` stores the result of a reactive or render function keyed on one or
more reactive expressions. When the key combination has been seen before, the
cached value is returned immediately — no re-computation.

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
- App-level cache with user-specific data (privacy/security risk — in pharma, PHI)
- Computation is <10ms — caching overhead exceeds the benefit

---

## Custom cache backends with cachem

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

## memoise() — Function-level memoization

Use `memoise` for pure R functions called in reactive contexts. Unlike
`bindCache`, `memoise` works outside Shiny's reactive system and persists across
sessions when stored in `global.R`.

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
