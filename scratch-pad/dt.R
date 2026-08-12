# --- Paginated-column DT module -----------------------------------------------
# Splits a wide dataset into column "pages" so the table stays readable.
# subjectId is always shown as the anchor column on every page.

library(DT)

# --- Module UI ----------------------------------------------------------------

paginated_dt_ui <- function(id) {
  ns <- NS(id)
  tagList(
    div(
      class = "d-flex align-items-center gap-3 mb-3",
      radioButtons(
        ns("col_page"), "Column Page:",
        choices  = c("Page 1", "Page 2"),
        selected = "Page 1",
        inline   = TRUE
      )
    ),
    DTOutput(ns("table"))
  )
}

# --- Module server ------------------------------------------------------------

paginated_dt_server <- function(id, data, id_col = "subjectId") {
  moduleServer(id, function(input, output, session) {

    # --- Split non-ID columns into two halves ---------------------------------
    other_cols <- setdiff(names(data), id_col)
    midpoint   <- ceiling(length(other_cols) / 2)
    page_cols  <- list(
      "Page 1" = c(id_col, other_cols[1:midpoint]),
      "Page 2" = c(id_col, other_cols[(midpoint + 1):length(other_cols)])
    )

    # --- Reactive subset of columns -------------------------------------------
    display_data <- reactive({
      req(input$col_page)
      data[, page_cols[[input$col_page]], drop = FALSE]
    })

    # --- Render DT ------------------------------------------------------------
    output$table <- renderDT({
      datatable(
        display_data(),
        rownames  = FALSE,
        filter    = "top",
        class     = "display compact nowrap",
        options   = list(
          pageLength   = 25,
          scrollX      = TRUE,
          dom          = "lftip",
          autoWidth    = TRUE,
          lengthMenu   = list(c(10, 25, 50, -1), c("10", "25", "50", "All"))
        )
      )
    })
  })
}
