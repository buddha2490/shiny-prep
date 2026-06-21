# test-utils-charts.R ---------------------------------------------------------
# Unit tests for the chart builders. We assert object class and validation,
# not pixels — the smoke test proves they render in the live app.

test_that("plot_enrollment returns a ggplot", {
  p <- plot_enrollment(make_enrollment(make_adsl(40)))
  expect_s3_class(p, "ggplot")
})

test_that("plot_enrollment validates its input", {
  expect_error(plot_enrollment(data.frame(WEEK = Sys.Date())), "CUM_ENROLLED")
  expect_error(plot_enrollment("nope"), "WEEK")
})

test_that("plot_ae_by_arm returns a plotly htmlwidget", {
  p <- plot_ae_by_arm(make_ae_by_arm(make_adsl(40)))
  expect_s3_class(p, "plotly")
})

test_that("plot_ae_by_arm validates its input", {
  expect_error(plot_ae_by_arm(data.frame(ARM = "x")), "N_AE")
  expect_error(plot_ae_by_arm("nope"), "ARM")
})
