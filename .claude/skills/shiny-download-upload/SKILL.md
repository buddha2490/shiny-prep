---
name: shiny-download-upload
description: Auto-invoked when implementing file upload or download functionality in Shiny. Governs fileInput/downloadHandler patterns, CSV/Excel/PDF export, multi-file upload, progress indicators, and common pitfalls with temp file paths and MIME types.
---

# Shiny File Upload & Download

## File Upload -- `fileInput()`

### Canonical Pattern

```r
# --- UI ----------------------------------------------------------------------
fileInput("file", "Upload CSV:",
          accept = c(".csv", ".tsv", "text/csv"))

# --- Server ------------------------------------------------------------------
uploaded_data <- reactive({
  req(input$file)
  read.csv(input$file$datapath)
})
```

### Understanding `input$file`

`input$file` is `NULL` until the user selects a file. After upload, it returns a data frame:

| Column | Value |
|--------|-------|
| `name` | Original filename (`"patients.csv"`) |
| `size` | File size in bytes |
| `type` | MIME type (`"text/csv"`) |
| `datapath` | Temporary file path on the server (use this to read the file) |

**Always use `input$file$datapath`** to read the file -- never the `name`.

### Multi-File Upload

```r
# UI
fileInput("files", "Upload Files:", multiple = TRUE,
          accept = c(".csv", ".xlsx"))

# Server
uploaded_data <- reactive({
  req(input$files)
  # input$files is a data frame with one row per file
  purrr::map_dfr(input$files$datapath, read.csv)
})
```

### File Type Validation

```r
uploaded_data <- reactive({
  req(input$file)

  ext <- tools::file_ext(input$file$name)
  validate(
    need(ext %in% c("csv", "tsv"), "Please upload a CSV or TSV file.")
  )

  switch(ext,
    csv = read.csv(input$file$datapath),
    tsv = read.delim(input$file$datapath),
  )
})
```

### Excel Files

```r
# Requires readxl (no Java dependency) or openxlsx
uploaded_data <- reactive({
  req(input$file)
  validate(
    need(tools::file_ext(input$file$name) %in% c("xlsx", "xls"),
         "Please upload an Excel file.")
  )
  readxl::read_excel(input$file$datapath, sheet = 1)
})
```

---

## File Download -- `downloadHandler()`

### Canonical Pattern

```r
# --- UI ----------------------------------------------------------------------
downloadButton("download", "Download CSV")

# --- Server ------------------------------------------------------------------
output$download <- downloadHandler(
  filename = function() {
    paste0("export_", Sys.Date(), ".csv")
  },
  content = function(file) {
    write.csv(filtered_data(), file, row.names = FALSE)
  }
)
```

`downloadHandler()` takes two functions:
- **`filename`** -- returns the default filename for the download dialog
- **`content`** -- receives a temp `file` path; write the output to this path

### CSV Export

```r
output$download_csv <- downloadHandler(
  filename = function() {
    paste0("data_", format(Sys.time(), "%Y%m%d_%H%M%S"), ".csv")
  },
  content = function(file) {
    write.csv(filtered_data(), file, row.names = FALSE)
  }
)
```

### Excel Export

```r
# Requires openxlsx or writexl
output$download_excel <- downloadHandler(
  filename = function() {
    paste0("report_", Sys.Date(), ".xlsx")
  },
  content = function(file) {
    # Simple single-sheet export
    writexl::write_xlsx(filtered_data(), file)

    # Multi-sheet export with formatting
    # wb <- openxlsx::createWorkbook()
    # openxlsx::addWorksheet(wb, "Data")
    # openxlsx::writeData(wb, "Data", filtered_data())
    # openxlsx::addWorksheet(wb, "Summary")
    # openxlsx::writeData(wb, "Summary", summary_data())
    # openxlsx::saveWorkbook(wb, file)
  }
)
```

### PDF / HTML Report Export (Rmarkdown / Quarto)

```r
output$download_report <- downloadHandler(
  filename = function() {
    paste0("report_", Sys.Date(), ".pdf")
  },
  content = function(file) {
    # Copy the template to a temp directory (avoid permission issues)
    temp_rmd <- file.path(tempdir(), "report.Rmd")
    file.copy("www/report_template.Rmd", temp_rmd, overwrite = TRUE)

    # Render with parameters
    rmarkdown::render(
      input = temp_rmd,
      output_file = file,
      params = list(
        data = filtered_data(),
        title = input$report_title
      ),
      envir = new.env(parent = globalenv())
    )
  }
)
```

### gt Table Export

```r
output$download_table <- downloadHandler(
  filename = function() {
    paste0("table_", Sys.Date(), ".html")
  },
  content = function(file) {
    gt_table <- filtered_data() %>%
      gt() %>%
      tab_header(title = "Clinical Summary")
    gtsave(gt_table, file)
  }
)
```

---

## Download Link vs Download Button

```r
# Button (styled as a button)
downloadButton("dl_btn", "Download", class = "btn-primary")

# Link (styled as a text link)
downloadLink("dl_link", "Download data")
```

Both use the same `downloadHandler()` in the server. Use `downloadButton()` for primary actions, `downloadLink()` for secondary or inline links.

---

## Module Pattern for Download

```r
# R/mod_download.R

mod_download_ui <- function(id) {
  ns <- NS(id)
  downloadButton(ns("download"), "Export CSV", class = "btn-sm btn-outline-primary")
}

mod_download_server <- function(id, data, filename_prefix = "export") {
  moduleServer(id, function(input, output, session) {
    output$download <- downloadHandler(
      filename = function() {
        paste0(filename_prefix, "_", Sys.Date(), ".csv")
      },
      content = function(file) {
        write.csv(data(), file, row.names = FALSE)
      }
    )
  })
}
```

Wire in the app:
```r
# ui.R
mod_download_ui("export")

# server.R
mod_download_server("export", data = filtered_data, filename_prefix = "patients")
```

---

## Progress Indicators During Upload Processing

```r
uploaded_data <- reactive({
  req(input$file)

  withProgress(message = "Processing file...", {
    incProgress(0.3, detail = "Reading file")
    raw <- read.csv(input$file$datapath)

    incProgress(0.5, detail = "Validating data")
    validated <- validate_data(raw)

    incProgress(0.2, detail = "Complete")
    validated
  })
})
```

---

## Common Pitfalls

- **`input$file` is NULL on app load** -- always guard with `req(input$file)` before reading
- **Temp file path changes** -- `input$file$datapath` points to a temporary file that Shiny manages; do not cache the path across reactive cycles
- **`accept` is advisory only** -- the `accept` parameter in `fileInput()` filters the OS file picker but does not enforce server-side; always validate the file type in the server
- **Download content function receives `file`** -- write to the `file` argument, not to a hardcoded path; Shiny manages the temp file and sends it to the browser
- **`downloadHandler` inside a module** -- the `downloadButton()` ID must be namespaced with `ns()` in the UI; the `output$id` in the server does not use `ns()` (standard module rules)
- **PDF rendering needs a temp copy** -- copy `.Rmd` templates to `tempdir()` before rendering to avoid write-permission errors on deployed servers
- **Excel upload requires readxl or openxlsx** -- base R cannot read `.xlsx`; add the package to `global.R` and `renv::snapshot()`
- **Large file uploads** -- Shiny's default max upload size is 5MB; increase with `options(shiny.maxRequestSize = 30 * 1024^2)` in `global.R`
- **`downloadButton()` in DT** -- to embed a download button inside a DT table row, use a custom `shinyInput()` helper, not a bare `downloadButton()` call
