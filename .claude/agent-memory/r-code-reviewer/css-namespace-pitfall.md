---
name: css-namespace-pitfall
description: CSS ID selectors targeting Shiny module outputs must use the fully-namespaced ID, not the bare local ID
type: pitfall
updated: 2026-06-19
---

CSS selectors in `www/custom.css` (or any static stylesheet) must use the **fully-namespaced** HTML element ID, not the bare local ID used in R code.

When R code writes `DT::DTOutput(ns("turn_table"))` inside a module with id `"advanced_ellmer"`, the rendered HTML element gets `id="advanced_ellmer-turn_table"`. A CSS rule `#turn_table .dataTable td` matches nothing.

**Pattern to enforce:** when reviewing CSS that targets module-rendered elements, grep for `ns("X")` in the R file and verify the CSS uses `#<module-id>-X`, not `#X`.

**Found in:** `examples/05. shinychat/www/custom.css` (fixed 2026-06-19):
- `#turn_table` → `#advanced_ellmer-turn_table`
- `#control_panel_sidebar` → `#control_panel-control_panel_sidebar`

**How to avoid:** add a comment in the CSS next to namespaced selectors citing the R source: `/* ns("turn_table") in mod_advanced_ellmer → "advanced_ellmer-turn_table" */`

See also: [[icon-package-conflicts]] for other UI-layer mismatches.
