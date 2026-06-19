---
name: examples-built
description: Reference apps built in examples/ and their key architectural facts (packages, data, helpers)
type: codebase-fact
updated: 2026-06-18
---

# Examples Built

## `examples/02. plotly/` — Plotly Reference App
- 5-tab app demonstrating all major plotly patterns
- 10M-row GWAS dataset (`gwas_data.csv`), uses `scattergl` + downsampling
- Reusable theme helpers in `R/utils_plotly_theme.R`
- Key packages: shiny, bslib, data.table, plotly, ggplot2, viridisLite

## `examples/03. modules/` — Shiny Modules Reference App
- 6-tab bslib `page_navbar` app demonstrating all major module patterns
- Inline synthetic clinical data (adsl/adae/adlb, no CSV)
- See [[module-patterns]] for the per-pattern cheat sheet

Related: [[confirmed-conventions]]
