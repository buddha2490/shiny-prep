# Tests for utils_error.R

test_that("new_incident_id() has the expected shape and is unique", {
  id1 <- new_incident_id()
  id2 <- new_incident_id()
  expect_match(id1, "^[0-9]{8}T[0-9]{6}-[0-9a-f]{6}$")
  expect_false(identical(id1, id2))
})

test_that("error_user_message() falls back to the generic message", {
  expect_equal(error_user_message("ERR-DATA-001"),
               .error_catalog[["ERR-DATA-001"]]$user)
  expect_equal(error_user_message("ERR-DOES-NOT-EXIST"),
               .error_catalog[["ERR-UNKNOWN-000"]]$user)
})

test_that("error_severity() reads the catalog and defaults to ERROR", {
  expect_equal(error_severity("ERR-APP-999"), "FATAL")
  expect_equal(error_severity("ERR-NOPE-000"), "ERROR")
})

test_that("with_error_handling() returns the value on success", {
  out <- with_error_handling(40 + 2, code = "ERR-CALC-001", notify = FALSE)
  expect_equal(out, 42)
})

test_that("with_error_handling() returns fallback and does not throw on error", {
  # session = NULL + notify = FALSE so no Shiny machinery is needed.
  out <- with_error_handling(
    stop("boom"),
    code     = "ERR-CALC-001",
    fallback = "safe",
    notify   = FALSE,
    session  = NULL
  )
  expect_equal(out, "safe")
})

test_that("with_error_handling() logs the error with its code", {
  tmp <- file.path(tempdir(), paste0("errtest-", as.integer(Sys.time())))
  init_logger(app_name = "errunit", log_dir = tmp, threshold = "DEBUG")

  with_error_handling(
    stop("kaboom in calc"),
    code    = "ERR-CALC-001",
    notify  = FALSE,
    session = NULL
  )

  contents <- readLines(file.path(tmp, "errunit.log"), warn = FALSE)
  expect_true(any(grepl("kaboom in calc", contents)))
  expect_true(any(grepl("code=ERR-CALC-001", contents)))
  expect_true(any(grepl("incident=", contents)))
})

test_that("with_error_handling() logs and muffles warnings", {
  tmp <- file.path(tempdir(), paste0("warntest-", as.integer(Sys.time())))
  init_logger(app_name = "warnunit", log_dir = tmp, threshold = "DEBUG")

  # Should not propagate the warning (muffled) but should still log it.
  expect_no_warning(
    with_error_handling(
      warning("a soft problem"),
      code    = "ERR-CALC-001",
      notify  = FALSE,
      session = NULL
    )
  )
  contents <- readLines(file.path(tmp, "warnunit.log"), warn = FALSE)
  expect_true(any(grepl("a soft problem", contents)))
})
