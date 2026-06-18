# =============================================================================
# R/mod_ae_table.R — Tab 3: Shared State with reactiveValues (Table Reader)
# =============================================================================
# Purpose: Demonstrates the READER role in a reactiveValues shared-state
#          pattern. Reads rv fields set by mod_ae_filters and renders a table.
#
# Key teaching points:
#   1. This module reads rv$severity_filter, rv$serious_only, and
#      rv$selected_subjects directly from the shared rv object. It never
#      knows about the UI inputs that produced those values.
#   2. Reading rv$field inside a reactive() or renderDT() creates a dependency.
#      When mod_ae_filters writes a new value to rv$severity_filter, THIS
#      module's reactive automatically re-executes — no observer or explicit
#      wiring needed.
#   3. Multiple readers can independently read the same rv fields. Each reader
#      tracks only the fields it accessed — granular dependency tracking.
#
# Created: 2026-06-18
# =============================================================================

# --- UI function -------------------------------------------------------------

#' AE Listing Table — UI
#'
#' Renders a DT table of adverse events filtered by the shared \code{rv} state.
#' Part of the Tab 3 reactiveValues shared-state pattern.
#'
#' @param id Character scalar. Module namespace ID.
#'
#' @return A \code{card} containing the AE DT table.
#'
#' @export
mod_ae_table_ui <- function(id) {
  ns <- NS(id)

  card(
    card_header("Adverse Event Listing (ADAE)"),
    DTOutput(ns("ae_table"))
  )
}

# --- Server function ---------------------------------------------------------

#' AE Listing Table — Server
#'
#' Reads the shared \code{rv} object to filter \code{adae} and renders a DT
#' table. Demonstrates the READER side of the reactiveValues shared-state
#' pattern.
#'
#' @param id Character scalar. Module namespace ID.
#' @param rv A \code{reactiveValues} object. This module reads:
#'   \code{rv$severity_filter}, \code{rv$serious_only},
#'   \code{rv$selected_subjects}.
#' @param adae Data frame. Full adverse events dataset.
#'
#' @return Nothing. Side effects only (output rendering).
#'
#' @export
mod_ae_table_server <- function(id, rv, adae) {
  # --- Validate inputs --- [2026-06-18]
  if (!is.reactivevalues(rv)) {
    stop("`rv` must be a reactiveValues object.", call. = FALSE)
  }
  if (!is.data.frame(adae)) {
    stop("`adae` must be a data frame.", call. = FALSE)
  }

  moduleServer(id, function(input, output, session) {

    # --- Filtered AE reactive --- [2026-06-18]
    # Reading rv$severity_filter, rv$serious_only, and rv$selected_subjects
    # inside this reactive() creates reactive dependencies on all three fields.
    # Any time mod_ae_filters writes a new value to ANY of these fields,
    # this reactive re-executes and the table re-renders.
    filtered_ae <- reactive({
      # Reading rv fields: these are the reactive dependencies.
      severity  <- rv$severity_filter
      serious   <- rv$serious_only
      subjects  <- rv$selected_subjects

      result <- adae

      # Apply severity filter
      if (!is.null(severity) && severity != "All") {
        result <- result %>% filter(AESEV == severity)
      }

      # Apply serious AE filter
      if (isTRUE(serious)) {
        result <- result %>% filter(AESER == "Y")
      }

      # Apply subject filter (skip if "ALL" sentinel or NULL)
      if (!is.null(subjects) && !("ALL" %in% subjects)) {
        result <- result %>% filter(USUBJID %in% subjects)
      }

      result
    })

    # --- Render the AE table --- [2026-06-18]
    output$ae_table <- renderDT({
      df <- filtered_ae()
      datatable(
        df %>% select(USUBJID, AEDECOD, AESEV, AESER, AESTDTC, ARM),
        options  = list(pageLength = 10, scrollX = TRUE),
        rownames = FALSE,
        caption  = paste0(nrow(df), " adverse event records")
      )
    })
  })
}
