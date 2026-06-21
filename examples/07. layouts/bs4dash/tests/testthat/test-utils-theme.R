# test-utils-theme.R ----------------------------------------------------------
#
# The theme builder is mostly a wiring call into fresh, but it can fail loudly
# if a fresh setter name or argument is wrong — so we assert it constructs a
# usable object (testing rule 1: R6/utility functions with logic get a test).

test_that("build_dashboard_theme returns a usable fresh theme object", {
  thm <- build_dashboard_theme()
  # fresh::create_theme() returns the rendered CSS as a character string carrying
  # the c("css","html","character") classes; bs4Dash drops it into the page head
  # via dashboardPage(freshTheme=). Assert that contract: it is `css`/`html` and
  # actually contains our overridden status colour.
  expect_s3_class(thm, "css")
  expect_s3_class(thm, "html")
  expect_true(grepl("2c7fb8", thm, fixed = TRUE))  # our clinical primary blue
  expect_silent(build_dashboard_theme())
})
