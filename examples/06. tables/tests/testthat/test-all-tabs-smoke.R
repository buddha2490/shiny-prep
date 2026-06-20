# =============================================================================
# test-all-tabs-smoke.R — startup smoke test across ALL navbar tabs
# =============================================================================
# WHY THIS EXISTS (testing rule 6)
# The per-module testServer tests prove reactive *logic*; they do not prove an
# output renders or an observer survives its first flush in a real browser. A
# whole class of failures — an output that errors on render, a cell renderer
# that throws, a proxy/observer that crashes on first flush — lives only in the
# wired, rendered app and sails straight through a testServer test.
#
# This launches the REAL app, visits every nav panel, exercises the headline
# interactions on each, and asserts the browser console stayed clean and each
# tab's primary table output actually rendered. It asserts no feature behaviour
# (the per-module tests do that) — only that nothing throws.
#
# Run it the documented way (testing rule 7): from the repo root with renv
# active and NOT_CRAN=true, so packages resolve to the locked library.
# =============================================================================

library(shinytest2)
library(testthat)

APP_DIR <- file.path("..", "..")

# nav_panel values default to their titles; the navbar input id is "nav".
ALL_TABS <- c("Overview", "DT", "reactable", "gt", "rhandsontable")

test_that("every navbar tab opens and renders with a clean browser console", {
  app <- AppDriver$new(
    app_dir      = APP_DIR,
    name         = "tables-all-tabs-smoke",
    seed         = 42L,
    load_timeout = 90000L,
    timeout      = 30000L
  )
  on.exit(app$stop(), add = TRUE)

  # Visit each tab and let its outputs/observers flush.
  for (tab in ALL_TABS) {
    app$set_inputs(nav = tab)
    app$wait_for_idle(timeout = 15000L)
  }

  # --- Exercise the headline interactions on each tab -----------------------
  # DT: programmatic selection, proxy data mutation, reset.
  app$set_inputs(nav = "DT")
  app$wait_for_idle(timeout = 15000L)
  app$click("dt-select_serious"); app$wait_for_idle(timeout = 10000L)
  app$click("dt-worsen");         app$wait_for_idle(timeout = 10000L)
  app$click("dt-clear_sel");      app$wait_for_idle(timeout = 10000L)
  app$click("dt-reset");          app$wait_for_idle(timeout = 10000L)

  # reactable: expand / collapse all groups.
  app$set_inputs(nav = "reactable")
  app$wait_for_idle(timeout = 15000L)
  app$click("reactable-expand");   app$wait_for_idle(timeout = 10000L)
  app$click("reactable-collapse"); app$wait_for_idle(timeout = 10000L)

  # gt: switch between the two publication tables.
  app$set_inputs(nav = "gt")
  app$wait_for_idle(timeout = 15000L)
  app$set_inputs(`gt-which` = "ae"); app$wait_for_idle(timeout = 15000L)
  app$set_inputs(`gt-which` = "t1"); app$wait_for_idle(timeout = 15000L)

  # rhandsontable: save / reset round-trip.
  app$set_inputs(nav = "rhandsontable")
  app$wait_for_idle(timeout = 15000L)
  app$click("rhot-save");  app$wait_for_idle(timeout = 10000L)
  app$click("rhot-reset"); app$wait_for_idle(timeout = 10000L)

  # --- Assert: each tab's primary table output rendered WITHOUT error --------
  # A render-time exception does NOT show up as a browser-console error and
  # still leaves a non-empty container behind (the error <div>), so "got some
  # HTML" is not enough — Shiny tags a failed output with class
  # `shiny-output-error`. Assert that class is absent and the widget actually
  # drew (its htmlwidget/table markup is present).
  for (out in c("dt-tbl", "reactable-tbl", "gt-tbl", "rhot-tbl")) {
    html <- app$get_html(sprintf("#%s", out))
    expect_false(
      isTRUE(grepl("shiny-output-error", html %||% "")),
      info = sprintf("Output '%s' rendered into an error state:\n%s", out, html)
    )
    expect_true(
      !is.null(html) && nchar(html) > 50,
      info = sprintf("Output '%s' did not render any content", out)
    )
  }

  # Belt-and-braces: no output element anywhere is in an error state.
  # get_html() returns NULL when the selector matches nothing.
  any_error <- tryCatch(app$get_html(".shiny-output-error"),
                        error = function(e) NULL)
  expect_null(
    any_error,
    info = paste0("An output rendered into an error state:\n",
                  any_error %||% "")
  )

  # --- Assert: the browser console logged no errors --------------------------
  logs <- as.data.frame(app$get_logs())
  if (nrow(logs) > 0 && "level" %in% names(logs)) {
    console_errors <- logs$message[!is.na(logs$level) & logs$level == "error"]
    expect_identical(
      console_errors, character(0),
      info = paste0("Browser console errors:\n",
                    paste(console_errors, collapse = "\n"))
    )
  } else {
    succeed("No structured console logs to inspect.")
  }
})
