# =============================================================================
# R/mod_filter.R — Tab 2: Module Communication (Filter Producer)
# =============================================================================
# Purpose: Demonstrates how a module RETURNS a reactive so another module can
#          consume it. This is the standard pattern for module-to-module
#          communication in Shiny.
#
# Key teaching points:
#   1. A moduleServer() function CAN return a value — conventionally a reactive
#      or reactiveVal. This is the idiomatic way to pass data from one module
#      to another without going through a shared state object.
#   2. The CONSUMER module (mod_listing) receives the reactive as a function
#      argument. It calls data() with parentheses to read the current value —
#      the parentheses mean "evaluate this reactive now, and subscribe to it."
#   3. Contrast with passing a plain data frame as an argument: a plain data
#      frame is static. A reactive is live — when its upstream inputs change,
#      every downstream reactive that calls it re-executes automatically.
#   4. The returned reactive is the "contract" between modules. The consumer
#      does not know or care HOW the filter module produces the data — it only
#      knows it will receive a filtered data frame when it calls data().
#
# This file: the PRODUCER (filter controls).
# See mod_listing.R for the CONSUMER.
#
# Created: 2026-06-18
# =============================================================================

# --- UI function -------------------------------------------------------------

#' Subject Filter Controls — UI
#'
#' Renders filter dropdowns for ARM and SEX. Paired with
#' \code{mod_listing_ui()} in Tab 2 to demonstrate inter-module communication
#' via a returned reactive.
#'
#' @param id Character scalar. Module namespace ID.
#'
#' @return A \code{card} containing the filter controls.
#'
#' @export
mod_filter_ui <- function(id) {
  ns <- NS(id)

  card(
    card_header("Filters"),
    # --- ARM filter --- [2026-06-18]
    selectInput(
      inputId  = ns("arm"),
      label    = "Treatment Arm",
      choices  = c("All", "Placebo", "Drug A 10mg", "Drug A 20mg"),
      selected = "All"
    ),

    # --- SEX filter --- [2026-06-18]
    selectInput(
      inputId  = ns("sex"),
      label    = "Sex",
      choices  = c("All", "M", "F"),
      selected = "All"
    ),

    # --- Subject count badge --- [2026-06-18]
    # Real-time feedback showing how many subjects match the current filters.
    # The textOutput is rendered by the server below.
    tags$p(
      tags$strong("Matching subjects: "),
      textOutput(ns("subject_count"), inline = TRUE)
    )
  )
}

# --- Server function ---------------------------------------------------------

#' Subject Filter Controls — Server
#'
#' Applies ARM and SEX filters to \code{adsl} and RETURNS the filtered dataset
#' as a reactive. The calling code in \code{server.R} assigns the return value
#' and passes it to \code{mod_listing_server()} as an argument.
#'
#' @section Return value convention:
#' Returning a reactive from \code{moduleServer()} is the idiomatic pattern
#' for module output. The consumer receives a reactive and calls it with
#' parentheses: \code{filtered_data()} — not \code{filtered_data}. Forgetting
#' the parentheses passes the reactive object itself (a function), which breaks
#' downstream renders silently.
#'
#' @param id Character scalar. Module namespace ID.
#' @param adsl Data frame. Full subject-level dataset.
#'
#' @return A reactive expression that returns the filtered \code{adsl} data
#'   frame based on current input selections.
#'
#' @export
mod_filter_server <- function(id, adsl) {
  # --- Validate inputs --- [2026-06-18]
  if (!is.data.frame(adsl)) {
    stop("`adsl` must be a data frame.", call. = FALSE)
  }

  moduleServer(id, function(input, output, session) {

    # --- Filtered dataset reactive --- [2026-06-18]
    # This reactive is the "output" of this module. It is returned from
    # moduleServer() so the parent server (server.R) can assign it and pass
    # it to a consumer module.
    #
    # Pattern:
    #   filtered_data <- mod_filter_server("filter", adsl = adsl)
    #   mod_listing_server("listing", data = filtered_data)
    #
    # Note that filtered_data is the reactive OBJECT (a function). The consumer
    # calls filtered_data() to get the current value.
    filtered_data <- reactive({
      req(input$arm, input$sex)

      result <- adsl

      # Apply ARM filter if not "All"
      if (input$arm != "All") {
        result <- result %>% filter(ARM == input$arm)
      }

      # Apply SEX filter if not "All"
      if (input$sex != "All") {
        result <- result %>% filter(SEX == input$sex)
      }

      result
    })

    # --- Subject count output --- [2026-06-18]
    # Side-effect output: show how many subjects match the current filters.
    # This output is consumed by this module's own UI — not returned.
    output$subject_count <- renderText({
      nrow(filtered_data())
    })

    # --- Return the reactive --- [2026-06-18]
    # This is the key: moduleServer() returns whatever the inner function
    # returns. Returning a reactive makes this module a "producer" that other
    # modules can subscribe to.
    filtered_data
  })
}
