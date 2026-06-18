# =============================================================================
# R/mod_r6_details.R — Tab 4: Shared State with R6 (Details / Reader)
# =============================================================================
# Purpose: Demonstrates the READER role in an R6 shared-state pattern.
#          Calls store$get_patient() to subscribe to patient selection changes
#          and renders a demographics + labs detail panel for the selected
#          patient.
#
# Key teaching points:
#   1. Calling store$get_patient() INSIDE a reactive() or render*() function
#      registers this context as a dependent on the reactiveVal inside the R6
#      instance. When set_patient() is called by the selector module, this
#      reader automatically re-executes.
#   2. The R6 instance is not itself reactive — it's a plain R object. Only
#      the reactiveVal INSIDE it triggers invalidation. This is why get_patient()
#      must be called inside a reactive context (reactive(), observe(), render*).
#   3. req() guards downstream rendering when no patient is selected (NULL),
#      preventing empty or error states.
#   4. This module does NOT know about mod_r6_selector at all. It only depends
#      on the store contract (get_patient()/set_patient()). This is loose
#      coupling: swapping the selector for a different UI module would require
#      zero changes here.
#
# Created: 2026-06-18
# =============================================================================

# --- UI function -------------------------------------------------------------

#' Patient Detail Panel — UI
#'
#' Renders demographics and lab result panels for the currently selected
#' patient. Part of the Tab 4 R6 shared-state pattern.
#'
#' @param id Character scalar. Module namespace ID.
#'
#' @return A \code{tagList} containing the detail cards.
#'
#' @export
mod_r6_details_ui <- function(id) {
  ns <- NS(id)

  tagList(
    # --- Demographics card --- [2026-06-18]
    card(
      card_header("Patient Demographics"),
      # uiOutput allows the server to render dynamic HTML based on the selected
      # patient. We use uiOutput here rather than a fixed table because the
      # content is entirely conditional on selection state.
      uiOutput(ns("demographics_panel"))
    ),

    # --- Lab results card --- [2026-06-18]
    card(
      card_header("Lab Results"),
      DTOutput(ns("labs_table"))
    )
  )
}

# --- Server function ---------------------------------------------------------

#' Patient Detail Panel — Server
#'
#' Reads the selected patient from the R6 \code{PatientStore} and renders
#' a demographics summary and lab results table for that patient.
#'
#' @param id Character scalar. Module namespace ID.
#' @param store A \code{PatientStore} R6 instance. This module calls
#'   \code{store$get_patient()} to subscribe to selection changes.
#' @param adsl Data frame. Subject-level dataset.
#' @param adlb Data frame. Lab results dataset.
#'
#' @return Nothing. Side effects only (output rendering).
#'
#' @export
mod_r6_details_server <- function(id, store, adsl, adlb) {
  # --- Validate inputs --- [2026-06-18]
  if (!inherits(store, "PatientStore")) {
    stop("`store` must be a PatientStore R6 instance.", call. = FALSE)
  }
  if (!is.data.frame(adsl)) stop("`adsl` must be a data frame.", call. = FALSE)
  if (!is.data.frame(adlb)) stop("`adlb` must be a data frame.", call. = FALSE)

  moduleServer(id, function(input, output, session) {

    # --- Reactive: currently selected patient --- [2026-06-18]
    # store$get_patient() is called inside reactive(), which registers this
    # reactive as a dependent on the internal reactiveVal. When the selector
    # module calls store$set_patient(), this reactive fires, which cascades
    # to all render functions that call selected_patient().
    selected_patient <- reactive({
      store$get_patient()
    })

    # --- Reactive: demographics for selected patient --- [2026-06-18]
    # req() halts execution if no patient is selected (NULL), preventing
    # downstream renders from showing empty or error states.
    patient_demographics <- reactive({
      req(selected_patient())
      adsl %>% filter(USUBJID == selected_patient())
    })

    # --- Reactive: labs for selected patient --- [2026-06-18]
    patient_labs <- reactive({
      req(selected_patient())
      adlb %>%
        filter(USUBJID == selected_patient()) %>%
        arrange(PARAMCD, VISITNUM)
    })

    # --- Render demographics panel --- [2026-06-18]
    # uiOutput renders HTML dynamically. When no patient is selected, we show
    # a placeholder. When a patient is selected, we show a summary table.
    output$demographics_panel <- renderUI({
      if (is.null(selected_patient())) {
        tags$p(class = "text-muted", "Select a patient using the dropdown.")
      } else {
        pt <- patient_demographics()
        if (nrow(pt) == 0) {
          tags$p(class = "text-danger", "Patient not found in ADSL.")
        } else {
          # Build a simple key-value display using a definition list
          tags$dl(
            class = "row",
            tags$dt(class = "col-sm-3", "USUBJID"),
            tags$dd(class = "col-sm-9", pt$USUBJID),
            tags$dt(class = "col-sm-3", "Age"),
            tags$dd(class = "col-sm-9", pt$AGE),
            tags$dt(class = "col-sm-3", "Sex"),
            tags$dd(class = "col-sm-9", pt$SEX),
            tags$dt(class = "col-sm-3", "Race"),
            tags$dd(class = "col-sm-9", pt$RACE),
            tags$dt(class = "col-sm-3", "Arm"),
            tags$dd(class = "col-sm-9", pt$ARM),
            tags$dt(class = "col-sm-3", "Country"),
            tags$dd(class = "col-sm-9", pt$COUNTRY)
          )
        }
      }
    })

    # --- Render labs table --- [2026-06-18]
    output$labs_table <- renderDT({
      req(selected_patient())
      labs <- patient_labs()
      if (nrow(labs) == 0) {
        return(datatable(data.frame(Message = "No lab records for this patient.")))
      }
      datatable(
        labs %>% select(PARAM, VISIT, BASE, AVAL, CHG),
        options  = list(pageLength = 10, scrollX = TRUE),
        rownames = FALSE,
        caption  = paste0("Lab results for ", selected_patient())
      )
    })
  })
}
