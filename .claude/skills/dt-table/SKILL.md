---
name: dt-table
description: Auto-invoked when creating or modifying DT (DataTables) tables in Shiny. Governs DTOutput/renderDT patterns, server-side processing, row selection, proxy updates, formatting, and extensions.
---

# DT Table Skill

## Canonical Shiny Pattern

```r
library(DT)

# --- UI ----------------------------------------------------------------------
DTOutput("my_table")

# --- Server ------------------------------------------------------------------
output$my_table <- renderDT({
  req(data())
  datatable(
    data(),
    rownames  = FALSE,
    selection = "single",       # "single", "multiple", or "none"
    options   = list(
      pageLength = 25,
      dom        = "lBfrtip",   # l=length, B=buttons, f=filter, r=processing,
                                # t=table, i=info, p=pagination
      scrollX    = TRUE
    )
  )
}, server = TRUE)               # server = TRUE required for large data
```

---

## Server-Side vs Client-Side Processing

| Mode | Use when | How |
|------|----------|-----|
| `server = TRUE` | > ~5,000 rows | Default for large data — filtering/sorting done in R |
| `server = FALSE` | < ~5,000 rows | All data sent to browser — enables CSV export of full table |

For CSV/Excel export of all rows, set `server = FALSE` (Buttons extension only exports the current page when `server = TRUE`).

---

## Row Selection

```r
# In UI
DTOutput("tbl")

# In server — read selected rows
selected_data <- reactive({
  req(input$tbl_rows_selected)
  data()[input$tbl_rows_selected, ]
})
```

Input suffixes from DT:

| Input | Value |
|-------|-------|
| `input$tableId_rows_selected` | Integer vector of selected row indices |
| `input$tableId_rows_all` | All row indices (after filter, before pagination) |
| `input$tableId_cell_clicked` | List with `row`, `col`, `value` |
| `input$tableId_search` | Current search string |

---

## Proxy Updates (Avoid Full Re-render)

Use a proxy to update selection or data without redrawing the table:

```r
# Create proxy
proxy <- dataTableProxy("my_table")

# Replace data (keeps pagination/sort)
observeEvent(input$refresh, {
  replaceData(proxy, new_data(), rownames = FALSE, resetPaging = FALSE)
})

# Programmatically select rows
observeEvent(input$select_all, {
  selectRows(proxy, 1:nrow(data()))
})

# Clear selection
observeEvent(input$clear, {
  selectRows(proxy, NULL)
})
```

---

## Column Formatting

Apply after `datatable()` with the pipe:

```r
datatable(data()) %>%
  formatCurrency("cost_col", currency = "$", digits = 2) %>%
  formatPercentage("pct_col", digits = 1) %>%
  formatDate("date_col", method = "toLocaleDateString") %>%
  formatRound("numeric_col", digits = 3) %>%
  formatStyle(
    "status_col",
    backgroundColor = styleEqual(
      c("Pass", "Fail"),
      c("#d4edda",  "#f8d7da")
    )
  )
```

---

## Export Buttons Extension

Requires `dom = "B..."` in options:

```r
datatable(
  data(),
  extensions = "Buttons",
  options = list(
    dom     = "Bfrtip",
    buttons = c("csv", "excel", "pdf", "copy")
  )
)
```

For PDF export, `pdfmake` JS must be available. CSV and Excel work out of the box.

---

## Column Definitions

```r
datatable(
  data(),
  colnames = c("Subject ID" = "usubjid", "Visit" = "visit"),
  options  = list(
    columnDefs = list(
      list(visible = FALSE, targets = 0),          # hide column by index (0-based)
      list(className = "dt-center", targets = 2),  # center-align column
      list(width = "80px", targets = c(1, 2))      # fixed width
    )
  )
)
```

---

## Common Pitfalls

- **Row indices are 1-based in R** — `input$tbl_rows_selected` returns R indices, not JS 0-based indices
- **`server = TRUE` + Buttons** — exports only the current page; use `server = FALSE` or a separate download handler for full data
- **Reactive data + proxy** — use `replaceData()` when the data changes but you want to preserve scroll position and page
- **Column targets in `columnDefs`** — always 0-based JavaScript indices, despite R being 1-based
- **`rownames = FALSE`** — almost always set this; default row names add an unwanted index column
