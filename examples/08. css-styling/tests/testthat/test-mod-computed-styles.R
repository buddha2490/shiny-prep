# test-mod-computed-styles.R --------------------------------------------------
# testServer() coverage of the computed-styles module's reactive logic: the
# flagged-count reactive must track the slider threshold against the data.

test_that("flagged_count tracks the threshold against subject completion", {
  subjects <- make_subjects()

  testServer(
    mod_computed_styles_server,
    args = list(subjects = subjects),
    {
      session$setInputs(threshold = 0)
      # Nobody is at or below 0% completion (min is 15 in the factory).
      expect_equal(session$returned$flagged_count(), sum(subjects$completion <= 0))

      session$setInputs(threshold = 100)
      # Everyone is at or below 100%.
      expect_equal(session$returned$flagged_count(), nrow(subjects))

      session$setInputs(threshold = 50)
      expect_equal(session$returned$flagged_count(), sum(subjects$completion <= 50))
    }
  )
})
