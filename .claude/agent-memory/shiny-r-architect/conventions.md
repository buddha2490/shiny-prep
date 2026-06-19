---
name: confirmed-conventions
description: House conventions confirmed while building the reference apps — layout, pipe, naming, DT/bslib APIs
type: convention
updated: 2026-06-18
---

# Confirmed Conventions

- Three-file layout: `global.R` / `ui.R` / `server.R` — never `app.R`
- `%>%` pipe (tidyverse), `snake_case`, 2-space indent
- DT package: use `DTOutput()` + `renderDT()`, NOT `dataTableOutput()` +
  `renderDataTable()` — see [[dt-masking]] for why
- bslib layout vocabulary: `page_navbar`, `nav_panel`, `card`, `layout_columns`,
  `value_box`
- All `library()` calls in `global.R` only; all `source()` in `global.R` only

Related: [[module-patterns]]
