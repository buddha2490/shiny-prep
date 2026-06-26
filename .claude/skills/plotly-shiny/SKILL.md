---
name: plotly-shiny
description: Auto-invoked when creating or modifying interactive plotly charts in Shiny. Governs plotlyOutput/renderPlotly, scattergl for large data, plotlyProxy partial updates (restyle/relayout/addTraces/deleteTraces), event_data with source, ggplotly conversion and cleanup, and crosstalk linked views.
---

# Plotly in Shiny Skill

Interactive charts with `plotly` in a Shiny app. The worked reference for every
pattern below is `examples/02. plotly/` (5-tab app over a 10M-row GWAS dataset).
Open that app's module files when you need a full, runnable example.

## Canonical Shiny Pattern

```r
library(plotly)

# --- UI ----------------------------------------------------------------------
plotlyOutput(ns("my_plot"), height = "500px")

# --- Server ------------------------------------------------------------------
output$my_plot <- renderPlotly({
  req(plot_data())

  plot_ly(
    data   = plot_data(),
    x      = ~xvar, y = ~yvar,
    type   = "scattergl",          # WebGL — see performance table below
    mode   = "markers",
    text   = ~hover_text,          # custom HTML hover
    hoverinfo = "text",            # show ONLY `text`, not x/y/trace name
    source = ns("my_plot")         # required for event_data() — see Events
  ) %>%
    layout(hovermode = "closest") %>%
    config(displayModeBar = TRUE)
})
```

`plot_ly()` uses **formula notation** (`~col`) to reference data columns. Always
set `source = ns(id)` when the plot drives any click/select/zoom interaction.

---

## Performance: scattergl and the Point-Count Decision Tree

`type = "scattergl"` (WebGL, GPU-rendered) instead of `type = "scatter"` (SVG)
is the single most important large-data lever. SVG bogs down past ~10K points.

```
How many points?
  ├── <1K      → scatter (SVG) is fine; ggplotly if convenient
  ├── 1K-20K   → scatter (SVG) works; crosstalk linked views OK
  ├── 20K-100K → scattergl (WebGL); downsample if needed
  ├── 100K-1M  → scattergl + aggressive downsampling; plotlyProxy for updates
  └── >1M      → scattergl + semantic zoom (LOD) + binned aggregation
```

Downsampling rule for signal data (e.g. Manhattan plots): **keep every
significant point, randomly thin the rest.** Never blindly sample — you will
drop the peaks that matter.

Trade-offs to remember:
- `scattergl` does **not** support crosstalk linked brushing (use SVG `scatter`).
- `ggplotly()` always emits SVG traces — no WebGL. Keep ggplotly under ~50K points.

---

## plotlyProxy — Update Without Re-rendering

The most important production pattern. `renderPlotly()` destroys and rebuilds the
entire widget (and its WebGL context) on every reactive invalidation — the primary
source of lag in large plotly apps. `plotlyProxy()` sends only the diff.

```r
# Initial render happens ONCE
output$plot <- renderPlotly({ plot_ly(...) %>% layout(...) })

# Create the proxy once, reuse it in every observer
proxy <- plotlyProxy("plot", session)   # ns added automatically inside a module

# restyle — change TRACE properties (marker size/color/opacity)
observeEvent(input$size, {
  plotlyProxyInvoke(proxy, "restyle",
    list(`marker.size` = input$size),
    list(0))                            # trace indices — 0-BASED (plotly.js)
})

# relayout — change LAYOUT (axis ranges, titles, shapes, annotations)
observeEvent(input$zoom, {
  plotlyProxyInvoke(proxy, "relayout",
    list(`xaxis.range` = list(x_min, x_max)))
})

# addTraces / deleteTraces — add or remove whole series
plotlyProxyInvoke(proxy, "addTraces", list(x = ..., y = ..., type = "scattergl"))
plotlyProxyInvoke(proxy, "deleteTraces", list(idx))   # idx 0-based
```

| Change | Method | Notes |
|--------|--------|-------|
| marker size / color / opacity | `restyle` | trace indices are **0-based** |
| axis range / zoom | `relayout` | `` `xaxis.range` `` = `list(min, max)` |
| threshold lines (shapes) | `relayout` | pass full `shapes` list each time |
| interactive annotations | `relayout` | accumulate in a `reactiveVal(list())`, push all |
| add / remove a series | `addTraces` / `deleteTraces` | delete from highest index down |
| client-side toggle | `updatemenus` | rendered into the plot; **zero server round-trip** |

**Use a full re-render instead when** the underlying data changes entirely, or for
the first render (`renderPlotly()` is mandatory initially).

**Real-time animation** is the same pattern at speed: render the figure once, then
drive a self-re-arming `observe({ invalidateLater(delay); ... })` loop that pushes
only new `x`/`y` to the traces via one `restyle` per frame. This holds 100+ moving
points smooth where a `renderPlotly`-in-a-timer stutters (it rebuilds the WebGL
context every tick). Decouple physics from paint with a "steps per frame" knob.
Worked reference: `examples/09. annimation/` (random-walk escape).

**deleteTraces pitfall:** deleting shifts indices, so delete from the highest
index downward. Guard observers that delete on startup with `ignoreInit = TRUE` —
otherwise you call `deleteTraces` on an index that does not exist yet.

---

## Events — event_data() + source

Read user interaction inside a reactive context. The `source` string in
`event_data()` **must match** the `source` passed to `plot_ly()`.

```r
# plot_ly(source = ns("manhattan"))   <- in the renderPlotly
sel <- event_data("plotly_selected", source = ns("manhattan"))   # box/lasso
click <- event_data("plotly_click",  source = ns("manhattan"))   # single point
zoom <- event_data("plotly_relayout", source = ns("manhattan"))  # zoom / pan
```

| Event | Fires on | Returns |
|-------|----------|---------|
| `plotly_click` | single-point click | `x`, `y`, `curveNumber`, `pointNumber`, `customdata` |
| `plotly_selected` | box / lasso brush | data frame of selected points' `x`, `y`, `customdata` |
| `plotly_hover` / `plotly_unhover` | mouse over / out | same shape as click |
| `plotly_relayout` | zoom / pan / resize | `` `xaxis.range[0]` ``, `` `xaxis.range[1]` ``; `` `xaxis.autorange` `` = TRUE on reset |

Notes:
- Inside a module, use `session$ns(id)` for the `source` value, matching the plot.
- Read `plotly_relayout` fields with bracket strings: `ev[["xaxis.range[0]"]]`.
  On a reset / autorange it returns `` `xaxis.autorange` = TRUE `` instead of a range.
- Carry hidden per-point data through events with `customdata = ~col` (it never
  displays; it just rides along to the click/select event).
- `event_register(p, "plotly_...")` only needed for events not auto-registered;
  click/select/relayout register automatically once `event_data()` is called.

---

## ggplotly() Conversion and Cleanup

Build in ggplot2, convert with `ggplotly()`. Convenient for existing ggplot
workflows, facets, and static-export parity — but SVG-only and slower at scale.

```r
p <- ggplot(d, aes(x, y, text = paste0("Chr ", chr, "<br>p=", pval))) +
  geom_point() +
  theme_plotly_clean()              # match the house plotly style BEFORE convert

ggplotly(p, tooltip = "text") %>%   # tooltip = "text" → show only the custom aes
  layout(legend = list(title = list(text = "")))   # strip ggplotly's "<br>var"
```

Cleanup checklist:
1. Map a custom `text` aesthetic and pass `tooltip = "text"`, else ggplotly dumps
   **every** mapped aesthetic into the hover.
2. Fix the legend title — ggplotly renders it as `<br>variable`; reset with
   `layout(legend = list(title = list(text = "...")))`.
3. Skip hover on band/annotation traces with `style(hoverinfo = "skip", traces = N)`.
   `traces` is **1-based in R**. **Never** call `style(..., traces = NULL)` to mean
   "one trace" — `NULL` applies the attribute to **every** trace (see `?style`).
4. Trace order follows ggplot layer order; a discrete `color` aesthetic explodes
   into one trace per level, so a first `geom_ribbon` layer is trace 1.

`ggplotly` vs `plot_ly`: prefer `ggplotly` for existing ggplot code, facets, and
<50K points; prefer `plot_ly` for `scattergl`, fine trace control, proxy updates,
and >50K points.

---

## Linked Views — crosstalk

Client-side linked brushing across panels, no server round-trip.

```r
sd <- highlight_key(d, ~row_id)        # wrap data in a SharedData object

p1 <- plot_ly(sd, x = ~a, y = ~b, type = "scatter", mode = "markers")
p2 <- plot_ly(sd, x = ~c, y = ~d, type = "scatter", mode = "markers")

subplot(p1, p2, nrows = 1, shareX = FALSE, margin = 0.05) %>%
  highlight(
    on  = "plotly_selected",
    off = "plotly_deselect",
    persistent = TRUE,                 # FALSE = transient (hover) highlight
    opacityDim = 0.1,                  # opacity of NON-selected points
    selected = attrs_selected(marker = list(opacity = 1, size = 5))
  )
```

crosstalk limitations — important:
- Does **not** work with `scattergl`; must use `type = "scatter"` (SVG).
- Sends the full dataset to the browser — keep under ~20K points.
- No server-side filtering; brushing is purely client-side.
- Works only with plotly, DT, and leaflet.

---

## Reusable Helpers (examples/02. plotly/R/utils_plotly_theme.R)

Centralize styling so every plot is cohesive — edit one function to restyle all.

| Helper | Purpose |
|--------|---------|
| `apply_plotly_theme(p)` | House style (colors, fonts, margins, hover, mode bar) for any `plot_ly`/`ggplotly` object |
| `make_hline(y, ...)` | A horizontal line shape for `layout(shapes = ...)` |
| `make_hline_label(y, text)` | A text annotation for a threshold line |
| `empty_plot(message)` | Blank widget with a centered message — for empty states |
| `theme_plotly_clean()` | ggplot2 theme matching the plotly house style, used before `ggplotly()` |

---

## Common Pitfalls

- **0-based vs 1-based traces** — `plotlyProxyInvoke` / plotly.js use **0-based**
  indices; `style(traces = ...)` in R is **1-based**. Mixing them targets the
  wrong trace silently.
- **`source` mismatch** — `event_data()` returns `NULL` forever if its `source`
  string does not exactly match the plot's `source`. Inside a module use
  `session$ns(id)` for both.
- **`style(traces = NULL)`** — means "all traces", not "no trace". Guard it.
- **crosstalk + scattergl** — incompatible. Linked brushing needs SVG `scatter`.
- **deleteTraces on startup** — `observeEvent(..., ignoreInit = TRUE)` so the off
  branch does not delete a trace that does not exist yet.
- **Always guard empty data** — check `nrow(d) == 0` and return `empty_plot()`;
  plotly errors on some empty inputs.
- **`hoverinfo = "text"`** — required to suppress the default x/y/trace-name hover
  when you supply a custom `text` column.
- **Threshold lines move with the data** — set `xref = "paper"` on horizontal
  shapes/labels so they span the full width regardless of x-range.
- **`scaleanchor` + two fixed axis ranges → collapsed view** — to force a square
  aspect (`yaxis = list(scaleanchor = "x", scaleratio = 1)`) AND also pin both
  `xaxis$range` and `yaxis$range` with `fixedrange = TRUE` makes plotly zoom into
  a tiny sub-window — shapes and most traces fall off-screen while only a stray
  annotation shows (a total but silent failure). Pick ONE: either let
  `scaleanchor` derive a range (set the range on just one axis), or drop
  `scaleanchor` and honour explicit ranges proportioned to read roughly square.
  See `examples/09. annimation/R/plot_arena.R`.
```