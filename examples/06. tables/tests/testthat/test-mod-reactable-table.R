# testServer test for the reactable module (R/mod_reactable_table.R)
#
# getReactableState() is browser-only, so the selection panel is exercised by
# the AppDriver smoke test, not here. This confirms the module wires up and the
# table output is produced from the lab summary.

test_that("the reactable output renders without error", {
  adlb <- make_adlb(make_adsl())
  testServer(mod_reactable_table_server, args = list(adlb = adlb), {
    session$setInputs(group = TRUE)
    expect_true(!is.null(output$tbl))          # renderReactable produced output
    # The selection panel shows its empty-state prompt before any click.
    expect_true(!is.null(output$selected))
  })
})
