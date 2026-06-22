# =============================================================================
# test-app-smoke.R — startup smoke test for the running animation app
# =============================================================================
# WHY THIS EXISTS (testing rule 6)
# The sim-engine unit tests prove the physics; they do not prove the wired app
# renders or that the animation loop survives its first flush in a real browser.
# A render error in renderPlotly, a bad plotlyProxy restyle, or an observer that
# crashes on first tick lives only in the running app and sails past the unit
# tests.
#
# This launches the REAL app, exercises the headline interaction (start the
# simulation, let it run, pause, reset), and asserts nothing threw and the two
# plot outputs actually rendered. Run it the documented way (testing rule 7):
# from the repo root with renv active and NOT_CRAN=true.
# =============================================================================

library(shinytest2)
library(testthat)

APP_DIR <- file.path("..", "..")

test_that("the app starts, animates, pauses and resets with no errors", {
  app <- AppDriver$new(
    app_dir      = APP_DIR,
    name         = "annimation-smoke",
    seed         = 7L,
    load_timeout = 90000L,
    timeout      = 30000L
  )
  on.exit(app$stop(), add = TRUE)

  # A small swarm with a wide door + fast stepping so escapes happen quickly.
  app$set_inputs(n_points = 30, door_h = 60, steps_per_frame = 40)
  app$wait_for_idle(timeout = 15000L)

  # --- Headline interaction: run the simulation -----------------------------
  # NOTE: while running, the invalidateLater loop keeps Shiny perpetually busy,
  # so wait_for_idle() would never return. We let it animate via a plain sleep,
  # then PAUSE before any wait_for_idle() so the reactive graph can settle.
  app$click("toggle")                       # Start
  Sys.sleep(4)                              # let many frames + escapes fire
  app$click("toggle")                       # Pause — now the app can go idle
  app$wait_for_idle(timeout = 10000L)

  # At least one point should have escaped by now.
  escaped <- as.integer(app$get_value(output = "vb_escaped"))
  expect_gt(escaped, 0)

  app$click("reset")                        # Reset
  app$wait_for_idle(timeout = 10000L)

  # --- Assert: nothing threw (the universal gate) ---------------------------
  expect_no_shiny_errors(app)

  # --- Assert: both plot outputs positively rendered ------------------------
  for (out in c("arena", "hist")) {
    html <- app$get_html(sprintf("#%s", out))
    expect_true(
      !is.null(html) && nchar(html) > 50,
      info = sprintf("Output '%s' did not render any content", out)
    )
  }
})
