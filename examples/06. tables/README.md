# Example 06 — R Table Packages Feature Showcase

A four-tab Shiny reference app, one tab per interactive/static table package the
project depends on. Each tab turns on **as many features as is sensible** — the
goal is to demonstrate capability, not to be a minimal production listing. All
four tabs are driven by the same synthetic CDISC-style clinical data so the
packages can be compared on identical inputs.

> **Reference, not production.** Feature density is deliberately high. For the
> "when to use which" decision guide see `docs/comparisons/tables-dt-reactable-gt-rhandsontable.md`
> and the four table skills in `.claude/skills/`.

## Run it

```bash
NOT_CRAN=true Rscript -e 'source("renv/activate.R"); shiny::runApp("examples/06. tables")'
```

No setup, no external services — the data is generated in-memory under fixed
seeds, so every launch (and every test) sees identical data.

## The data (all synthetic — no real patients)

Built once in `global.R` from the factories in `R/fct_sample_data.R`
(120 subjects, 3 arms: Placebo / Low Dose / High Dose):

| Object | Shape | Feeds |
|--------|-------|-------|
| `ADSL` | one row / subject — demographics (ADSL-like) | gt Table 1 |
| `ADAE` | one row / adverse event (ADAE-like) | DT listing, gt AE summary |
| `ADLB` | subject × parameter × visit labs (ADLB-like) | reactable lab summary |
| queries | 25-row data-management query log | rhandsontable grid |

Pure data-prep helpers (`R/utils_table_helpers.R`) aggregate these into the
summary frames the reactable and gt tabs visualise. They are plain
data-frame-in/data-frame-out functions, unit-tested directly.

## What each tab demonstrates

### DT — interactive adverse-event listing (`R/mod_dt_table.R`)
- **Editable cells** (severity / seriousness / relatedness / outcome) read back
  into a `reactiveVal` and pushed to the table via a **proxy** (`editData()`) —
  no full re-render, so sort/page/scroll survive every edit
- `dataTableProxy()`: `replaceData()` (a "simulate follow-up" mutation),
  `selectRows()` (select all serious AEs), clear selection
- Row selection driving a live per-subject **detail panel**
- **Buttons** extension: copy / CSV / Excel / PDF / column visibility, plus a
  separate full-data CSV download handler (`server = TRUE` is required for the
  proxy, so the Buttons export only the current page)
- `FixedHeader`, top column filters
- `formatStyle()` severity colouring, a serious-AE flag, and a `styleColorBar()`
  in-cell duration bar (note: after `colnames =` renames headers, `formatStyle`
  must reference the *displayed* names, e.g. "Severity" not "AESEV")

### reactable — laboratory summary (`R/mod_reactable_table.R`)
- **groupBy** parameter with aggregated parent rows
- **custom cell renderers** (htmltools): colour-coded change with ▲/▼ arrows and
  an in-cell percent bar
- inline **{sparkline}** line charts embedded from a list-column
- **expandable row details** — a nested reactable of per-subject values
- column groups (`colGroup`), a **sticky** column, **footer** summaries
- conditional `rowStyle` (JS), a custom `reactableTheme`, single-select wired
  back to Shiny via `getReactableState()`

### gt — publication / regulatory tables (`R/mod_gt_table.R`)
Two switchable static tables:
- **Table 1** baseline characteristics — row groups, a stub, a treatment-arm
  **spanner**, per-row-group **footnotes**, a source note, targeted `tab_style`
- **AE incidence by SOC** — `fmt_number`/`fmt_percent`, **`data_color`** heat
  scale on the rates, **`cols_merge`** to "n (%)", a **nanoplot** column, a
  highlighted maximum, footnotes
- one-click **download** of either table as standalone HTML (`gtsave()`)

### rhandsontable — editable query grid (`R/mod_rhandsontable_table.R`)
- mixed **column types**: read-only identifiers, dropdowns, checkbox, date,
  numeric
- numeric **validation** (age 0–365, invalid entries blocked) + a custom JS
  **renderer** flagging aging open queries red
- **save / reset** against a `reactiveValues` store, a live unsaved-edit counter
  via `hot_to_r()`, and CSV download of the edited grid

## Tests

```bash
NOT_CRAN=true Rscript -e 'source("renv/activate.R"); setwd("examples/06. tables"); \
  library(shinytest2); testthat::test_dir("tests/testthat")'
```

- `test-fct-sample-data.R`, `test-utils-table-helpers.R` — factory + helper unit
  tests (determinism, referential integrity, shapes)
- `test-mod-*.R` — `testServer()` tests of each module's reactive logic
- `test-all-tabs-smoke.R` — **the acceptance gate** (testing rule 6): launches
  the real app, visits **every** tab, exercises each tab's headline interactions
  (DT proxy/select/reset, reactable expand/collapse, gt table switch, rhot
  save/reset), and asserts **no output is in a `shiny-output-error` state** plus
  a clean browser console. (The "rendered some HTML" check alone is not enough —
  a render exception leaves a non-empty error `<div>` behind and does not log to
  the browser console, so the gate must look for the error class explicitly.)

**70 tests pass** (0 failures, 0 warnings); all 4 tabs verified rendering
end-to-end via `AppDriver`.

## Packages

`shiny`, `bslib`, `dplyr`, `tidyr`, `tibble`, `DT`, `reactable`, `gt`,
`rhandsontable`, `sparkline`, `htmltools`, `htmlwidgets`. All pinned in
`renv.lock`.
