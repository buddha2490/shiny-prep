# app.R — ExtendedTask: Shiny 1.8+ native async pattern
#
# ExtendedTask is Shiny's built-in, first-class solution for non-blocking tasks.
# It wraps a promise-returning function in a structured object that Shiny
# understands natively — no manual polling, no reactiveTimer needed.
#
# Recommended for new apps on Shiny >= 1.8.0.
#
# Pattern:
#   task <- ExtendedTask$new(function(...) future_promise({ ... }))
#   task$invoke(arg = value)    — start the task; returns immediately
#   task$status()               — reactive: "idle" | "running" | "success" | "error"
#   task$result()               — reactive: the resolved value (or error object)
#
# The function passed to ExtendedTask$new() must return a promise.
# task$invoke() passes named arguments to that function.

library(shiny)
library(future)
library(promises)

# Set up the future backend for future_promise()
plan(multisession)

ui <- fluidPage(
  h3("ExtendedTask: Shiny 1.8+ built-in async"),
  actionButton("go", "Run task (3 seconds)"),
  verbatimTextOutput("status_out"),
  verbatimTextOutput("result_out")
)

server <- function(input, output, session) {

  # --- Define the ExtendedTask once ---
  # The function receives the arguments you pass to task$invoke().
  # It must return a promise (here via future_promise).
  task <- ExtendedTask$new(function(x) {
    future_promise({
      Sys.sleep(3)    # Simulated slow computation in a background worker
      x^2 + 1
    })
  })

  # --- Invoke the task when the button is clicked ---
  observeEvent(input$go, {
    # Pass named arguments — they map to the function parameters above.
    # Calling invoke() while the task is already running is a no-op.
    task$invoke(x = 7)
  })

  # task$status() and task$result() are both reactive — they update
  # automatically when the background work finishes.
  output$status_out <- renderText({
    paste("Status:", task$status())
  })

  output$result_out <- renderText({
    # Guard: only show result once the task has succeeded
    req(task$status() == "success")
    paste("Result:", task$result())  # task$result() holds the resolved value
  })
}

shinyApp(ui, server)
