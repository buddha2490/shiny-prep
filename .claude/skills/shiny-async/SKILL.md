---
name: shiny-async
description: Auto-invoked when moving long-running, uncacheable work off the Shiny main thread so one slow computation does not block other users. Governs ExtendedTask (Shiny 1.8+, the preferred pattern) with bind_task_button(), and future_promise() for older apps. For the mirai backend specifically (workers, mirai_map, HPC), defer to the mirai skill; for capturing async errors, see shiny-error-handling.
---

# Shiny Async — Off-Thread Computation

This skill is Phase 5 of the `shiny-performance` workflow. Shiny is
**single-threaded**: one slow computation blocks every connected user. When a
computation takes more than ~1–2 seconds and cannot be cached (because the inputs
vary too much for `shiny-caching` to help), move it to a background process.

**Order of preference:** try the reactive-graph fix first (cheap), then caching
(`shiny-caching`), and reach for async only when the work is genuinely long and
input-varied. Async adds real complexity — worker setup, serialization, and error
handling that only surfaces when you read the result.

- For the **mirai** backend in depth (worker pools, `mirai_map`, cluster/HPC), use the `mirai` skill.
- For **capturing and logging** errors that occur in a worker, use `shiny-error-handling` (read `task$result()` inside `with_error_handling()` when `task$status() == "error"`).

---

## ExtendedTask (Shiny 1.8+ — preferred)

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
- The function passed to `$new()` must return a promise (wrap with `future::future()` or a mirai)
- `$invoke()` starts the task; `$result()` is a reactive that resolves when done
- Use `bslib::bind_task_button()` to disable the button while running
- One task runs at a time per `ExtendedTask` instance — queue multiple calls with separate instances
- A failed task surfaces its error only when you read `$result()` — wrap that read per `shiny-error-handling`

---

## future_promise() — For older apps

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
