# =============================================================================
# mod_log_demo.R — Tab 1: Logging basics
# =============================================================================
# Demonstrates the log4r levels via get_logger()/log_event(), and tails the log
# file so you can see exactly what was written. Shows the threshold behaviour:
# with LOG_LEVEL=INFO, DEBUG lines are discarded.
# =============================================================================

mod_log_demo_ui <- function(id) {
  ns <- NS(id)
  bslib::card(
    bslib::card_header("Logging at each level"),
    bslib::card_body(
      p(
        "Each button writes one line through ", code("log_event()"),
        ". Lines below the logger threshold are discarded — try setting ",
        code("LOG_LEVEL=DEBUG"), " vs ", code("LOG_LEVEL=WARN"), "."
      ),
      textInput(ns("msg"), "Message", value = "Manual log entry"),
      div(
        class = "d-flex gap-2 flex-wrap",
        actionButton(ns("debug"), "DEBUG", class = "btn-secondary"),
        actionButton(ns("info"),  "INFO",  class = "btn-info"),
        actionButton(ns("warn"),  "WARN",  class = "btn-warning"),
        actionButton(ns("error"), "ERROR", class = "btn-danger")
      ),
      hr(),
      strong("Log file tail:"),
      verbatimTextOutput(ns("log_tail"))
    )
  )
}

#' @param id      Module id.
#' @param log_file Path to the log file to tail (from global.R).
mod_log_demo_server <- function(id, log_file) {
  moduleServer(id, function(input, output, session) {

    # A trigger so the tail refreshes after every button press.
    bump <- reactiveVal(0)
    emit <- function(level) {
      log_event(level, input$msg, code = "LOG-DEMO", module = "log_demo")
      bump(bump() + 1)
    }

    observeEvent(input$debug, emit("DEBUG"))
    observeEvent(input$info,  emit("INFO"))
    observeEvent(input$warn,  emit("WARN"))
    observeEvent(input$error, emit("ERROR"))

    output$log_tail <- renderText({
      bump()  # take a dependency so the view updates on each emit
      if (!file.exists(log_file)) return("(log file not created yet)")
      lines <- readLines(log_file, warn = FALSE)
      paste(utils::tail(lines, 15), collapse = "\n")
    })
  })
}
