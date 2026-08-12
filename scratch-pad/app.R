# --- Demo app for paginated-column DT -----------------------------------------

library(shiny)
library(bslib)
library(DT)

source("dt.R")

hcru <- readRDS("data.rds")

ui <- page_sidebar(
  title = "HCRU Baseline — Paginated Column Table",
  theme = bs_theme(version = 5, bootswatch = "flatly"),
  sidebar = sidebar(
    width = 250,
    h5("About"),
    p("This table splits 25 columns across two pages.",
      "subjectId appears on both pages as the row anchor."),
    hr(),
    p(class = "text-muted small",
      paste("Rows:", nrow(hcru)),
      br(),
      paste("Columns:", ncol(hcru)))
  ),
  card(
    card_header("HCRU Baseline Data"),
    card_body(
      paginated_dt_ui("hcru_table")
    )
  )
)

server <- function(input, output, session) {
  paginated_dt_server("hcru_table", data = hcru)
}

shinyApp(ui, server)
