# app.R — crew: worker pool task orchestration
#
# {crew} manages a persistent pool of R worker processes (a "controller").
# Unlike future, crew gives you explicit control over the worker lifecycle
# and lets you submit many tasks to the pool, tracking them individually.
#
# Key objects and methods:
#   crew_controller_local(workers = n)  — create a local controller with n workers
#   controller$start()                  — launch the worker processes
#   controller$push(command, data, ...)  — submit a task (non-blocking)
#   controller$pop()                    — retrieve one completed result (non-blocking)
#   controller$terminate()              — shut down all workers
#
# push() and pop() are non-blocking.
# Use a reactiveTimer to poll pop() for completed results.
# Results come back as a one-row tibble; the expression value is in $result[[1]].

library(shiny)
library(crew)

ui <- fluidPage(
  h3("crew: worker pool task orchestration"),
  actionButton("go", "Submit task to crew worker"),
  verbatimTextOutput("status"),
  verbatimTextOutput("result")
)

server <- function(input, output, session) {
  status_msg <- reactiveVal("Idle.")
  result_msg <- reactiveVal("")

  # --- Create and start a controller with 2 persistent workers ---
  # crew_controller_local() uses local R processes; other backends exist
  # (e.g., crew.cluster for HPC, crew.aws.batch for cloud).
  controller <- crew_controller_local(workers = 2)
  controller$start()

  # Always terminate workers when the Shiny session ends
  onStop(function() controller$terminate())

  # Poll every 500ms for completed tasks
  poll_timer <- reactiveTimer(500)

  observeEvent(input$go, {
    status_msg("Task submitted...")
    result_msg("")

    # push() sends a task to the next available worker.
    # command: an expression to evaluate on the worker
    # data:    a named list of objects the expression can reference
    # name:    optional task label for tracking
    controller$push(
      command = {
        Sys.sleep(3)                       # Simulated work
        paste("Worker result:", x * 2)
      },
      data = list(x = 21),                # 'x' is available inside command
      name = "demo_task"
    )
  })

  # Check for completed tasks on each timer tick
  observe({
    poll_timer()

    # pop() retrieves one completed result or returns NULL if nothing is ready.
    # It is non-blocking — safe to call on every timer tick.
    completed <- controller$pop()

    if (!is.null(completed)) {
      # completed is a tibble; the expression's return value is in $result[[1]]
      result_msg(completed$result[[1]])
      status_msg("Done.")
    }
  })

  output$status <- renderText(status_msg())
  output$result <- renderText(result_msg())
}

shinyApp(ui, server)
