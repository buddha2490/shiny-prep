# =============================================================================
# test-utils-error.R — Unit tests for R/utils_error.R
# =============================================================================
# Tests the error catalog lookup helpers, new_incident_id(), and
# with_error_handling(). The logger is initialised to a console-only logger so
# log output doesn't pollute the test run with warnings about missing loggers.
# with_error_handling() requires a Shiny reactive domain for notify — we pass
# session = NULL to suppress notifications in unit tests.
# =============================================================================

library(testthat)
library(log4r)

# Source both helpers — utils_error depends on utils_logger.
source(file.path("..", "..", "R", "utils_logger.R"))
source(file.path("..", "..", "R", "utils_error.R"))

# Use a console-only logger for tests so no log files are created.
init_logger(app_name = "test", log_dir = tempdir(), to_file = FALSE)

# =============================================================================
# error_user_message()
# =============================================================================

test_that("error_user_message returns the catalog message for a known code", {
  msg <- error_user_message("ERR-LLM-001")
  expect_type(msg, "character")
  expect_gt(nchar(msg), 0L)
  # Verify it is the registered safe message (partial match is fine).
  expect_match(msg, "LLM request failed", ignore.case = TRUE)
})

test_that("error_user_message falls back to ERR-UNKNOWN-000 message for unknown code", {
  msg <- error_user_message("ERR-DOES-NOT-EXIST")
  generic <- error_user_message("ERR-UNKNOWN-000")
  expect_equal(msg, generic)
})

test_that("error_user_message returns a non-empty string for every registered code", {
  for (code in names(.error_catalog)) {
    msg <- error_user_message(code)
    expect_type(msg, "character")
    expect_gt(nchar(msg), 0L, label = paste("message for", code))
  }
})

# =============================================================================
# error_severity()
# =============================================================================

test_that("error_severity returns the catalog severity for known codes", {
  expect_equal(error_severity("ERR-LLM-001"),  "ERROR")
  expect_equal(error_severity("ERR-APP-999"),  "FATAL")
})

test_that("error_severity falls back to ERROR for unknown code", {
  expect_equal(error_severity("ERR-INVENTED"), "ERROR")
})

# =============================================================================
# new_incident_id()
# =============================================================================

test_that("new_incident_id returns a single character string", {
  id <- new_incident_id()
  expect_type(id, "character")
  expect_length(id, 1L)
})

test_that("new_incident_id matches expected format: YYYYMMDDTHHmmSS-<6hex>", {
  id <- new_incident_id()
  expect_match(id, "^\\d{8}T\\d{6}-[0-9a-f]{6}$")
})

test_that("new_incident_id generates unique values on repeated calls", {
  # Two calls in the same second differ in their hex suffix.
  ids <- replicate(20L, new_incident_id())
  expect_equal(length(unique(ids)), 20L)
})

# =============================================================================
# with_error_handling()
# =============================================================================

test_that("with_error_handling returns the expression result on success", {
  result <- with_error_handling(1 + 1, code = "ERR-DATA-001", session = NULL)
  expect_equal(result, 2L)
})

test_that("with_error_handling returns fallback when expression errors", {
  result <- with_error_handling(
    stop("deliberate error"),
    code     = "ERR-DATA-001",
    fallback = -99L,
    notify   = FALSE,
    session  = NULL
  )
  expect_equal(result, -99L)
})

test_that("with_error_handling returns NULL fallback by default on error", {
  result <- with_error_handling(
    stop("deliberate error"),
    code    = "ERR-DATA-001",
    notify  = FALSE,
    session = NULL
  )
  expect_null(result)
})

test_that("with_error_handling does not re-throw the caught error", {
  expect_no_error({
    with_error_handling(
      stop("caught"),
      code    = "ERR-DATA-001",
      notify  = FALSE,
      session = NULL
    )
  })
})

test_that("with_error_handling muffles warnings and returns the expression result", {
  result <- with_error_handling(
    {
      warning("a warning")
      42L
    },
    code    = "ERR-CALC-001",
    notify  = FALSE,
    session = NULL
  )
  expect_equal(result, 42L)
})

test_that("with_error_handling uses the provided fallback for NULL-returning expressions", {
  # Distinguish NULL-returning-on-success from error fallback.
  result <- with_error_handling(
    NULL,
    code     = "ERR-DATA-001",
    fallback = "FALLBACK",
    notify   = FALSE,
    session  = NULL
  )
  # NULL is the expression result — not an error, so fallback is NOT used.
  expect_null(result)
})

test_that("with_error_handling works with a complex multi-line expression", {
  result <- with_error_handling(
    {
      x <- 2
      y <- x * 3
      y + 1
    },
    code    = "ERR-CALC-001",
    notify  = FALSE,
    session = NULL
  )
  expect_equal(result, 7L)
})

test_that("notify_error does not throw when session is NULL", {
  expect_no_error(notify_error("ERR-LLM-001", new_incident_id(), session = NULL))
})

# =============================================================================
# ERR-RAG-001 and ERR-RAG-002 (Tab 6 RAG Chat codes)
# =============================================================================
# These codes were added to .error_catalog alongside the mod_rag_chat.R module.
# The existing loop test (error_user_message returns a non-empty string for
# every registered code) already covers them implicitly, but we add explicit
# assertions here so a refactoring that removes or renames either code fails
# loudly rather than silently regressing to the generic ERR-UNKNOWN-000 message.

test_that("ERR-RAG-001 resolves to ERROR severity and a non-empty user message", {
  # Severity
  expect_equal(error_severity("ERR-RAG-001"), "ERROR")
  # User message: non-empty and references the store
  msg <- error_user_message("ERR-RAG-001")
  expect_type(msg, "character")
  expect_gt(nchar(msg), 0L)
  expect_match(msg, "knowledge store", ignore.case = TRUE)
})

test_that("ERR-RAG-002 resolves to ERROR severity and a non-empty user message", {
  # Severity
  expect_equal(error_severity("ERR-RAG-002"), "ERROR")
  # User message: non-empty and references retrieval (mode-neutral wording —
  # the default BM25 mode needs no embedding provider, so the message must not
  # hard-assume Ollama).
  msg <- error_user_message("ERR-RAG-002")
  expect_type(msg, "character")
  expect_gt(nchar(msg), 0L)
  expect_match(msg, "retrieval", ignore.case = TRUE)
})

test_that("ERR-RAG-001 user message does not fall back to the generic unknown message", {
  generic <- error_user_message("ERR-UNKNOWN-000")
  rag_msg <- error_user_message("ERR-RAG-001")
  expect_false(identical(rag_msg, generic))
})

test_that("ERR-RAG-002 user message does not fall back to the generic unknown message", {
  generic <- error_user_message("ERR-UNKNOWN-000")
  rag_msg <- error_user_message("ERR-RAG-002")
  expect_false(identical(rag_msg, generic))
})
