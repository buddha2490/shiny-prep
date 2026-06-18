# =============================================================================
# R/mod_patient_profile.R — Tab 5: Nested Modules (Outer Module)
# =============================================================================
# Purpose: Demonstrates the OUTER module pattern. This module contains a
#          patient selector and coordinates three INNER modules (header, labs,
#          aes). Inner modules are called inside the outer module's UI and
#          server functions.
#
# Key teaching points:
#   1. NS NESTING: The outer module has its own namespace (id). When calling
#      inner module UIs, the outer module passes NS(id)("inner_id") as the id
#      argument. At runtime this produces IDs like:
#        "patient_profile-header"
#        "patient_profile-labs"
#        "patient_profile-aes"
#      The inner module then further namespaces its own inputs/outputs, e.g.:
#        "patient_profile-header-header_content"
#      Shiny resolves all of this automatically — you never manually construct
#      these compound IDs. The key rule: always use ns() in the outer UI to
#      wrap inner module IDs.
#
#   2. In the SERVER, inner module servers are called inside moduleServer().
#      The id argument for each inner server is ns(inner_id) — NOT just
#      inner_id — because the inner module's namespace must be nested under
#      the outer module's namespace to match what was rendered in the UI.
#
#   3. Data FLOWS DOWN: The outer module filters the datasets for the selected
#      patient, wraps them in reactives, and passes those reactives to the
#      inner modules. Inner modules never touch the full datasets.
#
#   4. The outer module is itself a normal module — it can be called from
#      server.R with a plain string id, no special handling required.
#
# Created: 2026-06-18
# =============================================================================

#' Patient Profile — Outer Module UI
#'
#' Renders a patient selector and calls three inner module UIs:
#' \code{mod_profile_header_ui}, \code{mod_profile_labs_ui}, and
#' \code{mod_profile_aes_ui}. Inner module IDs are wrapped with
#' \code{ns()} to nest them under the outer namespace.
#'
#' @param id Character scalar. The outer module namespace ID.
#' @param usubjid_choices Character vector. Patient IDs for the selector.
#'
#' @return A \code{tagList} of the patient selector card and three inner
#'   module cards.
#'
#' @export
mod_patient_profile_ui <- function(id, usubjid_choices = character(0)) {
  # --- Outer namespace function --- [2026-06-18]
  # ns() will be used to namespace BOTH the outer module's own inputs/outputs
  # AND the IDs passed to inner module UI functions. This is the critical step
  # that creates nested namespaces.
  ns <- NS(id)

  tagList(
    # --- Patient selector (outer module's own input) --- [2026-06-18]
    card(
      card_header("Patient Selector"),
      selectInput(
        inputId  = ns("patient"),       # Outer ns: "patient_profile-patient"
        label    = "Select Patient",
        choices  = c("-- select --" = "", usubjid_choices),
        selected = "",
        selectize = FALSE
      )
    ),

    # --- Inner module UIs --- [2026-06-18]
    # Key: pass ns("header"), ns("labs"), ns("aes") as the id argument to each
    # inner module. This nests the inner namespace under the outer namespace.
    # At runtime:
    #   mod_profile_header_ui(ns("header")) produces IDs like
    #   "patient_profile-header-header_content"
    mod_profile_header_ui(ns("header")),
    mod_profile_labs_ui(ns("labs")),
    mod_profile_aes_ui(ns("aes"))
  )
}

#' Patient Profile — Outer Module Server
#'
#' Manages patient selection, filters datasets for the selected patient, and
#' calls three inner module servers — passing pre-filtered reactive data to
#' each. Demonstrates the full outer module pattern with nested namespacing.
#'
#' @param id Character scalar. The outer module namespace ID. Must match the
#'   id passed to \code{mod_patient_profile_ui()}.
#' @param adsl Data frame. Full subject-level dataset.
#' @param adlb Data frame. Full lab results dataset.
#' @param adae Data frame. Full adverse events dataset.
#'
#' @return Nothing. Side effects only.
#'
#' @export
mod_patient_profile_server <- function(id, adsl, adlb, adae) {
  # --- Validate inputs --- [2026-06-18]
  if (!is.data.frame(adsl)) stop("`adsl` must be a data frame.", call. = FALSE)
  if (!is.data.frame(adlb)) stop("`adlb` must be a data frame.", call. = FALSE)
  if (!is.data.frame(adae)) stop("`adae` must be a data frame.", call. = FALSE)

  moduleServer(id, function(input, output, session) {
    # --- Reactive: selected patient demographics row --- [2026-06-18]
    # Returns a data frame with 0 or 1 rows. The inner header module uses
    # nrow(pt) > 0 to guard against empty selection.
    patient_row <- reactive({
      req(input$patient, input$patient != "")
      adsl %>% filter(USUBJID == input$patient)
    })

    # --- Reactive: lab results for selected patient --- [2026-06-18]
    patient_labs <- reactive({
      req(input$patient, input$patient != "")
      adlb %>%
        filter(USUBJID == input$patient) %>%
        arrange(PARAMCD, VISITNUM)
    })

    # --- Reactive: AEs for selected patient --- [2026-06-18]
    patient_aes <- reactive({
      req(input$patient, input$patient != "")
      adae %>% filter(USUBJID == input$patient)
    })

    # --- Call inner module servers --- [2026-06-18]
    # CRITICAL: Pass the SHORT id string ("header"), NOT session$ns("header").
    # moduleServer() automatically nests under the parent session's namespace.
    # If you use session$ns("header"), the namespace doubles:
    #   session$ns("header") = "patient_profile-header"
    #   moduleServer then nests: "patient_profile-patient_profile-header" — WRONG
    # The short id "header" becomes "patient_profile-header" automatically — CORRECT.
    #
    # The UI uses ns("header") which also produces "patient_profile-header",
    # so UI and server match when the short id is used here.
    mod_profile_header_server("header", patient_data = patient_row)
    mod_profile_labs_server("labs",     labs_data    = patient_labs)
    mod_profile_aes_server("aes",       ae_data      = patient_aes)
  })
}
