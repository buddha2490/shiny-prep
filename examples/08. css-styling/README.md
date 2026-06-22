# Example 08 — CSS Styling Reference Showcase

A six-tab Shiny reference app, one tab per area of the project's **`css-styling`**
rule (`.claude/rules/css-styling.md`). The point is to show **every place styling
can live** — the theme, Bootstrap utilities, an external stylesheet, computed
inline styles, and namespaced module selectors — and which rule governs each.

> **Reference, not production.** There is no real task here. Each tab is a worked
> example you can copy from when you need custom styling on a real feature. For
> *layout* decisions (which bslib page type, cards vs. columns) see the
> `bslib-layout` skill; for *live* theme switching see `examples/07. layouts/bslib`.

## Run it

```bash
NOT_CRAN=true Rscript -e 'source("renv/activate.R"); shiny::runApp("examples/08. css-styling")'
```

No setup, no external services — the only data is 8 synthetic subjects generated
in-memory in `global.R` under a fixed seed, so every launch (and every test) is
identical.

## Where each rule is demonstrated

| Tab | Rule(s) | What it shows | File(s) |
|-----|---------|---------------|---------|
| **Theme** | 8 | App-wide colour/font/border-radius set once in `bs_theme()`; a rule needing a Sass variable (`$font-size-lg`) injected via `bs_add_rules()` | `global.R` (`APP_THEME`), `R/ui_gallery.R` |
| **Utility classes** | 3 | Bootstrap 5 utilities for spacing (`p-3`, `gap-2`), flexbox (`d-flex`, `justify-content-between`), text (`fs-5`, `text-muted`), colour (`bg-success`), borders (`rounded`, `shadow-sm`) — reach here *before* writing CSS | `R/ui_gallery.R` |
| **Custom components** | 1, 4, 5, 7 | The single external `www/custom.css`: summary cards, status badges, a keyframe animation, and the one documented `!important` — all keyed off `:root` `--app-*` custom properties | `www/custom.css`, `R/ui_gallery.R` |
| **Computed styles** | 2 | Data-driven inline styles a static file *can't* express: a percent-bar width and a grade-chip colour computed per row from the data, plus a live-slider conditional highlight | `R/utils_style_helpers.R`, `R/mod_computed_styles.R` |
| **Modules & namespacing** | 6 | CSS ID selectors must use the **fully-namespaced** id from the rendered HTML (`#metric_enrolled-value`), not the bare R id (`#value`) — shown with the same module instantiated twice | `R/mod_metric_panel.R`, `www/custom.css` |

## The eight rules, and how to read the example

1. **External file by default** — `ui.R` links `www/custom.css` with `tags$link()`
   in `header`; there is exactly one CSS file and no `includeCSS()`.
2. **When inline styles are acceptable** — the Computed-styles tab. `pct_bar()`
   and `grade_fill()` (`R/utils_style_helpers.R`) build the *only* values that
   depend on data (a width, a colour) inline; every reusable part of the
   treatment stays in a class.
3. **Bootstrap utilities before custom CSS** — the Utility-classes tab is a
   gallery of the common ones, each shown next to the class string that made it.
4. **Custom properties for palette** — `www/custom.css` defines `--app-*` on
   `:root`; every rule references them, so a palette change is one edit. Hex
   values appear *only* in `:root`.
5. **File structure + comments** — `www/custom.css` opens with a header block and
   is split into commented sections by purpose, including a responsive
   `@media` section.
6. **Namespace-aware selectors** — the Modules tab. `ns("value")` renders as
   `#metric_enrolled-value`; the CSS targets that, with a comment citing the R
   source. A bare `#value` would match nothing.
7. **`!important` sparingly** — exactly one rule (`.flush-card-body`) uses it, with
   a comment saying why (beating the bslib card-body default).
8. **`bs_theme()` / `bs_add_rules()` for theme-level changes** — the Theme tab.
   Colour, font, and radius live in `APP_THEME` (`global.R`); `bs_add_rules()`
   carries the one rule that needs a Bootstrap Sass variable.

## Tests

```bash
NOT_CRAN=true Rscript -e 'source("renv/activate.R"); setwd("examples/08. css-styling"); \
  library(shinytest2); testthat::test_dir("tests/testthat")'
```

- `test-utils-style-helpers.R` — unit tests for the Rule 2 helpers (`grade_fill`
  mapping + validation, `pct_bar` clamping/fill/label/validation)
- `test-mod-computed-styles.R` — `testServer()` test of the flagged-count reactive
  tracking the slider threshold
- `test-mod-metric-panel.R` — `testServer()` test of the value formatting
- `test-all-tabs-smoke.R` — **the acceptance gate** (testing rule 6): launches the
  real app, visits **all 6 tabs**, sweeps the Computed-styles slider (so its
  `renderUI` executes), and asserts no Shiny stderr / DOM `shiny-output-error` /
  browser-console errors, plus positive proof the namespaced `#metric_*-value`
  elements and the data-bound `pct-bar-fill` rows rendered.

**24 tests pass** (0 failures, 0 warnings, 0 skips); all 6 tabs verified rendering
end-to-end via `AppDriver`.

## Packages

`shiny`, `bslib`, `bsicons`, `dplyr`, `tibble`, `htmltools`. All pinned in
`renv.lock` — no new dependencies were added by this example.
