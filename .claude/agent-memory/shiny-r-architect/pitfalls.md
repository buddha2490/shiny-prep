---
name: dt-masking
description: DT masks shiny's renderDataTable/dataTableOutput — always use DT's own DTOutput/renderDT
type: pitfall
updated: 2026-06-18
---

# DT / bslib Masking

When both `DT` and `shiny` are loaded, `DT` masks `dataTableOutput` and
`renderDataTable`. Calling the masked pair is ambiguous and a common source of
silent rendering bugs. Always use DT's own API: `DTOutput()` / `renderDT()`.

# value_box "bottom" showcase plot — "figure margins too large"

A `value_box(showcase = plotOutput("x", height = "100%"), showcase_layout =
"bottom")` can collapse the plot device to ~0 px on first render in a short,
non-full-screen box, which trips ggplot/base "figure margins too large" — a
RENDER error that only fires when the reactive executes (so the all-tabs smoke
gate catches it in stderr, not the console). Fix: give the `value_box()` a
`min_height` (e.g. `"200px"`) AND the showcase `plotOutput()` an explicit pixel
height (e.g. `"80px"`), not `"100%"`. Seen in `examples/07. layouts/bslib`.

Related: [[confirmed-conventions]]
