---
name: gt-table
description: Auto-invoked when creating or modifying gt tables in Shiny. Governs gt_output/render_gt patterns, the pipeline API, column formatting, conditional styling, spanners, and summary rows for publication-quality tables.
---

# gt Table Skill

## Canonical Shiny Pattern

```r
library(gt)

# --- UI ----------------------------------------------------------------------
gt_output("my_table")

# --- Server ------------------------------------------------------------------
output$my_table <- render_gt({
  req(data())
  data() %>%
    gt() %>%
    tab_header(
      title    = "Study Summary",
      subtitle = "All Treated Subjects"
    ) %>%
    cols_label(
      usubjid = "Subject ID",
      aval    = "Analyte Value",
      visit   = "Visit"
    ) %>%
    fmt_number(columns = aval, decimals = 2) %>%
    tab_source_note("Data cutoff: 2024-06-01")
})
```

---

## Pipeline API Overview

gt tables are built by piping modifier functions onto `gt()`. Order matters — later calls override earlier ones.

| Function group | Purpose |
|----------------|---------|
| `tab_header()` | Title and subtitle |
| `tab_spanner()` | Column group headers |
| `cols_label()` | Rename columns |
| `cols_move()` / `cols_hide()` | Reorder or hide columns |
| `fmt_*()` | Format cell values |
| `tab_style()` | Conditional or targeted cell styling |
| `data_color()` | Color scale based on values |
| `summary_rows()` | Aggregate rows within groups |
| `grand_summary_rows()` | Aggregate row at bottom of table |
| `tab_footnote()` | Footnote attached to a cell, column, or row |
| `tab_source_note()` | Source note at the bottom |
| `tab_options()` | Global table appearance options |

---

## Column Formatting

```r
gt_tbl %>%
  fmt_number(columns = c(aval, chg), decimals = 2) %>%
  fmt_percent(columns = pct_chg, decimals = 1) %>%
  fmt_currency(columns = cost, currency = "USD") %>%
  fmt_date(columns = visit_dt, date_style = "yMMMd") %>%
  sub_missing(columns = everything(), missing_text = "--")
```

Use `columns = everything()` or `columns = where(is.numeric)` for tidy selection.

---

## Spanners (Column Group Headers)

```r
gt_tbl %>%
  tab_spanner(
    label   = "Baseline",
    columns = c(base_val, base_date)
  ) %>%
  tab_spanner(
    label   = "Week 12",
    columns = c(w12_val, w12_date)
  )
```

Spanners appear above the column labels. Nest spanners by passing a `spanner_id` to reference in another `tab_spanner()`.

---

## Conditional Styling

```r
# Style specific cells based on value
gt_tbl %>%
  tab_style(
    style = list(
      cell_fill(color = "#f8d7da"),
      cell_text(weight = "bold", color = "#721c24")
    ),
    locations = cells_body(
      columns = aval,
      rows    = aval > threshold
    )
  )

# Color scale across a column
gt_tbl %>%
  data_color(
    columns = aval,
    palette = c("white", "#0d6efd"),
    domain  = c(0, 100)
  )
```

`locations` helpers: `cells_body()`, `cells_column_labels()`, `cells_row_groups()`, `cells_stub()`, `cells_summary()`, `cells_grand_summary()`.

---

## Summary Rows

```r
data %>%
  group_by(treatment) %>%
  gt(groupname_col = "treatment") %>%
  summary_rows(
    groups    = TRUE,
    columns   = c(aval, chg),
    fns       = list(
      Mean = ~ mean(., na.rm = TRUE),
      SD   = ~ sd(., na.rm = TRUE),
      N    = ~ sum(!is.na(.))
    ),
    fmt       = list(~ fmt_number(., decimals = 2))
  ) %>%
  grand_summary_rows(
    columns = aval,
    fns     = list(Overall = ~ mean(., na.rm = TRUE)),
    fmt     = list(~ fmt_number(., decimals = 2))
  )
```

---

## Table Appearance Options

```r
gt_tbl %>%
  tab_options(
    table.font.size          = px(13),
    table.width              = pct(100),
    column_labels.font.weight = "bold",
    row_group.font.weight    = "bold",
    row.striping.include_table_body = TRUE,
    heading.align            = "left"
  )
```

---

## Footnotes

```r
gt_tbl %>%
  tab_footnote(
    footnote  = "Graded per CTCAE v5.0",
    locations = cells_column_labels(columns = grade)
  ) %>%
  tab_footnote(
    footnote  = "Early discontinuation",
    locations = cells_body(columns = usubjid, rows = eos_reason == "Withdrew")
  )
```

---

## Export Outside Shiny

```r
# Save to file
gtsave(gt_tbl, "table.html")
gtsave(gt_tbl, "table.docx")   # requires {webshot2} for PDF/PNG
gtsave(gt_tbl, "table.rtf")
```

---

## Common Pitfalls

- **gt is static** — it renders HTML but has no built-in sorting, filtering, or pagination; use DT or reactable when interactivity is needed
- **`render_gt()` not `renderTable()`** — always use `render_gt()` / `gt_output()` pair in Shiny
- **Column selection** — `columns` uses tidyselect: `c(col1, col2)`, `where(is.numeric)`, `starts_with("ae_")`; pass bare names not strings
- **`sub_missing()` order** — apply after other `fmt_*()` calls or it may be overridden (note: `fmt_missing()` is deprecated — use `sub_missing()`)
- **Grouping requires grouped data** — pass a grouped data frame or use `groupname_col` argument to `gt()`; `summary_rows()` only works with groups
- **Large tables in Shiny** — gt renders the entire table as HTML; for 1000+ rows, paginate upstream or switch to DT
