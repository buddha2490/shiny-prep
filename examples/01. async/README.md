# Async Patterns in Shiny

Seven progressive examples demonstrating every major approach to non-blocking async computation in R Shiny. Each example is a minimal, self-contained app that isolates one pattern.

## Examples

| # | Directory | Pattern | Key Packages | Blocking? |
|---|-----------|---------|-------------|-----------|
| 01 | `01_promises/` | Promise basics (`.then()` / `.catch()`) | promises | Yes (no background worker) |
| 02 | `02_future_promise/` | future + promises (core async pattern) | future, promises | No |
| 03 | `03_future_callr/` | future with callr backend | future, future.callr, promises | No |
| 04 | `04_callr/` | Direct `r_bg()` with polling | callr | No |
| 05 | `05_extended_task/` | Shiny 1.8+ `ExtendedTask` | future, promises (built-in) | No |
| 06 | `06_crew/` | Worker pool orchestration | crew | No |
| 07 | `07_mirai/` | Lightweight NNG-based async | mirai | No |

## How to Use

Start with `02_future_promise/` -- it is the most common production pattern. Then review `05_extended_task/` as the modern Shiny-native replacement.

Run any example:

```r
shiny::runApp("examples/async/01_promises")
```

## Decision Guide

```
Do you need async at all?
  No  --> skip all of this
  Yes --> Is the task user-triggered (button click)?
            Yes --> Use ExtendedTask (05) -- Shiny-native, cleanest API
            No  --> Is it a one-off background job?
                      Yes --> future_promise (02) or callr r_bg (04)
                      No  --> Do you need a managed worker pool?
                                Yes --> crew (06) or mirai (07)
                                No  --> future_promise (02)
```

## Note on File Structure

These examples use single-file `app.R` format for brevity. Production apps in this project use the three-file layout (`global.R`, `ui.R`, `server.R`) per project rules.
