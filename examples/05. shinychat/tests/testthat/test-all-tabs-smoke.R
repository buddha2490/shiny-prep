# =============================================================================
# test-all-tabs-smoke.R — startup smoke test across ALL navbar tabs
# =============================================================================
# WHY THIS EXISTS
# The first E2E test (test-basic-chat-stream.R) only ever loads Tab 1. A whole
# class of runtime failures — an output that errors on render, an observer that
# crashes on first flush, a NULL client cascading into a cryptic
# "object of type 'closure' is not subsettable" — lives on the OTHER tabs and
# sails straight through a one-tab test. This smoke test launches the real app,
# visits every nav panel, and asserts that NOTHING logged a FATAL or ERROR and
# the browser console stayed clean.
#
# It is the cheap, broad safety net: it does not assert feature behaviour (the
# per-feature tests do that) — it only asserts every tab can be opened without
# the app throwing. For a multi-tab app, ship one of these.
#
# Gated on ANTHROPIC_API_KEY because the server builds an ellmer client at
# startup. Run it the SAME way as the other AppDriver tests: from the repo root
# with renv active (NOT_CRAN=true), so packages resolve to the locked library.
# =============================================================================

library(shinytest2)
library(testthat)

testthat::skip_if(
  Sys.getenv("ANTHROPIC_API_KEY") == "",
  message = "ANTHROPIC_API_KEY not set — skipping live API smoke test"
)

APP_DIR  <- file.path("..", "..")
LOG_FILE <- file.path(APP_DIR, "logs", "shinychat-app.log")

# All five nav panels, by their `value` (set in ui.R) / label.
ALL_TABS <- c(
  "Basic Chat", "Module Pattern", "Markdown Stream",
  "Advanced ellmer", "Control Panel"
)

# --- Helper: lines appended to the app log since a recorded baseline ----------
log_lines_since <- function(baseline) {
  if (!file.exists(LOG_FILE)) return(character(0))
  all_lines <- readLines(LOG_FILE, warn = FALSE)
  if (length(all_lines) <= baseline) return(character(0))
  all_lines[(baseline + 1L):length(all_lines)]
}

test_that("every navbar tab opens without logging a FATAL or ERROR", {
  # Baseline: how many log lines exist before we launch.
  baseline <- if (file.exists(LOG_FILE)) length(readLines(LOG_FILE, warn = FALSE)) else 0L

  app <- AppDriver$new(
    app_dir      = APP_DIR,
    name         = "all-tabs-smoke",
    seed         = 42L,
    load_timeout = 90000L,
    timeout      = 30000L
  )
  on.exit(app$stop(), add = TRUE)

  # Visit each tab and let its outputs/observers flush.
  for (tab in ALL_TABS) {
    app$set_inputs(main_nav = tab)
    app$wait_for_idle(timeout = 15000L)
  }

  # --- Assert: no FATAL/ERROR lines were appended to the app log -------------
  new_lines <- log_lines_since(baseline)
  bad <- grep("FATAL|ERROR", new_lines, value = TRUE)
  expect_identical(
    bad, character(0),
    info = paste0(
      "App logged FATAL/ERROR while opening tabs:\n",
      paste(bad, collapse = "\n")
    )
  )

  # --- Assert: the browser console logged no errors --------------------------
  logs <- as.data.frame(app$get_logs())
  if (nrow(logs) > 0 && "level" %in% names(logs)) {
    console_errors <- logs$message[!is.na(logs$level) & logs$level == "error"]
    expect_identical(
      console_errors, character(0),
      info = paste0(
        "Browser console errors:\n", paste(console_errors, collapse = "\n")
      )
    )
  } else {
    succeed("No structured console logs to inspect.")
  }
})
