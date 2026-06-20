# =============================================================================
# test-tool-helpers.R — Unit tests for tool backing functions in mod_advanced_ellmer.R
# =============================================================================
# The tool backing functions (the `fun` arg to ellmer::tool()) are pure R
# closures. We extract and test them directly without creating an ellmer tool
# object, since ellmer::tool() validates the fun signature but doesn't change
# what fun() does.
#
# Tools tested:
#   - make_time_tool()  -> backing function returns a formatted date-time string
#   - make_dice_tool()  -> backing function returns a list with rolls/total/label
# =============================================================================

library(testthat)

source(file.path("..", "..", "R", "utils_logger.R"))
source(file.path("..", "..", "R", "utils_error.R"))
source(file.path("..", "..", "R", "mod_advanced_ellmer.R"))

# Silence logger output during tests.
init_logger(app_name = "test", log_dir = tempdir(), to_file = FALSE)

# --- Helpers to extract the fun() closure from the tool object ---------------
# ellmer::tool() returns an object of class "Tool". The backing function is
# stored in the $fun slot (or as the first element of the list). We use
# local_mocked_bindings to intercept tool() and capture the fun argument.

# =============================================================================
# get_current_time tool — backing function
# =============================================================================

test_that("time tool backing function returns a non-empty character string", {
  # Capture the fun passed to ellmer::tool() for make_time_tool
  captured_fun <- NULL
  local_mocked_bindings(
    tool = function(fun, description, arguments = list()) {
      captured_fun <<- fun
      structure(list(fun = fun, description = description), class = "Tool")
    },
    type_integer = function(...) list(),
    .package = "ellmer"
  )

  make_time_tool()

  expect_false(is.null(captured_fun))
  result <- captured_fun()
  expect_type(result, "character")
  expect_gt(nchar(result), 0L)
})

test_that("time tool backing function result matches YYYY-MM-DD HH:MM:SS pattern", {
  captured_fun <- NULL
  local_mocked_bindings(
    tool = function(fun, description, arguments = list()) {
      captured_fun <<- fun
      structure(list(fun = fun), class = "Tool")
    },
    type_integer = function(...) list(),
    .package = "ellmer"
  )

  make_time_tool()
  result <- captured_fun()

  # Expected pattern: "2026-06-19 14:30:00 UTC" (timezone suffix varies)
  expect_match(result, "^\\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}:\\d{2}")
})

test_that("time tool backing function result reflects current time (within 2s)", {
  captured_fun <- NULL
  local_mocked_bindings(
    tool = function(fun, description, arguments = list()) {
      captured_fun <<- fun
      structure(list(fun = fun), class = "Tool")
    },
    type_integer = function(...) list(),
    .package = "ellmer"
  )

  make_time_tool()
  before <- Sys.time()
  result <- captured_fun()
  after  <- Sys.time()

  # Parse the result back to POSIXct (strip timezone suffix for parsing)
  parsed <- tryCatch(
    as.POSIXct(substr(result, 1, 19), format = "%Y-%m-%d %H:%M:%S"),
    error = function(e) NA
  )
  expect_false(is.na(parsed))
  # Allow 2 seconds of clock drift between before and parsed.
  expect_lte(abs(as.numeric(parsed - before, units = "secs")), 2)
})

# =============================================================================
# roll_dice tool — backing function
# =============================================================================

test_that("dice tool backing function returns a list with rolls, total, and label", {
  set.seed(42)
  captured_fun <- NULL
  local_mocked_bindings(
    tool = function(fun, description, arguments = list()) {
      captured_fun <<- fun
      structure(list(fun = fun), class = "Tool")
    },
    type_integer = function(...) list(),
    .package = "ellmer"
  )

  make_dice_tool()
  result <- captured_fun(n_dice = 2, sides = 6)

  expect_type(result, "list")
  expect_named(result, c("rolls", "total", "label"), ignore.order = FALSE)
})

test_that("dice tool returns correct number of rolls", {
  set.seed(42)
  captured_fun <- NULL
  local_mocked_bindings(
    tool = function(fun, description, arguments = list()) {
      captured_fun <<- fun
      structure(list(fun = fun), class = "Tool")
    },
    type_integer = function(...) list(),
    .package = "ellmer"
  )

  make_dice_tool()
  result <- captured_fun(n_dice = 3, sides = 6)
  expect_length(result$rolls, 3L)
})

test_that("dice rolls are all within the valid range", {
  set.seed(42)
  captured_fun <- NULL
  local_mocked_bindings(
    tool = function(fun, description, arguments = list()) {
      captured_fun <<- fun
      structure(list(fun = fun), class = "Tool")
    },
    type_integer = function(...) list(),
    .package = "ellmer"
  )

  make_dice_tool()
  result <- captured_fun(n_dice = 100, sides = 6)

  expect_true(all(result$rolls >= 1L))
  expect_true(all(result$rolls <= 6L))
})

test_that("dice tool total equals sum of rolls", {
  set.seed(42)
  captured_fun <- NULL
  local_mocked_bindings(
    tool = function(fun, description, arguments = list()) {
      captured_fun <<- fun
      structure(list(fun = fun), class = "Tool")
    },
    type_integer = function(...) list(),
    .package = "ellmer"
  )

  make_dice_tool()
  result <- captured_fun(n_dice = 4, sides = 8)
  expect_equal(result$total, sum(result$rolls))
})

test_that("dice label is formatted as NdS", {
  captured_fun <- NULL
  local_mocked_bindings(
    tool = function(fun, description, arguments = list()) {
      captured_fun <<- fun
      structure(list(fun = fun), class = "Tool")
    },
    type_integer = function(...) list(),
    .package = "ellmer"
  )

  make_dice_tool()
  result <- captured_fun(n_dice = 3, sides = 6)
  expect_equal(result$label, "3d6")
})

test_that("dice tool defaults to 1d6 when no arguments provided", {
  set.seed(42)
  captured_fun <- NULL
  local_mocked_bindings(
    tool = function(fun, description, arguments = list()) {
      captured_fun <<- fun
      structure(list(fun = fun), class = "Tool")
    },
    type_integer = function(...) list(),
    .package = "ellmer"
  )

  make_dice_tool()
  result <- captured_fun()

  expect_length(result$rolls, 1L)
  expect_gte(result$rolls, 1L)
  expect_lte(result$rolls, 6L)
  expect_equal(result$label, "1d6")
})

test_that("dice rolls are deterministic under set.seed()", {
  set.seed(2024L)
  captured_fun <- NULL
  local_mocked_bindings(
    tool = function(fun, description, arguments = list()) {
      captured_fun <<- fun
      structure(list(fun = fun), class = "Tool")
    },
    type_integer = function(...) list(),
    .package = "ellmer"
  )

  make_dice_tool()

  set.seed(2024L)
  r1 <- captured_fun(n_dice = 5, sides = 6)

  set.seed(2024L)
  r2 <- captured_fun(n_dice = 5, sides = 6)

  expect_equal(r1$rolls, r2$rolls)
  expect_equal(r1$total, r2$total)
})
