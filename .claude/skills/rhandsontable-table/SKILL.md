---
name: rhandsontable-table
description: Auto-invoked when creating or modifying rhandsontable tables in Shiny. Governs rHandsontableOutput/renderRHandsontable patterns, reading edits back to R, column types and validation, read-only controls, and hot_to_r() usage.
---

# rhandsontable Table Skill

## Canonical Shiny Pattern

```r
library(rhandsontable)

# --- UI ----------------------------------------------------------------------
rHandsontableOutput("my_table")

# --- Server ------------------------------------------------------------------
output$my_table <- renderRHandsontable({
  req(data())
  rhandsontable(data(), rowHeaders = NULL) %>%
    hot_table(highlightCol = TRUE, highlightRow = TRUE)
})

# Read edits back into R
edited_data <- reactive({
  req(input$my_table)
  hot_to_r(input$my_table)
})
```

`hot_to_r()` converts the Handsontable JSON input back to an R data frame. Always use `hot_to_r()` — do not parse `input$tableId` manually.

---

## Column Configuration with `hot_col()`

```r
rhandsontable(data()) %>%
  hot_col("status",    type = "dropdown", source = c("Active", "Completed", "Withdrawn")) %>%
  hot_col("confirmed", type = "checkbox") %>%
  hot_col("visit_dt",  type = "date",     dateFormat = "YYYY-MM-DD") %>%
  hot_col("aval",      type = "numeric",  format = "0.00") %>%
  hot_col("notes",     type = "text")
```

Column types: `"text"`, `"numeric"`, `"date"`, `"checkbox"`, `"dropdown"`, `"autocomplete"`, `"password"`, `"time"`, `"handsontable"`.

---

## Read-Only Columns

```r
# Make specific columns read-only
rhandsontable(data()) %>%
  hot_col("usubjid", readOnly = TRUE) %>%
  hot_col("studyid", readOnly = TRUE)

# Make the entire table read-only
rhandsontable(data(), readOnly = TRUE)
```

---

## Column Widths and Visibility

```r
rhandsontable(data()) %>%
  hot_col("usubjid", width = 120) %>%
  hot_col("notes",   width = 250) %>%
  hot_cols(columnSorting = TRUE)    # enable sorting on all columns

# Hide a column (keep data, hide visually)
rhandsontable(data()) %>%
  hot_col("internal_id", width = 0.1)   # near-zero width to hide
```

---

## Table-Level Options

```r
rhandsontable(
  data(),
  rowHeaders   = NULL,       # hide row numbers
  stretchH     = "all",      # stretch columns to fill width
  contextMenu  = TRUE,       # right-click menu
  overflow     = "hidden",   # clip overflow
  height       = 400,        # fixed height with scroll
  width        = "100%"
) %>%
  hot_table(
    highlightCol  = TRUE,
    highlightRow  = TRUE,
    enableComments = FALSE
  )
```

---

## Conditional Cell Formatting

```r
# Use hot_cols() with renderer for custom cell styling
rhandsontable(data()) %>%
  hot_col(
    "aval",
    renderer = "
      function(instance, td, row, col, prop, value, cellProperties) {
        Handsontable.renderers.NumericRenderer.apply(this, arguments);
        if (value > 100) {
          td.style.background = '#f8d7da';
          td.style.color = '#721c24';
        }
      }
    "
  )
```

Renderer strings are JavaScript. Keep them simple — complex logic belongs in R before the table renders.

---

## Preserving Edits Across Re-Renders

The table re-renders whenever `renderRHandsontable` re-executes, losing unsaved edits. Preserve edits by seeding the render from the input:

```r
# Seed table from edited state if available, else from source data
output$my_table <- renderRHandsontable({
  current <- if (!is.null(input$my_table)) hot_to_r(input$my_table) else data()
  rhandsontable(current, rowHeaders = NULL)
})
```

Use this pattern when the table data can also change from outside (e.g., a reset button). Add an `ignoreInit = TRUE` guard if needed to avoid circular reactivity.

---

## Validation

```r
rhandsontable(data()) %>%
  hot_col(
    "age",
    type   = "numeric",
    validator = "function(value, callback) { callback(value >= 0 && value <= 120); }",
    allowInvalid = FALSE   # blocks invalid input (shows red border)
  )
```

`allowInvalid = TRUE` (default) highlights invalid cells but still accepts them. Set `FALSE` to block the entry.

---

## Save / Reset Pattern in Shiny

```r
# UI
rHandsontableOutput("tbl")
actionButton("save",  "Save Changes")
actionButton("reset", "Reset")

# Server
rv <- reactiveValues(data = initial_data)

output$tbl <- renderRHandsontable({
  rhandsontable(rv$data, rowHeaders = NULL)
})

observeEvent(input$save, {
  rv$data <- hot_to_r(input$tbl)
  # write rv$data to DB or file here
})

observeEvent(input$reset, {
  rv$data <- initial_data
})
```

---

## Common Pitfalls

- **Always use `hot_to_r()`** — `input$tableId` is a JSON list, not a data frame; `hot_to_r()` converts it correctly
- **Re-render wipes edits** — any reactive dependency in `renderRHandsontable` that changes will discard unsaved edits; seed from `input$tableId` or use `reactiveValues` to persist
- **Column order must match data frame** — `hot_col()` refers to columns by name; if you reorder columns in the data frame, verify `hot_col()` calls still target the right columns
- **Date columns** — rhandsontable returns dates as strings; coerce with `as.Date()` after `hot_to_r()`
- **Large data** — Handsontable renders all rows in the DOM; avoid > 500 rows; use pagination or aggregation upstream
- **Circular reactivity** — if `renderRHandsontable` reads `input$my_table` to seed itself, wrap with `isolate()` or use `reactiveValues` to break the cycle
