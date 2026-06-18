---
name: raw-shiny-app
description: Auto-invoked when creating or modifying a Shiny application without a framework (golem, rhino, or leprechaun). Governs file structure, module patterns, and best practices for lightweight Shiny apps and prototypes.
---

# Raw Shiny Application Skill

This skill governs Shiny applications built **without a framework** — no golem, rhino, or leprechaun. Use this for prototypes, small apps, internal tools, and situations where framework overhead is not justified.

**Project rule:** Always use the three-file layout (`global.R`, `ui.R`, `server.R`). Never use `app.R`.

## When to Use Raw Shiny

- Prototyping and proof-of-concept apps
- Small single-purpose tools (< 5 modules)
- Quick dashboards that won't grow into large production apps
- When the team is not familiar with any framework

## File Structure

```
myapp/
├── global.R               # packages, sources, constants — loaded once per process
├── ui.R                   # UI definition (assigns to `ui`)
├── server.R               # server logic (assigns to `server`)
├── R/                     # auto-sourced by Shiny (alphabetically)
│   ├── mod_data_import.R  # module files
│   ├── mod_summary.R
│   ├── mod_plot.R
│   └── utils.R            # shared helper functions
├── www/                   # static assets (served at /)
│   ├── style.css
│   ├── script.js
│   └── logo.png
└── data/                  # app data files
    └── reference.rds
```

**Important:** Files in `R/` are auto-sourced by Shiny when the app starts (Shiny 1.5+). They are sourced alphabetically — do not rely on sourcing order. You can also `source()` them explicitly from `global.R` if order matters.

## Module Pattern

Every module follows the `moduleServer()` / `NS()` pattern:

```r
# R/mod_data_import.R

# --- UI ----------------------------------------------------------------------
mod_data_import_ui <- function(id) {
  ns <- NS(id)
  tagList(
    fileInput(ns("file"), "Upload CSV"),
    tableOutput(ns("preview"))
  )
}

# --- Server ------------------------------------------------------------------
mod_data_import_server <- function(id) {
  moduleServer(id, function(input, output, session) {

    # --- Reactive data -------------------------------------------------------
    imported_data <- reactive({
      req(input$file)
      read.csv(input$file$datapath)
    })

    # --- Outputs -------------------------------------------------------------
    output$preview <- renderTable({
      head(imported_data(), 10)
    })

    # --- Return reactive for other modules -----------------------------------
    return(imported_data)
  })
}
```

Wire modules in `ui.R` and `server.R`:

```r
# ui.R
ui <- fluidPage(
  theme = bslib::bs_theme(version = 5),
  titlePanel("My App"),
  mod_data_import_ui("data_import"),
  mod_summary_ui("summary"),
  mod_plot_ui("plot")
)

# server.R
server <- function(input, output, session) {
  imported_data <- mod_data_import_server("data_import")
  summary_stats <- mod_summary_server("summary", data = imported_data)
  mod_plot_server("plot", data = imported_data, stats = summary_stats)
}
```

## Module Communication Patterns

### Returning reactive values

```r
# Producer module returns a reactive
mod_filter_server <- function(id, data) {
  moduleServer(id, function(input, output, session) {
    filtered <- reactive({
      data() %>% filter(group == input$selected_group)
    })
    return(filtered)
  })
}

# Consumer module receives it as a parameter
mod_table_server <- function(id, data) {
  moduleServer(id, function(input, output, session) {
    output$table <- renderTable({ data() })
  })
}
```

### Shared reactiveValues

For bidirectional communication or shared mutable state across modules:

```r
server <- function(input, output, session) {
  shared <- reactiveValues(
    selected_subject = NULL,
    current_visit = NULL
  )

  mod_subject_selector_server("selector", shared = shared)
  mod_patient_profile_server("profile", shared = shared)
}
```

## Static Assets

Place files in `www/` — they are served at the app root:

```r
# Reference in UI
tags$link(rel = "stylesheet", href = "style.css")
tags$script(src = "script.js")
tags$img(src = "logo.png", height = "50px")
```

## Package Loading

Load all packages in `global.R`. Functions are called unqualified. Use `package::function()` only for genuine namespace conflicts (per r-style rules).

```r
# global.R
library(shiny)
library(bslib)
library(dplyr)
library(ggplot2)
library(DT)
```

## Configuration

```r
# Simple approach
data_path <- Sys.getenv("DATA_PATH", "data/")

# config package approach
library(config)
config <- config::get()
data_path <- config$data_path
```

## Testing

### testServer() for module logic

```r
# tests/testthat/test-mod_data_import.R
library(testthat)
library(shiny)

source("R/mod_data_import.R")

testServer(mod_data_import_server, {
  session$setInputs(file = list(datapath = "test-data.csv"))
  expect_s3_class(imported_data(), "data.frame")
})
```

### shinytest2 for full integration

```r
library(shinytest2)

test_that("app loads", {
  app <- AppDriver$new(app_dir = ".", name = "basic-test")
  app$expect_screenshot()
  app$stop()
})
```

## Deployment

Raw Shiny apps deploy directly — no package build step:

```r
rsconnect::deployApp()           # shinyapps.io
rsconnect::deployApp(appDir = ".")  # Posit Connect
```

## When to Graduate to a Framework

Consider moving to golem, rhino, or leprechaun when:

- The app exceeds ~5 modules
- Multiple developers are contributing
- The app requires formal testing (testthat, shinytest2, Cypress)
- Deployment needs Docker, CI/CD, or version pinning
- The app needs configuration for multiple environments (dev/staging/prod)

## Key Conventions

1. **Three-file layout always** — `global.R`, `ui.R`, `server.R`. No `app.R`.
2. **Use `R/` directory** for modules and utilities — Shiny auto-sources them.
3. **Do not rely on `R/` sourcing order** — files are sourced alphabetically.
4. **Use `www/` for static assets** — CSS, JS, images.
5. **Every module gets its own file** named `mod_<name>.R`.
6. **Module functions follow `mod_<name>_ui` / `mod_<name>_server`** naming.
7. **Modules communicate via return values** (reactives), not global variables.
8. **Use `req()`** to guard against NULL/missing inputs.
9. **Keep business logic in separate utility files** (`R/utils.R`, `R/fct_*.R`) testable independently of Shiny.
