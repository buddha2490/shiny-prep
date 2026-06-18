# =============================================================================
# mod_safe_load.R — Tab 2: Safe data loading that never crashes the app
# =============================================================================
# The canonical with_error_handling() pattern. A "load" action can succeed or
# fail (simulated). On failure the app:
#   * logs the real error with a catalog code + incident id,
#   * shows the user a SAFE message plus the incident reference,
#   * keeps running (the reactive returns the previous/empty value).
#
# Compare the three scenarios in the dropdown — the app survives all of them.
# =============================================================================

mod_safe_load_ui <- function(id) {
  ns <- NS(id)
  bslib::card(
    bslib::card_header("Safe data load"),
    bslib::card_body(
      selectInput(
        ns("scenario"), "Scenario",
        choices = c(
          "Valid load"              = "ok",
          "Corrupt file (parse error)" = "corrupt",
          "Missing file"            = "missing"
        )
      ),
      actionButton(ns("load"), "Load data", class = "btn-primary"),
      hr(),
      DT::DTOutput(ns("table"))
    )
  )
}

#' @param id   Module id.
#' @param adsl A valid data frame to "load" in the success scenario.
mod_safe_load_server <- function(id, adsl) {
  moduleServer(id, function(input, output, session) {

    # Holds whatever was last successfully loaded. Starts empty so the table
    # has something to render before the first (and after a failed) load.
    loaded <- reactiveVal(adsl[0, , drop = FALSE])

    observeEvent(input$load, {
      result <- with_error_handling(
        {
          # Simulate the three outcomes. In a real app this is read.csv(),
          # a DB query, haven::read_sas(), etc.
          switch(
            input$scenario,
            ok      = adsl,
            corrupt = stop("Unexpected token at line 42 while parsing dataset"),
            missing = stop("File not found: /data/adsl.sas7bdat")
          )
        },
        code     = if (input$scenario == "corrupt") "ERR-DATA-002" else "ERR-DATA-001",
        context  = list(module = "safe_load", scenario = input$scenario),
        fallback = NULL,          # NULL => keep the previously loaded value
        session  = session
      )

      if (!is.null(result)) {
        loaded(result)
        log_event("INFO", "Data loaded",
                  code = "DATA-LOAD", module = "safe_load",
                  rows = nrow(result))
      }
    })

    output$table <- DT::renderDT({
      DT::datatable(loaded(), options = list(pageLength = 5), rownames = FALSE)
    })
  })
}
