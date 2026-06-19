# =============================================================================
# mod_async_task.R — Tab 4: Error handling in async (ExtendedTask + mirai)
# =============================================================================
# Errors in a background worker are special: they surface when you READ the
# result, not where the work runs, and they must not be lost. The pattern:
#
#   * Run the work in a mirai() inside an ExtendedTask.
#   * Watch task$status(). When it becomes "error", read task$result() inside
#     with_error_handling() — accessing the result re-throws the worker's error,
#     which we then log (code + incident id) and surface to the user.
#   * The session never crashes; the button is simply re-enabled.
#
# Requires daemons to be running (set up in global.R via mirai::daemons()).
# =============================================================================

mod_async_task_ui <- function(id) {
  ns <- NS(id)
  bslib::card(
    bslib::card_header("Async task with error handling"),
    bslib::card_body(
      p("Runs a 1.5s background job. Tick the box to make the worker fail."),
      checkboxInput(ns("boom"), "Make the background task fail"),
      input_task_button(ns("run"), "Run background task"),
      hr(),
      verbatimTextOutput(ns("status"))
    )
  )
}

#' @param id Module id.
mod_async_task_server <- function(id) {
  moduleServer(id, function(input, output, session) {

    # The ExtendedTask wraps a mirai. Dependencies are passed in explicitly via
    # the `...` of mirai() — the worker is a clean process and sees nothing else.
    task <- ExtendedTask$new(function(should_fail) {
      mirai::mirai(
        {
          Sys.sleep(1.5)
          if (should_fail) stop("Worker ran out of memory during model fit")
          paste("Completed at", format(Sys.time(), "%H:%M:%S"))
        },
        should_fail = should_fail
      )
    }) %>%
      bslib::bind_task_button("run")

    observeEvent(input$run, {
      log_event("INFO", "Background task submitted",
                code = "ASYNC-SUBMIT", module = "async_task")
      task$invoke(should_fail = isTRUE(input$boom))
    })

    # Watch the task status. On "error", reading result() re-throws the worker
    # error; with_error_handling() logs + notifies and keeps the app alive.
    observeEvent(task$status(), {
      if (task$status() == "error") {
        with_error_handling(
          task$result(),                # re-throws the worker's error
          code    = "ERR-ASYNC-001",
          context = list(module = "async_task"),
          session = session
        )
      }
    })

    output$status <- renderText({
      switch(
        task$status(),
        initial = "Idle — press the button.",
        running = "Running in the background…",
        success = task$result(),
        error   = "Task failed — see the notification (the app is still running)."
      )
    })
  })
}
