---
name: reactable-table
description: Auto-invoked when creating or modifying reactable tables in Shiny. Governs reactableOutput/renderReactable patterns, colDef customization, row selection, grouping, cell rendering, and programmatic updates.
---

# reactable Table Skill

## Canonical Shiny Pattern

```r
library(reactable)

# --- UI ----------------------------------------------------------------------
reactableOutput("my_table")

# --- Server ------------------------------------------------------------------
output$my_table <- renderReactable({
  req(data())
  reactable(
    data(),
    searchable  = TRUE,
    sortable    = TRUE,
    pagination  = TRUE,
    defaultPageSize = 25,
    striped     = TRUE,
    highlight   = TRUE,
    compact     = TRUE
  )
})
```

---

## Column Definitions with `colDef()`

```r
reactable(
  data(),
  columns = list(
    usubjid = colDef(name = "Subject ID", minWidth = 120),
    age     = colDef(name = "Age", align = "right", format = colFormat(digits = 0)),
    aval    = colDef(
      name   = "Value",
      format = colFormat(digits = 2, separators = TRUE)
    ),
    pct     = colDef(
      name   = "Percent",
      format = colFormat(percent = TRUE, digits = 1)
    ),
    flag    = colDef(show = FALSE)   # hide column
  )
)
```

`colFormat()` options: `digits`, `separators`, `percent`, `currency`, `datetime`, `date`, `time`, `locales`.

---

## Row Selection

```r
# In UI
reactableOutput("tbl")
actionButton("get_selected", "Get Selected")

# In server
output$tbl <- renderReactable({
  reactable(
    data(),
    selection = "multiple",   # "single" or "multiple"
    onClick   = "select"      # click row to select
  )
})

selected_data <- eventReactive(input$get_selected, {
  selected <- getReactableState("tbl", "selected")  # returns selected row indices
  req(selected)
  data()[selected, ]
})
```

`getReactableState()` must be called inside a reactive context. It returns the current page, pageSize, sorted, and selected state.

---

## Custom Cell Rendering

```r
reactable(
  data(),
  columns = list(
    status = colDef(
      name = "Status",
      cell = function(value) {
        color <- if (value == "Pass") "#28a745" else "#dc3545"
        htmltools::span(style = paste0("color:", color, "; font-weight:bold"), value)
      }
    ),
    link = colDef(
      name = "Report",
      html = TRUE,
      cell = function(value, index) {
        sprintf('<a href="%s" target="_blank">View</a>', value)
      }
    )
  )
)
```

Set `html = TRUE` in `colDef()` when the cell function returns raw HTML strings.

---

## Grouping and Aggregation

```r
reactable(
  data(),
  groupBy = "treatment",     # column name to group by (can be a vector)
  columns = list(
    n     = colDef(aggregate = "count"),
    aval  = colDef(
      aggregate = "mean",
      format    = colFormat(digits = 2)
    ),
    flag  = colDef(aggregate = "unique")   # show if all values are the same
  )
)
```

Built-in aggregates: `"sum"`, `"mean"`, `"max"`, `"min"`, `"median"`, `"count"`, `"unique"`, `"frequency"`.

---

## Expandable Row Details

```r
reactable(
  summary_data,
  details = function(index) {
    # Return a reactable (or any htmltools tag) for the expanded row
    detail_rows <- detail_data[detail_data$id == summary_data$id[index], ]
    reactable(detail_rows, outlined = TRUE)
  }
)
```

---

## Programmatic Updates

```r
# Update selected rows, page, or page size without full re-render
observeEvent(input$reset, {
  updateReactable("tbl", selected = NA, page = 1)
})

observeEvent(input$select_first, {
  updateReactable("tbl", selected = 1)
})
```

`updateReactable()` arguments: `selected`, `page`, `pageSize`, `data` (replace underlying data).

---

## Conditional Row Styling

```r
reactable(
  data(),
  rowStyle = function(index) {
    if (data()$flag[index] == "Y") list(background = "#fff3cd")
    else NULL
  },
  rowClass = function(index) {
    if (data()$serious[index]) "serious-row" else NULL
  }
)
```

Use `rowStyle` for inline CSS and `rowClass` for CSS class names (defined in `www/custom.css`).

---

## Common Pitfalls

- **`getReactableState()` outside reactive context** — wrap in `reactive()`, `eventReactive()`, or `observe*()`; calling it at top-level server fails
- **`selection` without `onClick = "select"`** — selection works but requires shift/ctrl-click; add `onClick = "select"` for single-click selection UX
- **Data updates** — prefer `updateReactable("tbl", data = new_data())` over re-rendering to preserve sort/page state
- **`html = TRUE` and XSS** — never render user-supplied strings as HTML; sanitize first
- **Column names with spaces** — wrap in backticks in the `columns` list: `` `my col` = colDef(...) ``
