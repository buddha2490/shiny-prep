# test-fct-sample-data.R ------------------------------------------------------
# Unit tests for the synthetic-data factories. They are deterministic (seeded),
# so we can assert exact shapes and the downstream derivations.

test_that("make_adsl returns the expected shape and columns", {
  adsl <- make_adsl(n = 60)

  expect_s3_class(adsl, "tbl_df")
  expect_equal(nrow(adsl), 60)
  expect_setequal(
    names(adsl),
    c("USUBJID", "ARM", "AGE", "SEX", "REGION", "ENRLDT", "SAFFL")
  )
  expect_s3_class(adsl$ENRLDT, "Date")
  expect_true(all(adsl$SAFFL %in% c("Y", "N")))
  expect_equal(nlevels(adsl$ARM), 3)
})

test_that("make_adsl is deterministic", {
  expect_identical(make_adsl(30), make_adsl(30))
})

test_that("make_adsl validates n", {
  expect_error(make_adsl(0), "positive")
  expect_error(make_adsl("x"), "positive")
  expect_error(make_adsl(c(1, 2)), "positive")
})

test_that("make_enrollment yields a monotonic cumulative curve", {
  enr <- make_enrollment(make_adsl(60))

  expect_setequal(names(enr), c("WEEK", "CUM_ENROLLED"))
  expect_s3_class(enr$WEEK, "Date")
  # Cumulative sum must be non-decreasing and end at the subject count.
  expect_false(is.unsorted(enr$CUM_ENROLLED))
  expect_equal(max(enr$CUM_ENROLLED), 60)
})

test_that("make_enrollment validates its input", {
  expect_error(make_enrollment(data.frame(x = 1)), "ENRLDT")
  expect_error(make_enrollment("nope"), "data frame")
})

test_that("make_ae_by_arm returns one row per arm with plausible counts", {
  ae <- make_ae_by_arm(make_adsl(60))

  expect_setequal(names(ae), c("ARM", "N_SUBJ", "N_AE"))
  expect_equal(nrow(ae), 3)
  expect_true(all(ae$N_AE >= 0))
  # AE burden should rise with dose given the fabricated rates.
  high <- ae$N_AE[ae$ARM == "High Dose"]
  placebo <- ae$N_AE[ae$ARM == "Placebo"]
  expect_gt(high, placebo)
})

test_that("make_ae_by_arm validates its input", {
  expect_error(make_ae_by_arm(data.frame(x = 1)), "ARM")
})
