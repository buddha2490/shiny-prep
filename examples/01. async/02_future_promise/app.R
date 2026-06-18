# app.R — future + promises: non-blocking async computation
#
# This is the core async pattern for Shiny:
#   future_promise() runs an expression in a separate R worker process.
#   It returns a promise immediately — the Shiny session stays responsive
#   while the background work runs.
#
# Without this, a Sys.sleep(5) inside observeEvent() would block the ENTIRE
# Shiny process — no other user could interact with the app during that time.
#
# plan() sets the parallelism backend for {future}:
#   plan(multisession) — a pool of background R worker processes (socket cluster)
#   Call plan() once at app startup, NOT inside server().

library(shiny)
library(future)
library(promises)

# Set up the future backend at app startup.
# multisession starts R worker processes that persist across tasks.
plan(multisession)

ui <- fluidPage(
  h3("future + promises: non-blocking computation"),
  p("Click 'Start Task', then immediately click 'Still Alive?' — the UI stays responsive."),
  actionButton("start", "Start (5-second task)"),
  actionButton("ping",  "Still alive?"),
  verbatimTextOutput("task_result"),
  verbatimTextOutput("ping_result")
)

server <- function(input, output, session) {
  task_result <- reactiveVal("Not started.")
  ping_count  <- reactiveVal(0L)

  observeEvent(input$start, {
    task_result("Running in background worker...")

    # future_promise() sends the expression to a worker process and returns
    # a promise immediately. Shiny can handle other events while it runs.
    future_promise({
      Sys.sleep(5)            # Simulated slow computation (runs off main thread)
      "Finished! Result = 99"
    }) %>%
      then(function(value) {
        # .then() fires when the background work is done
        task_result(value)
      }) %>%
      catch(function(err) {
        task_result(paste("Error:", conditionMessage(err)))
      })
  })

  # This observer shows the main thread is NOT blocked during the task
  observeEvent(input$ping, {
    ping_count(ping_count() + 1L)
  })

  output$task_result <- renderText(task_result())
  output$ping_result <- renderText(paste("Ping count:", ping_count()))
}

shinyApp(ui, server)
