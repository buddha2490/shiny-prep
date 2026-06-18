# =============================================================================
# R/mod_profile_aes.R — Tab 5: Nested Modules (Inner: AE Listing)
# =============================================================================
# Purpose: An INNER module called by mod_patient_profile. Displays AEs for the
#          selected patient. Third inner module — shows that a single outer
#          module can coordinate any number of inner modules.
#
# Key teaching points:
#   1. All three inner modules (header, labs, aes) follow the same pattern:
#      receive a reactive, call it with (), render content. The pattern is
#      identical regardless of what they display.
#   2. Inner modules are completely reusable — mod_profile_aes could be used
#      in a different outer module with zero changes.
#
# Created: 2026-06-18
# =============================================================================

#' Patient Profile AEs — UI
#'
#' Renders a DT table of adverse events for one patient. Called inside
#' \code{mod_patient_profile_ui()} with a namespaced ID.
#'
#' @param id Character scalar. Module namespace ID.
#'
#' @return A \code{card} tag object.
#'
#' @export
mod_profile_aes_ui <- function(id) {
  ns <- NS(id)

  card(
    card_header("Adverse Events"),
    DTOutput(ns("ae_table"))
  )
}

#' Patient Profile AEs — Server
#'
#' Renders a DT table from the AE data reactive supplied by the outer module.
#'
#' @param id Character scalar. Module namespace ID.
#' @param ae_data A reactive expression returning a data frame of ADAE rows
#'   for the selected patient.
#'
#' @return Nothing. Side effects only (output rendering).
#'
#' @export
mod_profile_aes_server <- function(id, ae_data) {
  # --- Validate inputs --- [2026-06-18]
  if (!is.reactive(ae_data)) {
    stop("`ae_data` must be a reactive expression.", call. = FALSE)
  }

  moduleServer(id, function(input, output, session) {

    # --- Render AE table --- [2026-06-18]
    output$ae_table <- renderDT({
      df <- ae_data()
      if (nrow(df) == 0) {
        return(datatable(
          data.frame(Message = "No adverse events recorded for this patient."),
          rownames = FALSE,
          options  = list(dom = "t")
        ))
      }
      datatable(
        df %>% select(AEDECOD, AESEV, AESER, AESTDTC),
        options  = list(pageLength = 8, scrollX = TRUE),
        rownames = FALSE
      )
    })
  })
}
