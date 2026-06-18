# =============================================================================
# R/mod_ae_summary.R — Tab 3: Shared State with reactiveValues (Summary Reader)
# =============================================================================
# Purpose: Second READER module in the Tab 3 reactiveValues pattern. Reads the
#          same rv fields as mod_ae_table but renders value boxes instead of a
#          table. Demonstrates that multiple independent readers can consume the
#          same shared state without any coupling between them.
#
# Key teaching points:
#   1. Two reader modules (this file + mod_ae_table) both read rv$severity_filter
#      etc. They are completely independent: changing rv does NOT cause them to
#      communicate with each other — each independently re-executes when rv
#      changes.
#   2. Both readers re-execute when the SAME rv field changes. Shiny tracks
#      dependencies per-reactive, not per-module. There is no overhead from
#      having multiple readers.
#   3. This module shows summary counts (value boxes), while mod_ae_table shows
#      the full listing. Both stay synchronized automatically through rv.
#
# Created: 2026-06-18
# =============================================================================

# --- UI function -------------------------------------------------------------

#' AE Summary Cards — UI
#'
#' Renders value boxes summarizing adverse event counts by severity.
#' Part of the Tab 3 reactiveValues shared-state pattern.
#'
#' @param id Character scalar. Module namespace ID.
#'
#' @return A \code{layout_columns} containing summary value boxes.
#'
#' @export
mod_ae_summary_ui <- function(id) {
  ns <- NS(id)

  # --- Value box layout --- [2026-06-18]
  # Three value boxes: total AEs, unique subjects, and severe AEs.
  # Each is a separate output rendered by the server below.
  layout_columns(
    col_widths = c(4, 4, 4),
    value_box(
      title = "Total AEs",
      value = textOutput(ns("total_ae"), inline = TRUE),
      theme = "primary"
    ),
    value_box(
      title = "Unique Subjects",
      value = textOutput(ns("unique_subjects"), inline = TRUE),
      theme = "secondary"
    ),
    value_box(
      title = "Severe AEs",
      value = textOutput(ns("severe_ae"), inline = TRUE),
      theme = "danger"
    )
  )
}

# --- Server function ---------------------------------------------------------

#' AE Summary Cards — Server
#'
#' Reads the shared \code{rv} object to compute AE summary statistics and
#' renders value box outputs. Demonstrates that a second independent reader
#' module can observe the same \code{rv} fields as another reader module with
#' no coupling between the two readers.
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
mod_ae_summary_server <- function(id, rv, adae) {
  # --- Validate inputs --- [2026-06-18]
  if (!is.reactivevalues(rv)) {
    stop("`rv` must be a reactiveValues object.", call. = FALSE)
  }
  if (!is.data.frame(adae)) {
    stop("`adae` must be a data frame.", call. = FALSE)
  }

  moduleServer(id, function(input, output, session) {

    # --- Filtered AE reactive (shared logic) --- [2026-06-18]
    # This mirrors the same filtering logic as mod_ae_table. In a production
    # app, you would extract this into a shared utility function (utils_ae.R)
    # to avoid duplication. Here it's repeated for clarity — this is a
    # teaching app where seeing the full pattern in each file is intentional.
    filtered_ae <- reactive({
      severity <- rv$severity_filter
      serious  <- rv$serious_only
      subjects <- rv$selected_subjects

      result <- adae

      if (!is.null(severity) && severity != "All") {
        result <- result %>% filter(AESEV == severity)
      }
      if (isTRUE(serious)) {
        result <- result %>% filter(AESER == "Y")
      }
      if (!is.null(subjects) && !("ALL" %in% subjects)) {
        result <- result %>% filter(USUBJID %in% subjects)
      }

      result
    })

    # --- Total AE count --- [2026-06-18]
    output$total_ae <- renderText({
      nrow(filtered_ae())
    })

    # --- Unique subjects count --- [2026-06-18]
    output$unique_subjects <- renderText({
      filtered_ae() %>%
        pull(USUBJID) %>%
        n_distinct()
    })

    # --- Severe AE count --- [2026-06-18]
    # Counts SEVERE AEs regardless of the severity filter, so the card is
    # always informative even when the user is looking at all severities.
    output$severe_ae <- renderText({
      filtered_ae() %>%
        filter(AESEV == "SEVERE") %>%
        nrow()
    })
  })
}
