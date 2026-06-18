# app.R — promises: .then() and .catch()
#
# The {promises} package brings JavaScript-style async programming to R.
# A promise is a placeholder for a value that will be available in the future.
#
# Core methods:
#   promise_resolve(value) — creates an already-resolved promise
#   promise_reject(reason) — creates an already-rejected promise
#   then(onFulfilled)      — runs a function when the promise resolves
#   catch(onRejected)      — runs a function when the promise rejects (errors)
#   %>%                    — regular pipe works here; there is also %...>% for
#                            promise-specific chaining inside render functions
#
# On their own, promises don't give you parallelism — combine with {future}
# (see 02_future_promise) to actually run code off the main R thread.

library(shiny)
library(promises)

ui <- fluidPage(
  h3("promises: .then() and .catch()"),
  actionButton("good", "Resolve (success path)"),
  actionButton("bad",  "Reject (error path)"),
  verbatimTextOutput("result")
)

server <- function(input, output, session) {
  result_val <- reactiveVal("Click a button...")

  # --- Success path ---
  observeEvent(input$good, {
    # promise_resolve() creates a promise that is already resolved with a value.
    # .then() receives that value and runs its function.
    promise_resolve(42) %>%
      then(function(value) {
        result_val(paste("Resolved with:", value))
      }) %>%
      catch(function(err) {
        # .catch() is skipped because no error occurred
        result_val(paste("Error (won't show):", err))
      })
  })

  # --- Error path ---
  observeEvent(input$bad, {
    # promise_reject() creates a promise that has already failed.
    # .then() is skipped; .catch() handles the reason.
    promise_reject("something went wrong") %>%
      then(function(value) {
        # This never runs — the promise was rejected before reaching .then()
        result_val("This never shows")
      }) %>%
      catch(function(err) {
        result_val(paste("Caught error:", err))
      })
  })

  output$result <- renderText(result_val())
}

shinyApp(ui, server)
