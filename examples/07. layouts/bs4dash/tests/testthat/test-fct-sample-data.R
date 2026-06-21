# test-fct-sample-data.R ------------------------------------------------------
#
# Unit tests for the synthetic-data factories. These prove the contract the
# whole dashboard depends on: stable shapes, expected columns, deterministic
# output, and clean validation errors (testing rule 1).

test_that("make_adsl returns the expected shape and columns", {
  adsl <- make_adsl(30)
  expect_s3_class(adsl, "tbl_df")
  expect_identical(nrow(adsl), 30L)
  expect_setequal(
    names(adsl),
    c("USUBJID", "ARM", "AGE", "SEX", "REGION", "ENROLL_DT")
  )
  expect_s3_class(adsl$ENROLL_DT, "Date")
  expect_s3_class(adsl$ARM, "factor")
})

test_that("make_adsl is deterministic", {
  expect_identical(make_adsl(20), make_adsl(20))
})

test_that("make_adsl rejects bad n", {
  expect_error(make_adsl(0), "positive")
  expect_error(make_adsl("x"), "positive")
})

test_that("make_enrollment returns a cumulative, monotone curve", {
  enr <- make_enrollment(make_adsl(40))
  expect_setequal(names(enr), c("MONTH", "N", "CUM_N"))
  expect_s3_class(enr$MONTH, "Date")
  # Cumulative count must be non-decreasing and end at the subject total.
  expect_true(all(diff(enr$CUM_N) >= 0))
  expect_identical(max(enr$CUM_N), sum(enr$N))
})

test_that("make_enrollment validates its input", {
  expect_error(make_enrollment(list()), "ENROLL_DT")
})

test_that("make_ae_counts covers every arm x severity cell", {
  adsl <- make_adsl(50)
  ae <- make_ae_counts(adsl)
  expect_setequal(names(ae), c("ARM", "SEVERITY", "N"))
  expect_identical(nrow(ae), nlevels(adsl$ARM) * 3L)
  expect_true(all(ae$N >= 0))
})

test_that("make_ae_counts validates its input", {
  expect_error(make_ae_counts(data.frame(x = 1)), "ARM")
})
