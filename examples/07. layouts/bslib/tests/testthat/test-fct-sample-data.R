# =============================================================================
# test-fct-sample-data.R — unit tests for the synthetic data factories
# =============================================================================
# Factories must be reproducible (seeded) and structurally correct, because both
# the running app and every other test build on them.

test_that("make_adsl returns a well-formed, reproducible ADSL", {
  adsl1 <- make_adsl()
  adsl2 <- make_adsl()

  # Reproducible: the seed inside the factory => identical output each call.
  expect_identical(adsl1, adsl2)

  expect_s3_class(adsl1, "tbl_df")
  expect_setequal(
    names(adsl1),
    c("USUBJID", "ARM", "AGE", "SEX", "REGION", "ENRLDT")
  )
  expect_equal(nrow(adsl1), 60)

  # ARM is the expected 3-level factor.
  expect_setequal(levels(adsl1$ARM), c("Placebo", "Low Dose", "High Dose"))

  # AGE is clamped to the clinically plausible band.
  expect_true(all(adsl1$AGE >= 22 & adsl1$AGE <= 84))

  # USUBJID is unique (an identifier contract).
  expect_equal(length(unique(adsl1$USUBJID)), nrow(adsl1))

  expect_s3_class(adsl1$ENRLDT, "Date")
})

test_that("make_enrollment yields monotonically increasing cumulative counts", {
  enr <- make_enrollment()

  expect_setequal(
    names(enr),
    c("ARM", "week", "n_enrolled", "cumulative")
  )

  # Within each arm, cumulative enrollment never decreases.
  by_arm <- split(enr, enr$ARM)
  for (a in by_arm) {
    a <- a[order(a$week), ]
    expect_true(all(diff(a$cumulative) >= 0))
  }

  # Total enrolled across all arms == number of subjects in the ADSL.
  expect_equal(sum(enr$n_enrolled), nrow(make_adsl()))
})

test_that("make_ae_counts has one row per arm x severity with positive counts", {
  ae <- make_ae_counts()

  expect_equal(nrow(ae), 3 * 3)
  expect_setequal(names(ae), c("ARM", "SEVERITY", "n_ae"))
  expect_true(all(ae$n_ae > 0))
  expect_setequal(levels(ae$SEVERITY), c("Mild", "Moderate", "Severe"))
})

test_that("lubridate_floor_week returns the Monday on or before a date", {
  # 2025-01-01 is a Wednesday -> floor to Monday 2024-12-30.
  expect_equal(lubridate_floor_week(as.Date("2025-01-01")),
               as.Date("2024-12-30"))
  # A Monday floors to itself.
  expect_equal(lubridate_floor_week(as.Date("2025-01-06")),
               as.Date("2025-01-06"))
})
