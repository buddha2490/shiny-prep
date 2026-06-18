# Shiny R Architect — Agent Memory

## Examples Built

### `examples/02. plotly/` — Plotly Reference App
- 5-tab app demonstrating all major plotly patterns
- 10M-row GWAS dataset (gwas_data.csv), uses scattergl + downsampling
- Reusable theme helpers in `R/utils_plotly_theme.R`
- Key packages: shiny, bslib, data.table, plotly, ggplot2, viridisLite

### `examples/03. modules/` — Shiny Modules Reference App
- 6-tab bslib page_navbar app demonstrating all major module patterns
- Inline synthetic clinical data (adsl/adae/adlb, no CSV)
- See `patterns.md` for module pattern cheat sheet

## Confirmed Conventions

- Three-file layout: global.R / ui.R / server.R — never app.R
- `%>%` pipe (tidyverse), snake_case, 2-space indent
- DT package: use `DTOutput()` + `renderDT()` NOT `dataTableOutput()` + `renderDataTable()`
  (the latter are shiny's, DT masks them — stick to DT's own API)
- bslib layout: `page_navbar`, `nav_panel`, `card`, `layout_columns`, `value_box`
- All `library()` in global.R only; all `source()` in global.R only

## Key Architecture Patterns

See `patterns.md` for detailed notes on each module pattern.

## DT / bslib Masking Note
When both `DT` and `shiny` are loaded, `DT` masks `dataTableOutput`/`renderDataTable`.
Always use `DTOutput()` / `renderDT()` to avoid ambiguity.
