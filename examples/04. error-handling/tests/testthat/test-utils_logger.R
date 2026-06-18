# Tests for utils_logger.R

test_that("get_logger() returns a usable logger even without init", {
  # Reset the private store so we exercise the fallback branch.
  rm(list = ls(envir = .logger_store), envir = .logger_store)
  expect_s3_class(get_logger(), "logger")
})

test_that("init_logger() writes to the configured file", {
  tmp <- file.path(tempdir(), paste0("logtest-", as.integer(Sys.time())))
  init_logger(app_name = "unit", log_dir = tmp, threshold = "DEBUG")

  log_event("INFO", "hello world", code = "T-001")

  log_file <- file.path(tmp, "unit.log")
  expect_true(file.exists(log_file))
  contents <- readLines(log_file, warn = FALSE)
  expect_true(any(grepl("hello world", contents)))
  expect_true(any(grepl("code=T-001", contents)))
})

test_that("log_event() renders extra fields as key=value and quotes spaces", {
  line <- log_event("INFO", "msg", code = "T-002", detail = "two words")
  expect_match(line, "code=T-002")
  expect_match(line, 'detail="two words"')
})

test_that("threshold suppresses lower-priority levels", {
  tmp <- file.path(tempdir(), paste0("logtest2-", as.integer(Sys.time())))
  init_logger(app_name = "unit2", log_dir = tmp, threshold = "WARN")

  log_event("DEBUG", "should be hidden", code = "T-003")
  log_event("ERROR", "should appear",    code = "T-004")

  contents <- readLines(file.path(tmp, "unit2.log"), warn = FALSE)
  expect_false(any(grepl("should be hidden", contents)))
  expect_true(any(grepl("should appear", contents)))
})
