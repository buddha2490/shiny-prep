# testServer test for the rhandsontable module (R/mod_rhandsontable_table.R)
#
# The Handsontable widget input (input$tbl) is browser-only JSON, so save/edit
# round-trips are exercised by the AppDriver smoke test. Here we confirm the
# module initialises, derives its due-date column, and renders the status block
# and table output from the seeded reactiveValues store.

test_that("the module initialises with the seeded query grid", {
  q <- make_queries(make_adsl())
  testServer(mod_rhandsontable_table_server, args = list(queries = q), {
    expect_true(!is.null(output$tbl))          # renderRHandsontable output
    expect_true(!is.null(output$status))       # sidebar status block
    # edited() falls back to the saved store when input$tbl is NULL.
    ed <- edited()
    expect_equal(nrow(ed), nrow(q))
    expect_true("DUEDATE" %in% names(ed))
    expect_s3_class(ed$DUEDATE, "Date")
  })
})

test_that("reset restores the initial saved state", {
  q <- make_queries(make_adsl())
  testServer(mod_rhandsontable_table_server, args = list(queries = q), {
    session$setInputs(reset = 1)
    expect_equal(nrow(rv$data), nrow(q))
  })
})
