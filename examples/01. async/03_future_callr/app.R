# app.R — future.callr: using callr as the future backend
#
# {future.callr} provides plan(callr), an alternative future backend.
# The usage pattern (future_promise + .then/.catch) is IDENTICAL to 02_future_promise.
# The difference is in how worker processes are created:
#
#   plan(multisession)  — reuses a persistent pool of R socket workers
#                         (worker state can carry over between tasks)
#
#   plan(callr)         — launches a brand-new, clean R process for EACH task
#                         (no leftover globals, safer package isolation)
#
# When to prefer callr backend:
#   - You need a guaranteed clean R environment per task
#   - A package misbehaves in forked/socket processes (e.g., database drivers)
#   - You want process-level isolation for security or reproducibility

library(shiny)
library(future)
library(future.callr)   # Provides plan(callr)
library(promises)

# Use the callr backend — each task gets a fresh R process
plan(callr)

ui <- fluidPage(
  h3("future.callr: fresh R process per task"),
  actionButton("go", "Run (3-second task)"),
  verbatimTextOutput("result")
)

server <- function(input, output, session) {
  result_val <- reactiveVal("Waiting...")

  observeEvent(input$go, {
    result_val("Running in a fresh callr process...")

    # Local variable to use inside the future.
    # {future} automatically detects it as a global dependency and ships it
    # to the new process — you don't need to pass it manually.
    multiplier <- 10

    future_promise({
      Sys.sleep(3)
      # 'multiplier' was detected as a dependency and is available here
      paste("Result:", 6 * multiplier)
    }) %>%
      then(function(value) result_val(value)) %>%
      catch(function(err) result_val(paste("Error:", conditionMessage(err))))
  })

  output$result <- renderText(result_val())
}

shinyApp(ui, server)
