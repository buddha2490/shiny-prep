# =============================================================================
# test-all-tabs-smoke.R — startup smoke test across ALL navbar tabs (rule 6)
# =============================================================================
# WHY THIS EXISTS
# The unit tests prove the data factories and plot builders in isolation; they
# do NOT prove an output renders or an observer survives first flush in a real
# browser. A whole class of failures — a value_box showcase plot that throws, a
# renderPlotly that errors, a session$setCurrentTheme() call that fails, a
# nav_select() targeting a wrong id — lives only in the wired, rendered app.
#
# This launches the REAL app, visits every nav panel, exercises each tab's
# primary interaction (a render error only fires when its reactive executes),
# then asserts NOTHING THREW via expect_no_shiny_errors() (stderr scan + DOM
# error class + clean browser console). See helper-shiny-smoke.R for why
# "console clean + non-empty HTML" is a false-pass trap.
#
# Run it the documented way (testing rule 7): from the app dir with renv active
# and NOT_CRAN=true so packages resolve to the locked library.
# =============================================================================

library(shinytest2)
library(testthat)

APP_DIR <- file.path("..", "..")

# nav_panel values default to their titles; navbar input id is "nav".
ALL_TABS <- c("Layouts", "Value boxes", "Navsets", "Theming", "About")

test_that("every navbar tab opens and renders with no shiny errors", {
  app <- AppDriver$new(
    app_dir      = APP_DIR,
    name         = "layouts-bslib-all-tabs-smoke",
    seed         = 42L,
    load_timeout = 90000L,
    timeout      = 30000L
  )
  on.exit(app$stop(), add = TRUE)

  # --- Visit every tab and let its outputs/observers flush -------------------
  for (tab in ALL_TABS) {
    app$set_inputs(nav = tab)
    app$wait_for_idle(timeout = 15000L)
  }

  # --- Tab 1 Layouts: drive the page sidebar + card-scoped sidebar ----------
  app$set_inputs(nav = "Layouts")
  app$wait_for_idle(timeout = 15000L)
  app$set_inputs(arm_filter = "High Dose"); app$wait_for_idle(timeout = 10000L)
  app$set_inputs(age_filter = 60);          app$wait_for_idle(timeout = 10000L)
  app$set_inputs(layout_metric = "ae");     app$wait_for_idle(timeout = 10000L)
  app$set_inputs(layout_metric = "enroll"); app$wait_for_idle(timeout = 10000L)

  # --- Tab 2 Value boxes: switch, popover button, action button -------------
  app$set_inputs(nav = "Value boxes")
  app$wait_for_idle(timeout = 15000L)
  app$set_inputs(show_severe = TRUE);  app$wait_for_idle(timeout = 10000L)
  app$click("count_btn");              app$wait_for_idle(timeout = 10000L)
  app$click("count_btn");              app$wait_for_idle(timeout = 10000L)

  # --- Tab 3 Navsets: inner tab switch, color-by, server nav_select ---------
  app$set_inputs(nav = "Navsets")
  app$wait_for_idle(timeout = 15000L)
  app$set_inputs(nav_demo_col = "SEX"); app$wait_for_idle(timeout = 10000L)
  app$click("goto_table");              app$wait_for_idle(timeout = 10000L)

  # --- Tab 4 Theming: live bootswatch swap (the riskiest interaction) -------
  app$set_inputs(nav = "Theming")
  app$wait_for_idle(timeout = 15000L)
  app$set_inputs(bootswatch = "flatly"); app$wait_for_idle(timeout = 15000L)
  app$set_inputs(bootswatch = "darkly"); app$wait_for_idle(timeout = 15000L)
  app$set_inputs(bootswatch = "default"); app$wait_for_idle(timeout = 15000L)

  # --- Toggle dark mode, which re-renders every themed ggplot ---------------
  app$set_inputs(dark_mode = "dark");  app$wait_for_idle(timeout = 15000L)
  app$set_inputs(dark_mode = "light"); app$wait_for_idle(timeout = 15000L)

  # --- Assert: nothing threw (the universal gate) ---------------------------
  expect_no_shiny_errors(app)

  # --- Assert: a representative output on each tab positively rendered -------
  for (out in c("layout_plot", "vb_sparkline", "nav_plot", "theme_plot")) {
    html <- app$get_html(sprintf("#%s", out))
    expect_true(
      !is.null(html) && nchar(html) > 50,
      info = sprintf("Output '%s' did not render any content", out)
    )
  }
})
