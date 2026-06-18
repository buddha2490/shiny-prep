# Interactive & Static Tables: DT vs reactable vs gt vs rhandsontable

A critical comparison for R Shiny development in a pharma/clinical context (CDISC SDTM/ADaM data, patient listings, safety/efficacy summaries, clinical review tools). Accurate as of 2026.

---

## 1. TL;DR

For a clinical Shiny app, **DT is the default interactive table** and **gt is the default publication/static table** — this is the project convention and it is the right one. DT gives you sorting, filtering, paging, server-side processing for large data, and tight Shiny selection/proxy integration with a mature, battle-tested codebase. gt gives you grammar-of-tables formatting (spanners, footnotes, summary rows) that maps directly onto regulatory summary-table conventions. **reactable** is a legitimate alternative to DT when you need custom React-rendered cells or nested/grouped detail rows, but its development has slowed and it carries a heavier JS dependency stack — reach for it only when DT genuinely cannot do the layout. **rhandsontable** is a single-purpose tool: in-grid spreadsheet *editing*. Use it only for data-entry/annotation/correction workflows, never as a display table.

| Package | Best for | Avoid when | Interactivity | Editable | Output target |
|---|---|---|---|---|---|
| **DT** | Interactive listings, AE/lab review, large server-side tables | You need publication typesetting (spanners/footnotes) or a Word/PDF static artifact | High (sort/filter/page/search, native) | Limited (cell edit, not its strength) | HTML / Shiny (interactive) |
| **reactable** | Custom-rendered cells, nested detail rows, grouped aggregation | A plain table would do (DT is lighter to reason about); long-term maintenance matters | High (client-side; weak server-side) | No (read-only) | HTML / Shiny (interactive) |
| **gt** | Submission-quality summary tables, demographics, AE incidence | You need user-driven sorting/filtering/paging at scale | Minimal (static; some JS extras) | No | HTML / **PDF / Word / RTF / PNG** (static) |
| **rhandsontable** | Data correction, manual annotation, parameter entry | You only need to *display* data (overkill + fragile) | Spreadsheet-style (edit-centric) | **Yes (primary purpose)** | HTML / Shiny (editable grid) |

---

## 2. The contenders

**DT** is an R wrapper around the mature JavaScript library **DataTables.js** (jQuery-based). It is the workhorse of interactive tables in Shiny: it exposes DataTables' sorting, searching, paging, and extension ecosystem (Buttons, Scroller, Select) through `DT::datatable()` and the `DTOutput`/`renderDT` Shiny pair. Its philosophy is "expose a proven JS grid faithfully" — which means power and stability, but also a large, somewhat dated option surface and jQuery underpinnings.

**reactable** wraps the React-based **react-table** (now glide-data-grid era tooling under the hood for newer features) via the **reactR** bridge. Its philosophy is "tables as composable React components": you define columns with `colDef()` and can render any cell with an R function or JS. It produces clean, modern output and excels at nested/grouped rows and custom cells, but it is **client-side first** (no real server-side processing) and its release cadence has noticeably slowed, which is a real maintenance consideration.

**gt** is the tidyverse "**g**rammar of **t**ables" — a pipeable, layered API (`tab_spanner()`, `tab_footnote()`, `fmt_*()`, `summary_rows()`) for building *display* tables. Its philosophy is publication quality and multi-format rendering: the *same* gt object renders to HTML, **PDF/LaTeX, Word, RTF, and PNG**. It is static by design; interactivity is an afterthought (`opt_interactive()` exists but is not its strength).

**rhandsontable** wraps **Handsontable.js**, a spreadsheet-grid component. Its philosophy is "Excel in the browser": editable cells, column types, dropdowns, validation, and read-back into R via `hot_to_r()`. It is the only one of the four where *editing* is the headline feature; everything else (display, formatting) is secondary and comparatively crude.

---

## 3. Dimension-by-dimension comparison

### Interactivity (sorting / filtering / paging / search)

| | DT | reactable | gt | rhandsontable |
|---|---|---|---|---|
| Sort / filter / page / search | Native, comprehensive | Native, client-side | Essentially none (static) | Column sort; no real search/page |

- **DT** wins outright: per-column filters (`filter = "top"`), global search, paging, and the Scroller extension for infinite scroll all ship in the box. **Cost:** the breadth comes with a sprawling `options = list(...)` surface that mirrors DataTables.js verbatim — you frequently end up reading DataTables.js docs, not R docs.
- **reactable** offers comparable client-side interactivity with a cleaner R API (`filterable = TRUE`, `searchable = TRUE`, `defaultPageSize`). **Cost:** it filters/sorts in the browser, so all rows ship to the client — it does not scale the way DT's server-side mode does.
- **gt** is static. `opt_interactive()` adds a thin sort/search/page layer, but it is immature and you lose much of gt's formatting fidelity when you enable it. Don't pick gt *for* interactivity.
- **rhandsontable** is built for editing, not browsing — sorting exists but searching/paging do not in any usable form.

### Large-data handling (where it breaks down)

This is the single most important axis for clinical lab datasets.

- **DT** is the only one of the four with true **server-side processing** (`server = TRUE`, the default for `renderDT`). DataTables sends only the visible page back to the browser; R does the sort/filter/page. This comfortably handles **hundreds of thousands to millions of rows**. **Cost:** server-side mode changes the semantics — row selection returns *row indices into the current page/order*, custom column rendering and JS callbacks behave differently, and you must page/sort server-side too. It is more code and a sharper learning curve.

```r
# DT server-side: only the visible page crosses the wire
output$adlb_tbl <- renderDT(
  adlb,                  # could be 1M+ rows
  server = TRUE,         # default; keep it for big data
  options = list(pageLength = 25)
)
```

- **reactable** has **no server-side processing**. Everything is rendered/held client-side. It is comfortable to a few thousand rows; performance degrades noticeably as you approach tens of thousands, and the initial payload can be large. Virtualization helps scrolling but not the transfer cost.
- **gt** is static HTML — a large gt table is a huge DOM and will choke the browser well before DT does. gt is for *summaries* (tens to low hundreds of rows), not raw listings. Rendering thousands of rows in gt is a misuse.
- **rhandsontable** virtualizes the visible viewport (Handsontable handles large grids reasonably for editing), but round-tripping large grids through `hot_to_r()` is expensive. Practical ceiling is a few thousand editable rows.

**Verdict:** for large lab/listing data, **DT server-side is the only correct choice**.

### Editing / data entry

- **rhandsontable** is the answer. Column types (`numeric`, `dropdown`, `checkbox`, `date`), per-column read-only, validation, and `hot_to_r()` to pull the edited grid back into R as a data frame.

```r
output$grid <- renderRHandsontable({
  rhandsontable(annotations) %>%
    hot_col("status", type = "dropdown", source = c("confirmed", "query", "n/a")) %>%
    hot_col("subject_id", readOnly = TRUE)
})
edited <- reactive({ hot_to_r(input$grid) })  # read edits back
```

  **Cost:** Handsontable is a heavy dependency, the R API exposes only a slice of its capabilities, type coercion through `hot_to_r()` is a known source of subtle bugs (factors/dates/integers can come back unexpectedly), and it is the least actively maintained of the four. Treat edited data as untrusted and validate after read-back.
- **DT** supports cell editing (`editable = TRUE`, with `cell`/`row`/`column`/`all` modes) and emits `input$tbl_cell_edit`. It is serviceable for light correction but is **not** a spreadsheet — multi-cell paste, validation, and dropdowns are limited.
- **reactable** and **gt** are **read-only**. Do not pick them if editing is required.

### Styling & publication quality (conditional formatting, spanners, footnotes)

- **gt** is the clear winner and the reason it is the static default. Column **spanners** (`tab_spanner()`), **footnotes** with markers (`tab_footnote()`), source notes, stub heads, **summary rows** (`grand_summary_rows()`), and per-cell conditional styling (`tab_style()` + `cells_body()`) map directly onto the structure of regulatory demographic and AE-incidence tables. Crucially, it renders to **PDF/Word/RTF** with the formatting intact.

```r
ae_summary %>%
  gt(rowname_col = "soc") %>%
  tab_spanner("Placebo (N=98)", columns = starts_with("pbo")) %>%
  tab_spanner("Active (N=102)", columns = starts_with("act")) %>%
  fmt_number(columns = ends_with("pct"), decimals = 1) %>%
  tab_footnote("Treatment-emergent AEs.", cells_column_labels("act_n"))
```

- **reactable** can produce attractive output and arbitrary cell rendering, but spanners are basic (column groups only) and there is **no native footnote/source-note system** — you reconstruct publication structure by hand.
- **DT** styling is functional (`formatStyle()`, `formatCurrency()`, `formatRound()`, conditional color via `styleInterval()`), but it is a data grid, not a typesetting engine: no spanners worth the name, no footnote markers. It looks like a web table, not a clinical study report table.
- **rhandsontable** has minimal display styling. Not a candidate.

### Shiny integration (proxy updates, selection, reactivity)

- **DT** has the deepest Shiny integration: `dataTableProxy()` with `replaceData()`, `selectRows()`, `selectPage()` for partial updates without a full re-render; rich selection via `input$tbl_rows_selected` / `_cell_clicked` / `_rows_current`. This is mature and well documented (see the project's `dt-table` skill). **Cost:** proxy + server-side selection semantics require care (indices vs. keys).
- **reactable** has `reactable::updateReactable()` (select rows, set page, update data) and `getReactableState()`. Capable, but the API is younger and less documented; selection wiring is fiddlier than DT's.
- **gt** integrates via `render_gt`/`gt_output` for *display only* — no selection events, no proxy.
- **rhandsontable** integrates as an input (`input$grid` carries the edited data); good for forms, but it is not a selection/eventing surface like DT.

### Export (CSV / Excel / PDF / regulatory artifacts)

- **DT** exposes the DataTables **Buttons** extension: client-side Copy/CSV/Excel/PDF/Print buttons. **Cost:** these are *client-side* exports of the visible/filtered view — fine for ad-hoc reviewer downloads, but PDF output is cosmetically weak and **not** a submission artifact. For controlled exports, wire a Shiny `downloadHandler` instead.
- **gt** is the export winner for *static artifacts*: `gtsave()` to **PDF, Word (.docx), RTF, HTML, and PNG**. RTF/Word output is directly relevant to clinical reporting toolchains. This, plus formatting fidelity, is why gt owns the submission-table role.
- **reactable** has no built-in export; you roll your own with a `downloadHandler`.
- **rhandsontable** has no meaningful export; you export the read-back data frame yourself.

### Learning curve & API ergonomics

- **gt**: cleanest, most teachable API — pipeable, composable, tidyverse-idiomatic. Steeper only when you push into custom rendering.
- **reactable**: clean R-level API (`colDef()` list), but custom cells push you into JS/`htmlwidgets::JS()` and React mental models quickly.
- **DT**: the R surface is small, but real work means configuring DataTables.js `options` lists — effectively learning a second library. Server-side mode adds conceptual load.
- **rhandsontable**: simple for basic grids; the `hot_*()` chain is approachable, but edge cases (types, validation, read-back coercion) are where time goes.

### Dependencies / footprint

- **DT**: jQuery + DataTables.js. Mature, stable, ubiquitous — but jQuery-era tech. Lightest *conceptual* footprint for what it does; broadly compatible.
- **reactable**: React + reactR + a JS bundle. **Heaviest** front-end footprint, and the reactR bridge is an extra maintenance surface. Combined with slowed development, this is the main argument against reactable as a default.
- **gt**: relatively self-contained for HTML; PDF/Word paths may pull additional system tooling (LaTeX for PDF). Active development.
- **rhandsontable**: Handsontable.js bundle; least actively maintained R package of the four — a real risk for long-lived validated apps.

---

## 4. Decision guide

**DT**
- **Use when:** you need an interactive listing or review table; data is large enough to need server-side processing; you need rich row/cell selection wired into reactivity; you want proxy updates without full re-render; reviewers want quick client-side CSV/Excel export.
- **Don't use when:** the deliverable is a typeset summary table for a report/submission (use gt); you need true spreadsheet editing (use rhandsontable); you need spanners/footnotes.

**reactable**
- **Use when:** you need custom-rendered cells (inline sparklines, badges, buttons), nested/expandable detail rows, or grouped client-side aggregation that DT makes awkward; dataset fits comfortably in the browser.
- **Don't use when:** a plain interactive table suffices (DT is simpler to reason about and maintain); you need server-side processing for large data; long-term maintainability is paramount (development has slowed; React/reactR is a heavier dependency to carry in a validated environment).

**gt**
- **Use when:** the output is a publication/submission summary table; you need spanners, footnotes, summary rows, stub structure; you must render to PDF/Word/RTF with formatting preserved; the row count is small (summary, not listing).
- **Don't use when:** users need to sort/filter/page/search interactively at scale; the table has thousands of raw rows (it will bloat the DOM); you need editing or selection events.

**rhandsontable**
- **Use when:** users must *edit* data in-grid — corrections, manual annotation/adjudication, parameter entry; you need column types, dropdowns, and read-back to R.
- **Don't use when:** you only need to display data (it is heavier, less polished, and less maintained than DT/reactable/gt for read-only views); you have large datasets (read-back is expensive); the app is long-lived and validation-sensitive (maintenance risk).

---

## 5. Pharma / clinical context

- **Patient listings & AE tables (interactive review):** **DT**. Reviewers need sorting, per-column filtering, search, and row selection to drill into subjects; lab/listing datasets are large, so DT's server-side processing is essential. Wire row selection to a detail panel and use a `downloadHandler` for controlled CSV export of the filtered view.

- **Publication-quality safety/efficacy summary tables (submissions):** **gt**. Demographics tables, AE incidence by SOC/PT with treatment-arm spanners and N-counts, lab shift tables — gt's spanners, footnote markers, summary rows, and **RTF/Word/PDF** output are exactly what regulatory reporting needs. The same gt object can render in the app (`render_gt`) and be saved as the submission artifact (`gtsave()`), keeping screen and document consistent.

- **Editable data-correction / annotation workflows:** **rhandsontable**, deliberately scoped. Adjudication queries, manual data corrections, mapping/parameter entry. Lock identifier columns `readOnly = TRUE`, constrain values with `type = "dropdown"`, and **validate everything after `hot_to_r()`** before persisting — never trust the round-tripped frame's types. For light single-cell fixes, DT's `editable = TRUE` may be enough and avoids the extra dependency.

- **Large lab datasets:** **DT server-side**, full stop. reactable and gt will choke; rhandsontable is for editing, not browsing. If you need custom cell visuals (e.g., inline reference-range flags) on a *small* slice, reactable is acceptable, but page/filter the data down first.

**Project default (per convention):** **DT for interactive, gt for static/publication.** This is correct and should be the starting assumption. Deviate to reactable only for a specific layout DT cannot achieve, and to rhandsontable only when in-grid editing is the actual requirement. When unclear whether a table is interactive or static, ask.

---

## 6. Interop & migration notes

- **Combining them:** common and encouraged. A typical clinical app shows a DT interactive listing on screen, while a "Generate report" action renders the *same underlying summary* as gt and `gtsave()`s it to RTF/Word for the TLF (tables/listings/figures) package. DT and gt coexist without conflict.

- **gt's interactive aspirations:** `opt_interactive()` and **gtExtras** (`gt_plt_bar`, `gt_color_rows`, theme helpers) extend gt toward richer/interactive output. **But:** `opt_interactive()` is not a substitute for DT — it is limited, sacrifices formatting fidelity, and does not scale. **When gt is not enough → move to DT (or reactable).** Rule of thumb: if the user needs to *drive* the table (sort/filter/select/page large data), it is a DT job; if they need to *read and export* a formatted summary, it is a gt job. gtExtras is for enriching the *static* table, not for making gt an interactive grid.

- **crosstalk linking:** **DT and reactable both support crosstalk** (`SharedData$new()`), so they can be linked to plotly/leaflet for brushing/filtering *without* a Shiny server round-trip. **gt and rhandsontable do not** participate in crosstalk. Caveat: crosstalk is client-side, so it is incompatible with DT's server-side processing — you trade large-data scaling for client-side linking. In Shiny apps, prefer reactive wiring over crosstalk unless you specifically want the no-server-round-trip behavior (e.g., a static HTML report).

- **Switching costs:**
  - *DT ⇄ reactable:* moderate. Both are interactive HTML grids; column-config concepts map across, but DT `options` lists and reactable `colDef()`s are structurally different rewrites, and you lose DT server-side processing moving to reactable.
  - *DT/reactable → gt:* a re-conception, not a port — you move from a data grid to a typeset summary. Usually you also aggregate the data first (listings → summaries). Low mechanical overlap.
  - *Any → rhandsontable:* a different paradigm entirely (display → editing). Expect to rebuild, and budget for `hot_to_r()` validation.

---

## 7. Bottom line

**Recommendation hierarchy for a clinical Shiny app:**

1. **DT** — default for anything interactive: listings, AE/lab review, large server-side tables, selection-driven drill-downs. The workhorse. Mature, scalable, deeply Shiny-integrated.
2. **gt** — default for anything static/publication: submission summary tables, demographics, AE incidence, with PDF/Word/RTF export. The static-table standard.
3. **reactable** — situational: custom-rendered cells, nested detail rows, grouped client-side aggregation that DT makes awkward, on modest-sized data. Use with eyes open to its slowed development and heavier React/reactR footprint.
4. **rhandsontable** — niche and single-purpose: in-grid editing/annotation/correction only. Scope it tightly, validate read-back, and never use it as a display table.

If you remember one line: **DT to browse, gt to publish, reactable when DT can't render the cell, rhandsontable when the user must type into it.**
