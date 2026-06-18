# =============================================================================
# mod_validation.R — Tab 3: req() vs validate(need()) vs caught error
# =============================================================================
# Three DIFFERENT tools for three DIFFERENT situations. They are not
# interchangeable (see rules/error-handling.md):
#
#   req()             Input not ready yet. SILENT — no message, no log. The
#                     output just stays blank. NOT an error.
#   validate(need())  Input present but INVALID for a known, expected reason
#                     (out of range, empty selection). Shows a tidy in-output
#                     message to the user. Expected, so we don't log it as ERROR.
#   with_error_handling()  Something UNEXPECTED blew up. Log it with a code +
#                     incident id and show a safe notification.
# =============================================================================

mod_validation_ui <- function(id) {
  ns <- NS(id)
  bslib::card(
    bslib::card_header("Input validation & output errors"),
    bslib::card_body(
      selectInput(ns("arm"), "Treatment arm (blank = not ready)",
                  choices = c("", "Placebo", "Drug A", "Drug B")),
      numericInput(ns("n"), "Sample size (must be > 0)", value = 10),
      checkboxInput(ns("boom"), "Force an unexpected error in the calculation"),
      hr(),
      verbatimTextOutput(ns("summary"))
    )
  )
}

#' @param id Module id.
mod_validation_server <- function(id) {
  moduleServer(id, function(input, output, session) {

    output$summary <- renderText({
      # 1. req(): arm not chosen yet => stay silent and blank. No log entry.
      req(input$arm)

      # 2. validate(need()): a known, user-correctable problem. Tidy message,
      #    no ERROR log — this is expected user behaviour, not a fault.
      validate(
        need(is.numeric(input$n) && input$n > 0,
             "Sample size must be a positive number.")
      )

      # 3. with_error_handling(): the genuinely unexpected. If the computation
      #    throws, it is logged with a code + incident id and a notification is
      #    shown; the output falls back to a safe placeholder.
      with_error_handling(
        {
          if (isTRUE(input$boom)) {
            stop("Singular matrix in variance estimator")
          }
          sprintf("Arm: %s  |  n = %d  |  power ≈ %.2f",
                  input$arm, input$n, 1 - 0.8^input$n)
        },
        code     = "ERR-CALC-001",
        context  = list(module = "validation", arm = input$arm),
        fallback = "(calculation unavailable — see notification)",
        session  = session
      )
    })
  })
}
