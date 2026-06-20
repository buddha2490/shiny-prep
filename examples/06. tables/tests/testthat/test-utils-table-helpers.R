# Tests for the data-prep helpers in R/utils_table_helpers.R

test_that("summarise_labs yields one row per parameter x arm with a 5-pt trend", {
  adsl <- make_adsl()
  adlb <- make_adlb(adsl)
  s <- summarise_labs(adlb)

  expect_equal(nrow(s), 4 * 3)                        # 4 params x 3 arms
  expect_true(all(c("n_subj", "base_mean", "end_mean",
                    "chg_mean", "pct_high", "trend") %in% names(s)))
  expect_type(s$trend, "list")
  expect_true(all(lengths(s$trend) == 5))             # one mean per visit
  expect_true(all(s$pct_high >= 0 & s$pct_high <= 1)) # a proportion
  expect_true(all(s$n_subj == 40))                    # 40 subjects per arm
})

test_that("build_table1 pivots arms to columns with a Total", {
  adsl <- make_adsl()
  t1 <- build_table1(adsl)

  expect_true(all(c("group", "label", "Placebo", "Low Dose",
                    "High Dose", "Total") %in% names(t1)))
  expect_s3_class(t1$group, "factor")
  # The N row sums across arms to the total cohort.
  n_row <- t1[t1$label == "N", ]
  expect_equal(as.integer(n_row$Total), nrow(adsl))
  # Age-group rows keep clinical order, not alphabetical.
  ag <- t1$label[t1$group == "Age group, n (%)"]
  expect_equal(ag, c("<45", "45-64", ">=65"))
})

test_that("build_ae_summary gives subject incidence by SOC with arm rates", {
  adsl <- make_adsl()
  adae <- make_adae(adsl)
  s <- build_ae_summary(adae, adsl)

  expect_true(all(c("AEBODSYS", "n_PBO", "n_LD", "n_HD",
                    "pct_PBO", "pct_LD", "pct_HD") %in% names(s)))
  # Incidence counts never exceed the arm denominator (40).
  expect_true(all(s$n_PBO <= 40 & s$n_LD <= 40 & s$n_HD <= 40))
  # Percentages equal count / 40.
  expect_equal(s$pct_HD, s$n_HD / 40)
  # Rows sorted by descending total incidence.
  totals <- s$n_PBO + s$n_LD + s$n_HD
  expect_false(is.unsorted(rev(totals)))
})
