---
name: shiny-profiling
description: Auto-invoked when measuring or diagnosing Shiny performance — finding WHERE an app is slow before changing anything. Governs profvis (R flame graphs), reactlog (reactive over-invalidation), shiny.tictoc (JS-side render timing), and shinyloadtest (multi-user load testing). Pairs with the shiny-performance review workflow; reach for shiny-caching / shiny-async once profiling has located the bottleneck.
---

# Shiny Profiling — Measure First

This skill covers the **measurement** half of a performance review: locating the
bottleneck before changing any code. It is Phase 1 of the `shiny-performance`
workflow — once profiling tells you *which* category of problem you have, fix it
with the reactive-graph guidance in `shiny-performance`, or the `shiny-caching` /
`shiny-async` skills.

**Never optimize without measuring.** A "slow" app is slow for exactly one of a
few reasons; profiling tells you which, so you don't spend effort on the wrong layer.

| Tool | Measures | Catches |
|------|----------|---------|
| `profvis` | R execution time | Slow R code, repeated computation |
| `reactlog` | Reactive invalidation | Over-rendering, unintended dependencies |
| `shiny.tictoc` | Browser render time | Slow JS payloads profvis can't see |
| `shinyloadtest` | Concurrent-user behavior | Shared-resource contention under load |

---

## profvis — R execution profiler

Use `profvis` to find slow R code. It produces a flame graph that shows time
spent per function call.

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

## reactlog — Reactive dependency graph visualizer

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
| A reactive invalidates but its value hasn't changed | No cache — same work done again | `bindCache()` (see `shiny-caching`) |
| Observer fires unexpectedly | `observe()` picks up unintended reactive reads | Switch to `observeEvent()` or add `isolate()` |

The fixes above are detailed in `shiny-performance` (reactive-graph optimization).

> Remove `options(shiny.reactlog = TRUE)` before deploying — it carries a memory
> overhead in production.

---

## shiny.tictoc — JS-side render timing

`shiny.tictoc` measures time from when Shiny sends a message to when the browser
finishes rendering. This catches slow JS rendering (large DT tables, complex
plotly charts) that `profvis` misses because profvis only measures R time.

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

## shinyloadtest — Multi-user load testing

Test how the app performs under concurrent users. Run this before deploying to
production.

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

**Interpret the report:** Look at `SESSION_DURATION` distribution. If p95 is much
higher than p50, some users are waiting on shared resources (DB connections,
in-memory data, single-threaded R). The usual remedies are a connection `pool`,
caching, or moving blocking work to `shiny-async`.
