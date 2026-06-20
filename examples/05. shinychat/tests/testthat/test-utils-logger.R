# =============================================================================
# test-utils-logger.R — Unit tests for R/utils_logger.R
# =============================================================================
# Tests init_logger(), get_logger(), and log_event() in isolation.
# The logger stores its singleton in .logger_store, which is created when the
# source file is sourced. Each test that modifies state resets it after.
# =============================================================================

library(testthat)
library(log4r)

# Source only the logger — no Shiny or ellmer needed for these tests.
source(file.path("..", "..", "R", "utils_logger.R"))

# --- Helper: reset logger state between tests --------------------------------

reset_logger <- function() {
  .logger_store$logger <- NULL
}

# =============================================================================
# init_logger()
# =============================================================================

test_that("init_logger creates a log4r logger and stores it", {
  reset_logger()
  lg <- init_logger(app_name = "test-app", log_dir = tempdir(), to_file = FALSE)

  expect_s3_class(lg, "logger")
  expect_false(is.null(.logger_store$logger))

  reset_logger()
})

test_that("init_logger returns the logger invisibly", {
  reset_logger()
  # invisible() means the value is returned but not auto-printed
  result <- init_logger(app_name = "test-app", log_dir = tempdir(), to_file = FALSE)
  expect_s3_class(result, "logger")
  reset_logger()
})

test_that("init_logger creates a file appender when to_file = TRUE", {
  reset_logger()
  td <- file.path(tempdir(), paste0("log-test-", format(Sys.time(), "%H%M%S")))
  lg <- init_logger(app_name = "test-app", log_dir = td, to_file = TRUE)

  # File should exist after first write
  log4r::info(lg, "probe line")
  expect_true(file.exists(file.path(td, "test-app.log")))

  reset_logger()
})

test_that("init_logger replaces any existing logger on second call", {
  reset_logger()
  lg1 <- init_logger(app_name = "first",  log_dir = tempdir(), to_file = FALSE)
  lg2 <- init_logger(app_name = "second", log_dir = tempdir(), to_file = FALSE)

  # After second call, stored logger is lg2
  expect_identical(.logger_store$logger, lg2)

  reset_logger()
})

# =============================================================================
# get_logger()
# =============================================================================

test_that("get_logger returns the stored logger after init_logger", {
  reset_logger()
  init_logger(app_name = "test-app", log_dir = tempdir(), to_file = FALSE)
  lg <- get_logger()
  expect_s3_class(lg, "logger")
  reset_logger()
})

test_that("get_logger creates a default logger when none has been initialised", {
  reset_logger()
  # Do NOT call init_logger — get_logger should be self-healing
  lg <- get_logger()
  expect_s3_class(lg, "logger")
  reset_logger()
})

test_that("get_logger never throws even when logger store is empty", {
  reset_logger()
  expect_no_error(get_logger())
  reset_logger()
})

# =============================================================================
# log_event()
# =============================================================================

test_that("log_event returns the composed line invisibly", {
  reset_logger()
  init_logger(app_name = "test-app", log_dir = tempdir(), to_file = FALSE)

  result <- log_event("INFO", "Test message")
  expect_type(result, "character")
  expect_match(result, "Test message")

  reset_logger()
})

test_that("log_event appends key=value pairs from ... args", {
  reset_logger()
  init_logger(app_name = "test-app", log_dir = tempdir(), to_file = FALSE)

  result <- log_event("INFO", "Event occurred", module = "basic_chat", count = 3L)
  expect_match(result, "module=basic_chat")
  expect_match(result, "count=3")

  reset_logger()
})

test_that("log_event quotes values that contain whitespace", {
  reset_logger()
  init_logger(app_name = "test-app", log_dir = tempdir(), to_file = FALSE)

  result <- log_event("INFO", "msg", label = "hello world")
  expect_match(result, 'label="hello world"')

  reset_logger()
})

test_that("log_event does not throw for any supported level", {
  reset_logger()
  init_logger(app_name = "test-app", log_dir = tempdir(), to_file = FALSE)

  for (lvl in c("DEBUG", "INFO", "WARN", "ERROR", "FATAL")) {
    expect_no_error(log_event(lvl, paste("Test at level", lvl)))
  }

  reset_logger()
})

test_that("log_event treats unknown level as INFO without throwing", {
  reset_logger()
  init_logger(app_name = "test-app", log_dir = tempdir(), to_file = FALSE)

  expect_no_error(log_event("TRACE", "Unknown level test"))

  reset_logger()
})

test_that("log_event works without calling init_logger first", {
  reset_logger()
  # get_logger() self-heals — log_event must not throw in this scenario
  expect_no_error(log_event("INFO", "Self-healing test"))
  reset_logger()
})
