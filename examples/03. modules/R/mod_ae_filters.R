# =============================================================================
# R/mod_ae_filters.R — Tab 3: Shared State with reactiveValues (Writer)
# =============================================================================
# Purpose: Demonstrates the WRITER role in a reactiveValues shared-state
#          pattern. This module writes to an rv object created by the parent.
#
# Key teaching points:
#   1. reactiveValues() is created ONCE in the parent (server.R), not inside
#      any module. The parent passes it as an argument to all modules that need
#      it. This is the correct pattern — never create rv inside a module if
#      other modules need to share it.
#   2. The WRITER module (this file) sets fields on rv. Those writes
#      automatically invalidate any reactive context in OTHER modules that
#      reads those fields — no explicit wiring required.
#   3. Multiple READER modules can observe the same rv fields independently.
#      Each reader only re-executes when the specific fields it reads change.
#   4. Why rv > returning a reactive? When multiple modules need to READ the
#      same state, passing rv is cleaner than chaining return values through
#      server.R. Compare: one rv object passed to 3 modules vs. passing the
#      return value of module A to modules B and C separately.
#
# Created: 2026-06-18
# =============================================================================

# --- UI function -------------------------------------------------------------

#' AE Filter Controls — UI
#'
#' Renders controls for filtering the adverse events dataset: a subject
#' multi-select and a severity dropdown. Part of the Tab 3 reactiveValues
#' shared-state pattern.
#'
#' @param id Character scalar. Module namespace ID.
#' @param usubjid_choices Character vector. Subject IDs to populate the picker.
#'
#' @return A \code{card} containing the filter controls.
#'
#' @export
mod_ae_filters_ui <- function(id, usubjid_choices = character(0)) {
  ns <- NS(id)

  card(
    card_header("AE Filters"),

    # --- Severity filter --- [2026-06-18]
    # Writes to rv$severity_filter. Any module that reads rv$severity_filter
    # will re-execute when this changes.
    selectInput(
      inputId  = ns("severity"),
      label    = "Severity",
      choices  = c("All", "MILD", "MODERATE", "SEVERE"),
      selected = "All"
    ),

    # --- Serious AE toggle --- [2026-06-18]
    # Writes to rv$serious_only. Readers will re-execute when toggled.
    checkboxInput(
      inputId = ns("serious_only"),
      label   = "Serious AEs only (AESER = Y)",
      value   = FALSE
    ),

    # --- Subject selector --- [2026-06-18]
    # Allows focusing on a subset of subjects. Writes to rv$selected_subjects.
    selectInput(
      inputId  = ns("subjects"),
      label    = "Subject(s)",
      choices  = c("All Subjects" = "ALL", usubjid_choices),
      selected = "ALL",
      multiple = TRUE
    )
  )
}

# --- Server function ---------------------------------------------------------

#' AE Filter Controls — Server
#'
#' Observes filter inputs and writes the current selections to the shared
#' \code{rv} object. Does not render any outputs — it is a pure writer.
#'
#' @section reactiveValues write pattern:
#' \preformatted{
#'   observe({
#'     rv$severity_filter <- input$severity
#'   })
#' }
#' This observe() fires whenever \code{input$severity} changes and writes the
#' new value to \code{rv$severity_filter}. Any observer/reactive in any other
#' module that reads \code{rv$severity_filter} will then be invalidated and
#' re-execute. The write happens in an observe(), not a reactive(), because
#' we want the side effect (updating rv) to fire eagerly.
#'
#' @param id Character scalar. Module namespace ID.
#' @param rv A \code{reactiveValues} object created by the parent server.
#'   This module writes to: \code{rv$severity_filter}, \code{rv$serious_only},
#'   \code{rv$selected_subjects}.
#'
#' @return Nothing. Side effects only (writes to rv).
#'
#' @export
mod_ae_filters_server <- function(id, rv) {
  # --- Validate inputs --- [2026-06-18]
  if (!is.reactivevalues(rv)) {
    stop("`rv` must be a reactiveValues object created by the parent server.",
         call. = FALSE)
  }

  moduleServer(id, function(input, output, session) {

    # --- Write severity filter to shared state --- [2026-06-18]
    # observe() is the right primitive here: we want this side effect to fire
    # whenever the input changes. We do NOT return a value — writing to rv IS
    # the output of this module.
    observe({
      rv$severity_filter <- input$severity
    })

    # --- Write serious-only flag to shared state --- [2026-06-18]
    observe({
      rv$serious_only <- input$serious_only
    })

    # --- Write selected subjects to shared state --- [2026-06-18]
    # "ALL" is a sentinel value meaning no subject filter.
    # Reader modules check for "ALL" and skip filtering when it's present.
    observe({
      rv$selected_subjects <- input$subjects
    })
  })
}
