# =============================================================================
# test-all-tabs-smoke.R — startup smoke test across ALL navbar tabs
# =============================================================================
# WHY THIS EXISTS (testing rule 6)
# The per-module testServer tests prove reactive *logic*; they do not prove an
# output renders or an observer survives its first flush in a real browser. The
# whole point of this reference app is the rendered styling, so the gate that
# matters is "every tab renders without throwing."
#
# This launches the REAL app, visits every nav panel, exercises the one
# interactive tab (the Computed-styles slider re-renders the row UI — a render
# error only fires when its reactive actually executes), and asserts the Shiny
# stderr / DOM / browser console stayed clean. See helper-shiny-smoke.R for why
# "console clean + non-empty HTML" is NOT a sufficient check.
#
# Run it the documented way (testing rule 7): from the repo root with renv
# active and NOT_CRAN=true, so packages resolve to the locked library.
# =============================================================================

library(shinytest2)
library(testthat)

APP_DIR <- file.path("..", "..")

# nav_panel values default to their titles; the navbar input id is "nav".
ALL_TABS <- c("Overview", "Theme", "Utility classes", "Custom components",
              "Computed styles", "Modules & namespacing")

test_that("every navbar tab opens and renders with a clean browser console", {
  app <- AppDriver$new(
    app_dir      = APP_DIR,
    name         = "css-styling-all-tabs-smoke",
    seed         = 42L,
    load_timeout = 90000L,   # generous: cold headless-Chrome + font_google build
    timeout      = 30000L
  )
  on.exit(app$stop(), add = TRUE)

  # Visit each tab and let its outputs/observers flush.
  for (tab in ALL_TABS) {
    app$set_inputs(nav = tab)
    app$wait_for_idle(timeout = 15000L)
  }

  # --- Exercise the one interactive tab -------------------------------------
  # The Computed-styles slider re-renders the per-subject UI; sweep it across
  # the range so the renderUI executes at several thresholds.
  app$set_inputs(nav = "Computed styles")
  app$wait_for_idle(timeout = 15000L)
  app$set_inputs(`computed-threshold` = 0);   app$wait_for_idle(timeout = 10000L)
  app$set_inputs(`computed-threshold` = 100); app$wait_for_idle(timeout = 10000L)
  app$set_inputs(`computed-threshold` = 50);  app$wait_for_idle(timeout = 10000L)

  # --- Assert: nothing threw (the universal gate) ---------------------------
  expect_no_shiny_errors(app)

  # --- Assert: the namespaced metric values positively rendered -------------
  # Positive proof the Rule 6 namespaced elements exist with their ids in the
  # rendered HTML (the bare ids would NOT appear).
  for (sel in c("#metric_enrolled-value", "#metric_completed-value")) {
    html <- app$get_html(sel)
    expect_true(
      !is.null(html) && nchar(html) > 10,
      info = sprintf("Namespaced element '%s' did not render", sel)
    )
  }

  # --- Assert: the computed-styles UI actually drew rows ---------------------
  rows <- app$get_html("#computed-rows")
  expect_true(!is.null(rows) && grepl("pct-bar-fill", rows),
              info = "Computed-styles rows did not render the data-bound bars")
})
