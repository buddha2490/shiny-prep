# =============================================================================
# R/mod_r6_selector.R — Tab 4: Shared State with R6 (Selector / Writer)
# =============================================================================
# Purpose: Demonstrates the WRITER role in an R6 shared-state pattern.
#          The user selects a patient; this module calls store$set_patient()
#          which triggers reactive invalidation in any module that called
#          store$get_patient().
#
# Key teaching points:
#   1. The module interacts with R6 state through METHODS (set_patient,
#      get_patient), not by directly reading/writing fields. This encapsulates
#      the state management logic inside the R6 class.
#   2. Calling store$set_patient() inside observe() is the write operation.
#      It updates the reactiveVal inside the R6 instance, which automatically
#      invalidates all consumers that called store$get_patient().
#   3. The R6 instance (store) is passed as a plain argument — it is not
#      reactive itself. Only the reactiveVal INSIDE it is reactive. This means
#      you can call store$set_patient() outside a reactive context (e.g., in
#      a test) without errors.
#   4. Compare to reactiveValues: with rv you'd write rv$selected <- input$pt.
#      With R6, the write is mediated by a method: store$set_patient(input$pt).
#      The method can validate the input, log the change, enforce business
#      rules, etc. — that's the advantage of R6 over raw rv.
#
# Created: 2026-06-18
# =============================================================================

# --- UI function -------------------------------------------------------------

#' Patient Selector — UI
#'
#' Renders a dropdown to select a patient from the ADSL dataset.
#' Part of the Tab 4 R6 shared-state pattern.
#'
#' @param id Character scalar. Module namespace ID.
#' @param usubjid_choices Character vector. Subject IDs to populate the picker.
#'
#' @return A \code{card} containing the patient selector.
#'
#' @export
mod_r6_selector_ui <- function(id, usubjid_choices = character(0)) {
  ns <- NS(id)

  card(
    card_header("Patient Selector"),
    selectInput(
      inputId  = ns("patient"),
      label    = "Select Patient (USUBJID)",
      choices  = c("— select —" = "", usubjid_choices),
      selected = ""
    ),
    tags$p(
      class = "text-muted small",
      "Selecting a patient updates the detail panel via the R6 PatientStore."
    )
  )
}

# --- Server function ---------------------------------------------------------

#' Patient Selector — Server
#'
#' Observes the patient dropdown and writes the selection to the shared R6
#' \code{PatientStore}. Demonstrates the WRITER role in the R6 shared-state
#' pattern.
#'
#' @param id Character scalar. Module namespace ID.
#' @param store A \code{PatientStore} R6 instance created by the parent server.
#' @param adsl Data frame. Subject-level dataset (used for validation context).
#'
#' @return Nothing. Side effects only (writes to store via set_patient()).
#'
#' @export
mod_r6_selector_server <- function(id, store, adsl) {
  # --- Validate inputs --- [2026-06-18]
  if (!inherits(store, "PatientStore")) {
    stop("`store` must be a PatientStore R6 instance.", call. = FALSE)
  }
  if (!is.data.frame(adsl)) {
    stop("`adsl` must be a data frame.", call. = FALSE)
  }

  moduleServer(id, function(input, output, session) {

    # --- Write selection to R6 store --- [2026-06-18]
    # observe() fires whenever input$patient changes. We call store$set_patient()
    # rather than writing to a reactiveValues field directly. The R6 method
    # handles validation (see R6_PatientStore.R) and updates the internal
    # reactiveVal, which triggers invalidation of all readers.
    #
    # NULL handling: if the user selects the blank option (""), we pass NULL
    # to store$set_patient() to clear the selection gracefully.
    observe({
      selected <- input$patient
      if (is.null(selected) || selected == "") {
        store$set_patient(NULL)
      } else {
        store$set_patient(selected)
      }
    })
  })
}
