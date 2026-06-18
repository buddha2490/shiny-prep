# Shiny App Structure

All Shiny apps in this project use the **three-file layout**: `global.R`, `ui.R`, and `server.R`. Never use `app.R` — do not create it, do not suggest it.

## File Responsibilities

### `global.R`
Runs once at startup, before the app launches. Put here:

- `library()` calls for all packages the app needs
- Sourcing of module files and helper scripts (`source("R/mod_*.R")`)
- Data loading (static datasets read from disk)
- Constants and lookup tables used across UI and server
- Database connection setup (if applicable)

```r
library(shiny)
library(dplyr)
library(ggplot2)

source("R/mod_data_table.R")
source("R/utils_filters.R")

# --- Constants ---
APP_TITLE <- "My App"
```

**Rules:**
- No reactive code here — `global.R` runs outside the session context
- No `shinyApp()` call
- Keep it short; if data prep is complex, move it to a sourced script in `R/`

---

### `ui.R`
Defines the user interface. Must contain (or return) a single UI object.

```r
ui <- fluidPage(
  titlePanel("My App"),
  sidebarLayout(
    sidebarPanel(...),
    mainPanel(...)
  )
)
```

**Rules:**
- The file must assign the UI to the variable `ui` — Shiny discovers it by name
- No server logic, no `reactive()`, no `observe()`
- Module UI calls (`mod_patient_listing_ui("mod1")`) belong here, not in `server.R`
- Input IDs that are referenced in `server.R` must be defined here

---

### `server.R`
Defines the server function. Must contain (or return) a `server` function with signature `function(input, output, session)`.

```r
server <- function(input, output, session) {

  # --- Module servers ---
  mod_data_table_server("mod1")

  # --- Reactives ---
  filtered_data <- reactive({
    req(input$group)
    data %>% filter(group == input$group)
  })

  # --- Outputs ---
  output$plot <- renderPlot({
    ggplot(filtered_data(), aes(x = visit, y = value)) +
      geom_boxplot()
  })
}
```

**Rules:**
- The file must assign the server function to the variable `server` — Shiny discovers it by name
- No `shinyApp()` call
- No `library()` calls — all package loading happens in `global.R`
- No data loading — all datasets are loaded in `global.R`

---

## Directory Layout

```
my-app/
  global.R          # packages, sources, constants
  ui.R              # UI definition
  server.R          # server logic
  R/
    mod_*.R         # module files (sourced in global.R)
    utils_*.R       # helper functions (sourced in global.R)
  www/
    custom.css      # static assets served by Shiny
  tests/
    testthat/
    shinytest2/
```

