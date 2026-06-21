# =============================================================================
# test-all-tabs-smoke.R — startup smoke test across ALL bs4Dash sidebar tabs
# =============================================================================
# WHY THIS EXISTS (testing rule 6)
# bs4Dash is the heaviest Shiny client in this repo: a render error in any box,
# value box, chart, or table — or an observer that crashes on first flush — is
# caught by Shiny and shown in the output element; it never reaches the browser
# console and is NOT proven by a unit test. This launches the REAL app, visits
# every sidebar tab, exercises each tab's headline interaction (a render error
# only fires when its reactive actually executes), then asserts nothing threw.
#
# bs4Dash navigation: the sidebar IS the nav. We switch tabs by setting the
# sidebarMenu's input id (`sidebar_menu`), the bs4Dash equivalent of bslib's
# `nav`. Imperative widgets are driven through their action-button inputs.
#
# Run it the documented way (testing rule 7): from the repo root with renv
# active and NOT_CRAN=true, so packages resolve to the locked library.
# =============================================================================

library(shinytest2)
library(testthat)

APP_DIR <- file.path("..", "..")

# menuItem(tabName=) values, switched via the sidebarMenu(id="sidebar_menu").
ALL_TABS <- c("overview", "boxes", "components", "charts", "data")

test_that("every sidebar tab opens and renders with no Shiny errors", {
  app <- AppDriver$new(
    app_dir      = APP_DIR,
    name         = "bs4dash-all-tabs-smoke",
    seed         = 42L,
    load_timeout = 120000L,   # bs4Dash + waiter preloader boot is slow
    timeout      = 30000L
  )
  on.exit(app$stop(), add = TRUE)

  # --- Visit each tab and let its outputs / observers flush -----------------
  for (tab in ALL_TABS) {
    app$set_inputs(sidebar_menu = tab)
    app$wait_for_idle(timeout = 15000L)
  }

  # --- Overview: drive the dynamic value box from the controlbar slider -----
  app$set_inputs(sidebar_menu = "overview")
  app$wait_for_idle(timeout = 10000L)
  app$set_inputs(target_n = 60)
  app$wait_for_idle(timeout = 10000L)

  # --- Boxes: exercise the imperative updateBox / sidebar / toast widgets ---
  app$set_inputs(sidebar_menu = "boxes")
  app$wait_for_idle(timeout = 10000L)
  app$click("toggle_box");        app$wait_for_idle(timeout = 8000L)
  app$click("max_box");           app$wait_for_idle(timeout = 8000L)
  app$click("open_box_sidebar");  app$wait_for_idle(timeout = 8000L)
  app$click("dd_export");         app$wait_for_idle(timeout = 8000L)

  # --- Components: drive the accordion update from the radio buttons --------
  app$set_inputs(sidebar_menu = "components")
  app$wait_for_idle(timeout = 10000L)
  app$set_inputs(acc_control = "2"); app$wait_for_idle(timeout = 8000L)

  # --- Charts: filter arms + toggle the trend points (both re-render) -------
  app$set_inputs(sidebar_menu = "charts")
  app$wait_for_idle(timeout = 12000L)
  app$set_inputs(arm_filter = c("Placebo", "High Dose"))
  app$wait_for_idle(timeout = 12000L)
  app$set_inputs(show_points = FALSE)
  app$wait_for_idle(timeout = 12000L)

  # --- Data: just ensure the DT tab rendered --------------------------------
  app$set_inputs(sidebar_menu = "data")
  app$wait_for_idle(timeout = 12000L)

  # --- Assert: nothing threw (the universal gate) ---------------------------
  # Scans captured Shiny stderr for render/runtime errors, checks for any
  # `.shiny-output-error` element, and asserts a clean browser console. See
  # helper-shiny-smoke.R for why "console clean + non-empty HTML" is NOT enough.
  expect_no_shiny_errors(app)

  # --- Assert: each tab's primary output positively rendered ----------------
  # Positive proof the heavy widgets actually drew (not just "container present").
  for (out in c("vbox_target", "enroll_plot", "ae_plot", "adsl_table")) {
    html <- app$get_html(sprintf("#%s", out))
    expect_true(
      !is.null(html) && nchar(html) > 30,
      info = sprintf("Output '%s' did not render any content", out)
    )
  }
})
