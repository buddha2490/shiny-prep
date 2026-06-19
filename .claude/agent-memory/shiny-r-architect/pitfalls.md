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

Related: [[confirmed-conventions]]
