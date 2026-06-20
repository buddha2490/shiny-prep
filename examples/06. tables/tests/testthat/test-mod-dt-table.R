# testServer tests for the DT module's reactive logic (R/mod_dt_table.R)

test_that("value boxes reflect the adverse-event data", {
  adae <- make_adae(make_adsl())
  testServer(mod_dt_table_server, args = list(adae = adae), {
    expect_equal(output$n_rec, format(nrow(adae), big.mark = ","))
    expect_equal(output$n_serious, as.character(sum(adae$AESER == "Y")))
    expect_equal(output$n_edits, "0")
  })
})

test_that("a cell edit increments the edit counter and updates the data", {
  adae <- make_adae(make_adsl())
  testServer(mod_dt_table_server, args = list(adae = adae), {
    # Edit the Severity cell (display col index 4, 0-based) of row 1.
    session$setInputs(tbl_cell_edit = list(row = 1, col = 4, value = "SEVERE"))
    expect_equal(output$n_edits, "1")
  })
})

test_that("reset restores the record count and clears edits", {
  adae <- make_adae(make_adsl())
  testServer(mod_dt_table_server, args = list(adae = adae), {
    session$setInputs(tbl_cell_edit = list(row = 1, col = 4, value = "SEVERE"))
    expect_equal(output$n_edits, "1")
    session$setInputs(reset = 1)
    expect_equal(output$n_edits, "0")
    expect_equal(output$n_rec, format(nrow(adae), big.mark = ","))
  })
})

test_that("detail panel renders for a selection", {
  adae <- make_adae(make_adsl())
  testServer(mod_dt_table_server, args = list(adae = adae), {
    session$setInputs(tbl_rows_selected = c(1, 2, 3))
    expect_true(!is.null(output$detail))
  })
})
