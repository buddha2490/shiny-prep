# test-utils-style-helpers.R --------------------------------------------------
# Unit tests for the pure Rule 2 style helpers. These carry the data-driven
# style logic, so they are the parts worth asserting directly.

test_that("grade_fill maps each grade 0-4 to its custom property", {
  expect_equal(grade_fill(0), "var(--app-grade-0)")
  expect_equal(grade_fill(4), "var(--app-grade-4)")
  # Vectorised, order preserved.
  expect_equal(
    grade_fill(c(2, 0, 4)),
    c("var(--app-grade-2)", "var(--app-grade-0)", "var(--app-grade-4)")
  )
})

test_that("grade_fill rejects non-numeric and out-of-range input", {
  expect_error(grade_fill("2"), "must be numeric")
  expect_error(grade_fill(5), "range 0-4")
  expect_error(grade_fill(-1), "range 0-4")
})

test_that("pct_bar clamps the width into [0, 100]", {
  over  <- as.character(pct_bar(140))
  under <- as.character(pct_bar(-20))
  expect_true(grepl("width:\\s*100%", over))
  expect_true(grepl("width:\\s*0%", under))
})

test_that("pct_bar applies the fill colour and a default label inline", {
  html <- as.character(pct_bar(63, fill = "var(--app-accent)"))
  expect_true(grepl("background-color:\\s*var\\(--app-accent\\)", html))
  expect_true(grepl("width:\\s*63%", html))
  expect_true(grepl("63%", html))           # default label is the rounded pct
})

test_that("pct_bar honours an explicit label and rejects bad input", {
  html <- as.character(pct_bar(50, label = "half"))
  expect_true(grepl("half", html))
  expect_error(pct_bar(c(1, 2)), "single number")
  expect_error(pct_bar("50"), "single number")
})
