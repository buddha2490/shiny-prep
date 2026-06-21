# helper-shiny-smoke.R --------------------------------------------------------
#
# Reusable AppDriver assertion: "did the running app throw anything?"
# Drop this file into any app's tests/testthat/ — testthat auto-sources
# helper-*.R before the tests, and it runs in the TEST process (it inspects the
# app via the AppDriver handle; it is not loaded inside the app).
#
# WHY THIS EXISTS — the lesson that motivated it
# A naive smoke test asserts the *absence of a signal that may not fire*:
#   * "browser console has no errors"  — a Shiny RENDER error is caught by Shiny
#     and shown in the output element; it is NOT written to the browser console.
#   * "the output element is non-empty" — a failed render leaves a non-empty
#     `shiny-output-error` <div> behind, so "got some HTML" is a FALSE PASS.
# Both checks sailed past a real `renderDT` crash (formatStyle referencing a
# renamed column) and reported green while the tab was broken.
#
# The signal that DOES fire on a render error is the app's STDERR — Shiny prints
# "Warning: Error in <fn>: ..." there, and shinytest2 captures it in
# `app$get_logs()` under `location == "shiny"`. THAT is the universal catch:
# it needs no output IDs and no per-widget markers. This helper asserts on it,
# plus the DOM error class and the browser console, so a render exception cannot
# pass silently.

`%||%` <- function(a, b) if (is.null(a)) b else a   # base since R 4.4; defined for safety

#' Assert the running app logged no Shiny/JS errors and no output is in an error state.
#'
#' Call this AFTER visiting every tab and exercising each tab's primary
#' interaction (a render error only fires when its reactive actually executes).
#'
#' @param app a live `shinytest2::AppDriver`
#' @return the app, invisibly
expect_no_shiny_errors <- function(app) {
  logs <- as.data.frame(app$get_logs())
  have <- nrow(logs) > 0 && all(c("location", "message") %in% names(logs))

  # 1. Shiny stderr — render/runtime exceptions land here even when they never
  #    reach the browser console. This is the catch the "console clean" test
  #    misses. Match Shiny's printed forms: "Error in <fn>:" and "Error:".
  shiny_err <- character(0)
  if (have) {
    shiny_err <- logs$message[logs$location == "shiny" &
                                grepl("Error( in |:)", logs$message)]
  }
  testthat::expect_identical(
    shiny_err, character(0),
    info = paste0("App logged Shiny errors:\n", paste(shiny_err, collapse = "\n"))
  )

  # 2. Browser console errors (client-side JS failures).
  if (have && "level" %in% names(logs)) {
    console_err <- logs$message[!is.na(logs$level) & logs$level == "error" &
                                  logs$location == "chromote"]
    testthat::expect_identical(
      console_err, character(0),
      info = paste0("Browser console errors:\n",
                    paste(console_err, collapse = "\n"))
    )
  }

  # 3. DOM — no output rendered into a `shiny-output-error` state.
  #    get_html() returns NULL when the selector matches nothing.
  dom_err <- tryCatch(app$get_html(".shiny-output-error"),
                      error = function(e) NULL)
  testthat::expect_null(
    dom_err,
    info = paste0("An output is in an error state:\n", dom_err %||% "")
  )

  invisible(app)
}
