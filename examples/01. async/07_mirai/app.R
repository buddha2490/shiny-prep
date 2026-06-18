# app.R — mirai: minimalist async evaluation
#
# {mirai} ("future" in Japanese) is a lightweight, high-performance async
# framework built on nanonext (nanomsg/NNG sockets). It's faster and lower
# overhead than {future} for many workloads.
#
# Key functions:
#   daemons(n)           — start n persistent background daemon processes
#   mirai(expr, ...)     — evaluate expr asynchronously; returns a mirai object
#                          NOTE: unlike future, variables are NOT auto-detected.
#                          You MUST pass everything explicitly as named arguments.
#   m$data               — the result; is the special value `unresolved` while running
#   unresolved(m)        — TRUE while still running, FALSE when done
#
# Shiny integration: use reactiveTimer to poll unresolved() and retrieve $data.

library(shiny)
library(mirai)

# Start 2 daemon processes at app startup.
# These persist across tasks — faster than spawning a new process each time.
# daemons(0) shuts them all down.
daemons(2)

ui <- fluidPage(
  h3("mirai: minimalist async evaluation"),
  actionButton("go", "Run async task (2 seconds)"),
  verbatimTextOutput("status"),
  verbatimTextOutput("result")
)

server <- function(input, output, session) {
  active_mirai <- reactiveVal(NULL)  # Holds the running mirai object
  status_msg   <- reactiveVal("Idle.")
  result_msg   <- reactiveVal("")

  # Poll every 300ms to check if the mirai has resolved
  poll_timer <- reactiveTimer(300)

  observeEvent(input$go, {
    status_msg("Sent to daemon...")
    result_msg("")

    x <- 5  # Local variable to pass into the async context

    # mirai() evaluates the expression in a daemon process.
    # IMPORTANT: variables from the current environment are NOT automatically
    # available inside mirai(). Pass them as explicit named arguments.
    m <- mirai(
      { Sys.sleep(2); x^3 },  # Expression to run in the daemon
      x = x                    # 'x' is explicitly passed into the daemon
    )

    active_mirai(m)
  })

  # On each timer tick, check whether the mirai has a result yet
  observe({
    poll_timer()

    m <- active_mirai()
    if (is.null(m)) return()

    # unresolved() returns TRUE while the daemon is still working.
    # When it returns FALSE, $data holds the result.
    if (!unresolved(m)) {
      result_msg(paste("Result:", m$data))
      status_msg("Done.")
      active_mirai(NULL)  # Clear so polling stops
    }
  })

  output$status <- renderText(status_msg())
  output$result <- renderText(result_msg())
}

shinyApp(ui, server)
