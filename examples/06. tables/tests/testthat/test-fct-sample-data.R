# Tests for the synthetic-data factories in R/fct_sample_data.R

test_that("make_adsl returns one deterministic row per subject", {
  a <- make_adsl()
  b <- make_adsl()

  expect_s3_class(a, "tbl_df")
  expect_equal(nrow(a), N_SUB)
  expect_equal(dplyr::n_distinct(a$USUBJID), N_SUB)   # unique subject ids
  expect_setequal(levels(a$ARM), ARMS)
  expect_equal(as.integer(table(a$ARM)), rep(N_SUB / 3, 3))  # balanced arms
  expect_identical(a, b)                              # fixed seed -> identical
})

test_that("make_adsl age groups are consistent with AGE", {
  a <- make_adsl()
  expect_true(all(a$AGE[a$AGEGR1 == "<45"] < 45))
  expect_true(all(a$AGE[a$AGEGR1 == ">=65"] >= 65))
  expect_setequal(levels(a$AGEGR1), c("<45", "45-64", ">=65"))
})

test_that("make_adae links to ADSL subjects and is ordered", {
  adsl <- make_adsl()
  adae <- make_adae(adsl)

  expect_gt(nrow(adae), 0)
  expect_true(all(adae$USUBJID %in% adsl$USUBJID))    # referential integrity
  expect_setequal(levels(adae$AESEV), c("MILD", "MODERATE", "SEVERE"))
  expect_true(all(adae$AESER %in% c("N", "Y")))
  expect_true(all(adae$AEENDY >= adae$AESTDY))        # end on/after start
})

test_that("make_adlb has one row per subject x param x visit with change", {
  adsl <- make_adsl()
  adlb <- make_adlb(adsl)

  n_expected <- nrow(adsl) * 4 * 5                    # 4 params, 5 visits
  expect_equal(nrow(adlb), n_expected)
  # Baseline rows: AVAL equals BASE and CHG is zero by construction.
  base <- dplyr::filter(adlb, AVISIT == "Baseline")
  expect_equal(base$AVAL, base$BASE)
  expect_true(all(base$CHG == 0))
  expect_true(all(adlb$ANRIND %in% c("NORMAL", "HIGH", "HIGH-3x")))
})

test_that("make_queries returns the editable-grid shape", {
  q <- make_queries(make_adsl())
  expect_equal(nrow(q), 25)
  expect_true(all(c("QUERYID", "STATUS", "PRIORITY", "CONFIRM") %in% names(q)))
  expect_type(q$CONFIRM, "logical")
  expect_setequal(levels(q$STATUS), c("Open", "Answered", "Closed"))
})
