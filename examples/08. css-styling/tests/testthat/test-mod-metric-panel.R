# test-mod-metric-panel.R -----------------------------------------------------
# testServer() coverage of the metric-panel module: it formats its value with a
# thousands separator. (The namespaced CSS targeting is verified at the
# AppDriver layer in the smoke test — see the rendered ids there.)

test_that("metric panel formats its value with a thousands separator", {
  testServer(
    mod_metric_panel_server,
    args = list(value = 1280L),
    {
      expect_equal(output$count, "1,280")
    }
  )
})
