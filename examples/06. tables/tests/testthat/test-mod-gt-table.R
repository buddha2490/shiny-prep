# testServer + builder tests for the gt module (R/mod_gt_table.R)

test_that("the gt builders return gt_tbl objects that render to HTML", {
  adsl <- make_adsl()
  adae <- make_adae(adsl)

  t1 <- .gt_table1(adsl)
  expect_s3_class(t1, "gt_tbl")
  expect_gt(nchar(as.character(gt::as_raw_html(t1))), 1000)

  ae <- .gt_ae(adae, adsl)
  expect_s3_class(ae, "gt_tbl")
  expect_gt(nchar(as.character(gt::as_raw_html(ae))), 1000)
})

test_that("the radio switches the active table and header", {
  adsl <- make_adsl()
  adae <- make_adae(adsl)
  testServer(
    mod_gt_table_server,
    args = list(adae = adae, adsl = adsl),
    {
      session$setInputs(which = "t1")
      expect_match(output$hdr, "Baseline")
      expect_s3_class(current_gt(), "gt_tbl")

      session$setInputs(which = "ae")
      expect_match(output$hdr, "System Organ Class")
      expect_s3_class(current_gt(), "gt_tbl")
    }
  )
})
