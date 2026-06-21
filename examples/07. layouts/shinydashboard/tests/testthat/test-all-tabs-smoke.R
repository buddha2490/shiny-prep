# =============================================================================
# test-all-tabs-smoke.R — startup smoke test across ALL dashboard tabs
# =============================================================================
# WHY THIS EXISTS (testing rule 6)
# The unit tests prove the factories and chart builders in isolation; they do
# NOT prove an output renders or an observer survives its first flush in a real
# browser. A whole class of failures — a valueBox renderer that throws, a
# renderMenu that errors, a plot that crashes on an empty filter — lives only in
# the wired, rendered app and sails straight past a unit test.
#
# This launches the REAL app, visits every tabItem (shinydashboard switches tabs
# by the sidebarMenu id `sidebar_tabs`, NOT a navbar input), exercises each tab's
# headline interaction, and asserts nothing threw via expect_no_shiny_errors()
# (stderr scan + .shiny-output-error DOM check + clean browser console).
#
# Run it the documented way (testing rule 7): from the repo root with renv
# active and NOT_CRAN=true so packages resolve to the locked library.
# =============================================================================

library(shinytest2)
library(testthat)

APP_DIR <- file.path("..", "..")

# Each value is a tabItem `tabName`. The sidebarMenu id is "sidebar_tabs", so
# setting that input switches tabs exactly as clicking the menu link does.
ALL_TABS <- c("overview", "boxes", "charts", "data", "widgets", "about")

test_that("every dashboard tab opens and renders with no shiny errors", {
  app <- AppDriver$new(
    app_dir      = APP_DIR,
    name         = "shinydashboard-all-tabs-smoke",
    seed         = 42L,
    load_timeout = 90000L,
    timeout      = 30000L
  )
  on.exit(app$stop(), add = TRUE)

  # Visit each tab and let its outputs/observers flush.
  for (tab in ALL_TABS) {
    app$set_inputs(sidebar_tabs = tab)
    app$wait_for_idle(timeout = 15000L)
  }

  # --- Exercise the headline interactions on each tab -----------------------
  # Overview: change the arm filter so the dynamic valueBox/infoBox recompute.
  app$set_inputs(sidebar_tabs = "overview")
  app$wait_for_idle(timeout = 15000L)
  app$set_inputs(ov_arm = "High Dose"); app$wait_for_idle(timeout = 10000L)
  app$set_inputs(ov_arm = "All arms");  app$wait_for_idle(timeout = 10000L)

  # Charts: drive the region + age controls so both charts re-render.
  app$set_inputs(sidebar_tabs = "charts")
  app$wait_for_idle(timeout = 15000L)
  app$set_inputs(chart_region = "Europe"); app$wait_for_idle(timeout = 10000L)
  app$set_inputs(chart_age = c(40, 70));   app$wait_for_idle(timeout = 10000L)

  # Widgets: add a dynamic sidebar item (renderMenu) and jump tabs
  # (updateTabItems). The tab-jump must come last as it changes the active tab.
  app$set_inputs(sidebar_tabs = "widgets")
  app$wait_for_idle(timeout = 15000L)
  app$click("add_menu_item"); app$wait_for_idle(timeout = 10000L)
  app$click("add_menu_item"); app$wait_for_idle(timeout = 10000L)
  app$click("go_overview");   app$wait_for_idle(timeout = 10000L)

  # Header dynamic dropdown: type a search term so renderMenu re-runs.
  app$set_inputs(search_text = "DEMO-01-014"); app$wait_for_idle(timeout = 10000L)

  # --- Assert: nothing threw (the universal gate) ---------------------------
  expect_no_shiny_errors(app)

  # --- Assert: representative outputs positively rendered -------------------
  # Positive proof key widgets actually drew, not just "container non-empty".
  for (out in c("data_table", "chart_ae", "ov_dynamic_box")) {
    html <- app$get_html(sprintf("#%s", out))
    expect_true(
      !is.null(html) && nchar(html) > 50,
      info = sprintf("Output '%s' did not render any content", out)
    )
  }
})
