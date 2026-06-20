# =============================================================================
# test-utils-preflight.R — unit tests for the portable startup health check
# =============================================================================
# preflight() is pure-ish (reads installed packages, env vars, and an optional
# lockfile) and never throws. These tests pin its contract: missing packages and
# missing secrets are ERROR; everything-present is a clean (empty) result.
# No network, no real app launch.
# =============================================================================

library(testthat)

# Load the helper standalone if global.R hasn't been sourced.
if (!exists("preflight")) {
  source(testthat::test_path("..", "..", "R", "utils_preflight.R"))
}

# --- Factory: a guaranteed-unset env var name -------------------------------
unset_var_name <- function() "PREFLIGHT_TEST_DEFINITELY_UNSET_VARIABLE"

test_that("a clean environment yields no problems", {
  Sys.setenv(PREFLIGHT_TEST_PRESENT = "yes")
  on.exit(Sys.unsetenv("PREFLIGHT_TEST_PRESENT"), add = TRUE)
  res <- preflight(
    packages       = "testthat",                 # certainly installed
    env_vars       = "PREFLIGHT_TEST_PRESENT",
    check_versions = FALSE
  )
  expect_identical(res, character(0))
  expect_false(preflight_blocking(res))
})

test_that("a missing package is reported as a blocking ERROR", {
  res <- preflight(
    packages       = "this_package_does_not_exist_zzz",
    check_versions = FALSE
  )
  expect_length(res, 1L)
  expect_match(res, "^ERROR:.*this_package_does_not_exist_zzz")
  expect_true(preflight_blocking(res))
})

test_that("an unset environment variable is reported as a blocking ERROR", {
  res <- preflight(
    env_vars       = unset_var_name(),
    check_versions = FALSE
  )
  expect_length(res, 1L)
  expect_match(res, "^ERROR:.*is not set")
  expect_true(preflight_blocking(res))
})

test_that("multiple problems accumulate", {
  res <- preflight(
    packages       = "this_package_does_not_exist_zzz",
    env_vars       = unset_var_name(),
    check_versions = FALSE
  )
  expect_length(res, 2L)
  expect_true(preflight_blocking(res))
})

test_that("version checking degrades gracefully when no lockfile is found", {
  # Point discovery at a name that does not exist anywhere up the tree.
  res <- preflight(
    packages       = "testthat",
    check_versions = TRUE,
    lockfile_name  = "this_lockfile_does_not_exist.lock"
  )
  # No lockfile -> no version comparison -> clean.
  expect_identical(res, character(0))
})

test_that("preflight never throws, even on nonsense input", {
  expect_no_error(preflight(packages = NA_character_, check_versions = FALSE))
  expect_no_error(preflight(env_vars = c("", NA_character_), check_versions = FALSE))
})
