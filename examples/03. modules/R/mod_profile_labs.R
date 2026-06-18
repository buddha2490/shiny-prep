# =============================================================================
# R/mod_profile_labs.R — Tab 5: Nested Modules (Inner: Lab Results)
# =============================================================================
# Purpose: An INNER module called by mod_patient_profile. Displays a lab
#          results table for the selected patient. Demonstrates how inner
#          modules display their slice of patient data independently.
#
# Key teaching points:
#   1. This module receives a reactive of pre-filtered lab data. The outer
#      module (mod_patient_profile) does the patient filtering; this inner
#      module only handles rendering. Clean separation of concerns.
#   2. The module is self-contained — it can be tested in isolation by
#      passing a reactive wrapping any data frame.
#
# Created: 2026-06-18
# =============================================================================

#' Patient Profile Labs — UI
#'
#' Renders a DT table of lab results for one patient. Called inside
#' \code{mod_patient_profile_ui()} with a namespaced ID.
#'
#' @param id Character scalar. Module namespace ID.
#'
#' @return A \code{card} tag object.
#'
#' @export
mod_profile_labs_ui <- function(id) {
  ns <- NS(id)

  card(
    card_header("Lab Results"),
    DTOutput(ns("labs_table"))
  )
}

#' Patient Profile Labs — Server
#'
#' Renders a DT table from the lab data reactive supplied by the outer module.
#'
#' @param id Character scalar. Module namespace ID.
#' @param labs_data A reactive expression returning a data frame of ADLB rows
#'   for the selected patient.
#'
#' @return Nothing. Side effects only (output rendering).
#'
#' @export
mod_profile_labs_server <- function(id, labs_data) {
  # --- Validate inputs --- [2026-06-18]
  if (!is.reactive(labs_data)) {
    stop("`labs_data` must be a reactive expression.", call. = FALSE)
  }

  moduleServer(id, function(input, output, session) {

    # --- Render lab results table --- [2026-06-18]
    # req() prevents rendering an empty table before a patient is selected.
    output$labs_table <- renderDT({
      df <- labs_data()
      req(nrow(df) > 0)
      datatable(
        df %>% select(PARAMCD, PARAM, VISIT, BASE, AVAL, CHG),
        options  = list(pageLength = 8, scrollX = TRUE),
        rownames = FALSE
      )
    })
  })
}
