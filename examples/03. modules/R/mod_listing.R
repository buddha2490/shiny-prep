# =============================================================================
# R/mod_listing.R — Tab 2: Module Communication (Listing Consumer)
# =============================================================================
# Purpose: Demonstrates how a module CONSUMES a reactive returned by another
#          module (mod_filter). This is the second half of the inter-module
#          communication pattern.
#
# Key teaching points:
#   1. The `data` argument to mod_listing_server() is a REACTIVE, not a data
#      frame. Inside the server, call data() with parentheses to read the
#      current value and subscribe to future changes.
#   2. This module has no knowledge of HOW the data is filtered. It only knows
#      it will receive a reactive that resolves to a data frame. This decouples
#      the filter logic from the display logic.
#   3. The `data()` call inside renderDT() creates a reactive dependency:
#      whenever the filter module's reactive fires (because ARM or SEX changed),
#      this render function re-executes automatically.
#   4. Naming convention: when passing a reactive as an argument, name the
#      parameter with a plain noun (e.g., `data`, not `data_reactive`). The
#      parentheses at the call site make it clear it's a reactive.
#
# Created: 2026-06-18
# =============================================================================

# --- UI function -------------------------------------------------------------

#' Subject Listing Table — UI
#'
#' Displays a DT table of subjects filtered by \code{mod_filter}.
#' Part of the Tab 2 module communication pattern.
#'
#' @param id Character scalar. Module namespace ID.
#'
#' @return A \code{card} containing the DT table output.
#'
#' @export
mod_listing_ui <- function(id) {
  ns <- NS(id)

  card(
    card_header("Subject Listing"),
    # --- Table output --- [2026-06-18]
    # This DTOutput is populated by the renderDT() in the server function
    # below. The data it displays comes from the reactive passed in as the
    # `data` argument — it does not know or care where that reactive comes from.
    DTOutput(ns("subject_table"))
  )
}

# --- Server function ---------------------------------------------------------

#' Subject Listing Table — Server
#'
#' Renders a DT table from a reactive data frame supplied by another module.
#' This server function CONSUMES the reactive returned by
#' \code{mod_filter_server()}.
#'
#' @section The parentheses convention:
#' Inside this function, \code{data()} is called with parentheses. This is
#' the convention for reading a reactive:
#' \itemize{
#'   \item \code{data} — the reactive object itself (a function)
#'   \item \code{data()} — the current value of the reactive (a data frame)
#' }
#' Passing \code{data} without parentheses to \code{datatable()} would pass
#' a function object, causing an error. Always use \code{data()} inside
#' reactive contexts.
#'
#' @param id Character scalar. Module namespace ID.
#' @param data A reactive expression that returns a data frame. Typically the
#'   value returned by \code{mod_filter_server()}.
#'
#' @return Nothing. Side effects only (output rendering).
#'
#' @export
mod_listing_server <- function(id, data) {
  # --- Validate inputs --- [2026-06-18]
  # Check that `data` is reactive. If the caller passes a plain data frame
  # (forgetting the reactive wrapper), downstream reactivity will silently
  # fail — the table will show initial data but never update.
  if (!is.reactive(data)) {
    stop("`data` must be a reactive expression. Did you forget to pass the return value of mod_filter_server()?",
         call. = FALSE)
  }

  moduleServer(id, function(input, output, session) {

    # --- Render DT table --- [2026-06-18]
    # data() is called with parentheses to (a) read the current value and
    # (b) register this renderDT as a dependent on the reactive. When the
    # filter module updates, renderDT re-executes without any explicit wiring.
    # That automatic dependency tracking is core Shiny reactivity.
    output$subject_table <- renderDT({
      datatable(
        data(),
        options  = list(pageLength = 10, scrollX = TRUE),
        rownames = FALSE,
        caption  = paste0("Filtered subject listing — ", nrow(data()), " subjects")
      )
    })
  })
}
