# =============================================================================
# R/mod_demographics.R — Tab 1: Basic Module Pattern
# =============================================================================
# Purpose: Demonstrates the minimal, fundamental Shiny module pattern.
#
# Key teaching points:
#   1. NS() — the namespace function wraps every input/output ID so that
#      multiple instances of the same module never clash. NS(id, "arm_filter")
#      becomes e.g. "demo-arm_filter" at runtime.
#   2. moduleServer() — the server counterpart. The `id` argument must match
#      the id passed to the UI function. Inside, `input`, `output`, and
#      `session` are already namespaced — you just write `input$arm_filter`,
#      not `input[["demo-arm_filter"]]`.
#   3. A module is just a function. The UI function returns a tag object;
#      the server function sets up reactives and outputs. Nothing magic.
#   4. Data is passed as a plain argument to the server function. Modules do
#      not reach into global scope — they receive everything they need as args.
#
# Created: 2026-06-18
# =============================================================================

# --- UI function -------------------------------------------------------------

#' Demographics Table — UI
#'
#' Renders a sidebar layout with an ARM filter dropdown and a DT table of
#' subject demographics. All input/output IDs are wrapped in NS() to prevent
#' namespace collision when multiple instances are used.
#'
#' @param id Character scalar. The module namespace ID. Must match the `id`
#'   passed to \code{mod_demographics_server()}.
#'
#' @return A \code{tagList} containing the module's UI elements.
#'
#' @export
mod_demographics_ui <- function(id) {
  # --- Create the namespace function --- [2026-06-18]
  # NS(id) returns a function. Every ID used in this UI MUST be wrapped with
  # ns() so Shiny can isolate this module's inputs/outputs from others.
  # If you forget ns(), the input will exist in the global namespace and
  # may conflict with another module — a silent, hard-to-debug bug.
  ns <- NS(id)

  tagList(
    # --- Filter controls --- [2026-06-18]
    # selectInput for treatment arm filter. Note ns("arm_filter") — the ID
    # "arm_filter" is local to this module instance. At runtime Shiny
    # expands it to something like "demographics-arm_filter".
    card(
      card_header("Filter"),
      selectInput(
        inputId  = ns("arm_filter"),
        label    = "Treatment Arm",
        choices  = c("All", "Placebo", "Drug A 10mg", "Drug A 20mg"),
        selected = "All",
        selectize = FALSE
      )
    ),

    # --- Table output --- [2026-06-18]
    # DTOutput is also namespaced with ns(). The server function renders to
    # output$demographics_table, which Shiny maps to the namespaced ID at
    # runtime. UI and server stay in sync automatically as long as both use
    # the same un-namespaced string ("demographics_table").
    card(
      card_header("Subject Demographics (ADSL)"),
      DTOutput(ns("demographics_table"))
    )
  )
}

# --- Server function ---------------------------------------------------------

#' Demographics Table — Server
#'
#' Filters \code{adsl} by treatment arm and renders a DT table. Demonstrates
#' the core \code{moduleServer()} pattern: reactive input reading, reactive
#' data transformation, and output rendering, all within an isolated namespace.
#'
#' @param id Character scalar. Must match the `id` passed to
#'   \code{mod_demographics_ui()}.
#' @param adsl Data frame. Subject-level ADSL dataset. Passed explicitly so the
#'   module does not depend on a global variable — this makes it testable and
#'   reusable.
#'
#' @return Nothing. Side effects only (output rendering).
#'
#' @export
mod_demographics_server <- function(id, adsl) {
  # --- Validate inputs --- [2026-06-18]
  # Check that adsl is a data frame before entering the reactive graph.
  # Errors here surface immediately at startup rather than inside a reactive
  # expression where the stack trace is harder to read.
  if (!is.data.frame(adsl)) {
    stop("`adsl` must be a data frame.", call. = FALSE)
  }

  moduleServer(id, function(input, output, session) {
    # --- Filtered data reactive --- [2026-06-18]
    # This reactive reads input$arm_filter (no ns() needed inside moduleServer
    # — the namespace is already applied). req() prevents the reactive from
    # executing before the input is initialized (avoids a NULL flash on load).
    filtered_adsl <- reactive({
      req(input$arm_filter)

      # If "All" is selected, return the full dataset unchanged.
      # Otherwise, filter to the matching ARM.
      if (input$arm_filter == "All") {
        adsl
      } else {
        adsl %>% filter(ARM == input$arm_filter)
      }
    })

    # --- Render DT table --- [2026-06-18]
    # output$demographics_table — the ID matches the DTOutput() in the UI.
    # Shiny resolves the full namespaced ID internally; we just use the plain
    # string here.
    output$demographics_table <- renderDT({
      datatable(
        filtered_adsl(),
        options = list(
          pageLength = 10,
          scrollX    = TRUE
        ),
        rownames = FALSE,
        caption  = paste0(
          "Showing ", nrow(filtered_adsl()), " of ", nrow(adsl), " subjects"
        )
      )
    })
  })
}
