# =============================================================================
# test-utils-plots.R — unit tests for the plotting + theme helpers
# =============================================================================
# These functions build ggplot objects and validate inputs. We assert they
# return ggplot objects, accept light/dark mode without error, and reject bad
# input per the error-messages rule.

test_that("mode_theme returns ggplot theme components for both modes", {
  expect_type(mode_theme("light"), "list")
  expect_type(mode_theme("dark"), "list")

  # Defensive fallback: NULL / bad mode must NOT error (first-flush safety).
  expect_silent(mode_theme(NULL))
  expect_silent(mode_theme(character(0)))
})

test_that("plot_enrollment builds a ggplot and validates input", {
  g <- plot_enrollment(make_enrollment(), "dark")
  expect_s3_class(g, "ggplot")

  expect_error(
    plot_enrollment("not a data frame"),
    "`enrollment` must be a data frame",
    fixed = TRUE
  )
})

test_that("plot_ae_counts builds a ggplot and validates input", {
  g <- plot_ae_counts(make_ae_counts(), "light")
  expect_s3_class(g, "ggplot")

  expect_error(
    plot_ae_counts(42),
    "`ae_counts` must be a data frame",
    fixed = TRUE
  )
})

test_that("sparkline_plot builds a chrome-free ggplot and rejects short input", {
  g <- sparkline_plot(c(1, 3, 2, 5, 4))
  expect_s3_class(g, "ggplot")

  expect_error(
    sparkline_plot(1),
    "`y` must be a numeric vector of length >= 2",
    fixed = TRUE
  )
  expect_error(
    sparkline_plot("a"),
    "`y` must be a numeric vector of length >= 2",
    fixed = TRUE
  )
})

test_that("color palettes cover every arm and severity level", {
  expect_setequal(names(ARM_COLORS), c("Placebo", "Low Dose", "High Dose"))
  expect_setequal(names(SEV_COLORS), c("Mild", "Moderate", "Severe"))
})
