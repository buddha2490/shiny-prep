# app.R — callr: direct background R processes
#
# {callr} runs R code in a completely separate R process without the
# future/promise abstraction layer. Two main functions:
#
#   callr::r(func, args)     — SYNCHRONOUS: blocks until done, returns the value
#   callr::r_bg(func, args)  — ASYNC: returns a process handle immediately
#
# In Shiny, use r_bg() so you don't block the session.
# r_bg() gives you a process handle object with methods:
#   $is_alive()    — TRUE while running, FALSE when done
#   $get_result()  — retrieves the return value (blocks if still running)
#   $kill()        — terminate the process
#
# Since r_bg() doesn't use promises, you need a reactiveTimer to poll
# the process and check when it has finished.

library(shiny)
library(callr)

ui <- fluidPage(
  h3("callr: r_bg() background process with polling"),
  actionButton("go", "Start background job"),
  verbatimTextOutput("status"),
  verbatimTextOutput("result")
)

server <- function(input, output, session) {
  bg_process <- reactiveVal(NULL)   # Holds the r_bg() process handle
  status_msg <- reactiveVal("Idle")
  result_msg <- reactiveVal("")

  # Poll every 500ms to check whether the background process has finished.
  # reactiveTimer() invalidates its dependents on each tick.
  poll_timer <- reactiveTimer(500)

  observeEvent(input$go, {
    status_msg("Launching background R process...")
    result_msg("")

    # r_bg() starts a new R process running func() with the given args.
    # It returns immediately — the process runs independently.
    # Note: func() runs in a clean R environment; it cannot see variables
    # from the server() closure. Pass everything through args.
    proc <- callr::r_bg(
      func = function(n) {
        Sys.sleep(n)                    # Simulated work in the new process
        paste("Background result:", n^2)
      },
      args = list(n = 4)               # Passed as arguments to func
    )

    bg_process(proc)
    status_msg("Process running...")
  })

  # On each timer tick, check whether the background process has finished.
  observe({
    poll_timer()   # Take a dependency on the timer so this re-runs every 500ms

    proc <- bg_process()
    if (is.null(proc)) return()

    if (proc$is_alive()) {
      # Still running — nothing to do yet
      status_msg("Process running...")
    } else {
      # Process has finished — retrieve the return value
      value <- tryCatch(
        proc$get_result(),
        error = function(e) paste("Process error:", e$message)
      )
      result_msg(value)
      status_msg("Done.")
      bg_process(NULL)  # Clear the handle so polling stops
    }
  })

  output$status <- renderText(status_msg())
  output$result <- renderText(result_msg())
}

shinyApp(ui, server)
