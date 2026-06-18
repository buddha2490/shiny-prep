# =============================================================================
# R/mod_dynamic_host.R — Tab 6: Dynamic Modules (Host / Manager)
# =============================================================================
# Purpose: Demonstrates how to create and destroy Shiny module instances at
#          runtime using insertUI / removeUI. Manages a list of active
#          instances and coordinates their lifecycle.
#
# Key teaching points:
#   1. UNIQUE IDs via counter: Each new instance gets an ID from an
#      incrementing counter (reactiveVal). Never reuse IDs — even after
#      removal, the old ID must not be reused in the same session, because
#      Shiny's reactive graph remembers it.
#
#   2. insertUI / removeUI: insertUI() adds a UI element to the DOM at a
#      CSS selector anchor. removeUI() removes it by selector. After calling
#      insertUI(), immediately call the module's server function to register
#      its reactive bindings. The server MUST be called while the UI exists.
#
#   3. Instance tracking with reactiveVal(list()): Maintain a list of active
#      instance IDs in a reactiveVal. Add IDs on create, remove on destroy.
#      Iterating this list lets you set up per-instance observers.
#
#   4. Per-instance remove observer: For each instance, use observeEvent() to
#      watch the card's "remove" reactive. When it fires, call removeUI() and
#      remove the ID from the tracking list. Use local() to capture the loop
#      variable — without local(), all observers close over the same `card_id`
#      variable (a classic R closure bug).
#
#   5. Cleanup caveat: In this app, module server-side reactives persist in
#      memory even after removeUI(). For production apps with many dynamic
#      modules, consider using session$onSessionEnded or a destroy pattern
#      to prevent memory leaks.
#
# Created: 2026-06-18
# =============================================================================

#' Dynamic Module Host — UI
#'
#' Renders the "Add Comparison" button and a container div that receives
#' dynamically inserted card UIs. The container's id is the anchor for
#' \code{insertUI()}.
#'
#' @param id Character scalar. Module namespace ID.
#'
#' @return A \code{tagList} with the add button and the card container.
#'
#' @export
mod_dynamic_host_ui <- function(id) {
  ns <- NS(id)

  tagList(
    # --- Controls row --- [2026-06-18]
    layout_columns(
      col_widths = c(3, 9),
      card(
        card_header("Controls"),
        actionButton(
          inputId = ns("add"),
          label   = "Add Comparison",
          icon    = icon("plus"),
          class   = "btn btn-primary w-100"
        ),
        tags$hr(),
        tags$p(
          class = "text-muted small",
          "Each card is an independent module instance with its own ARM ",
          "selector. Click 'Remove' on any card to destroy that instance."
        ),
        tags$p(
          tags$strong("Active instances: "),
          textOutput(ns("instance_count"), inline = TRUE)
        )
      ),

      # --- Card container --- [2026-06-18]
      # This div is the INSERT anchor. insertUI() targets "#<ns>-card_container".
      # All dynamically created card UIs will appear inside this div.
      # The id MUST be namespaced so it is unique when this host module is
      # used multiple times.
      div(
        id    = ns("card_container"),
        class = "d-flex flex-column gap-3"
      )
    )
  )
}

#' Dynamic Module Host — Server
#'
#' Manages the lifecycle of dynamic \code{mod_dynamic_card} instances:
#' creation via the Add button, removal via each card's Remove button.
#' Demonstrates the full dynamic module pattern including ID generation,
#' insertUI/removeUI, instance tracking, and per-instance observer setup.
#'
#' @param id Character scalar. Module namespace ID.
#' @param adae Data frame. Full adverse events dataset, passed to each card.
#'
#' @return Nothing. Side effects only.
#'
#' @export
mod_dynamic_host_server <- function(id, adae) {
  # --- Validate inputs --- [2026-06-18]
  if (!is.data.frame(adae)) {
    stop("`adae` must be a data frame.", call. = FALSE)
  }

  moduleServer(id, function(input, output, session) {

    # --- Instance counter --- [2026-06-18]
    # A reactiveVal integer that increments with each new card. Used to
    # generate unique IDs. Never reuse IDs in a session — even after removal.
    counter <- reactiveVal(0)

    # --- Active instance ID list --- [2026-06-18]
    # A reactiveVal holding a character vector of currently active instance
    # IDs. Used to track how many cards exist and to clean up on removal.
    active_ids <- reactiveVal(character(0))

    # --- Instance count display --- [2026-06-18]
    output$instance_count <- renderText({
      length(active_ids())
    })

    # --- Add new instance --- [2026-06-18]
    # When the Add button is clicked, we:
    #   1. Increment the counter to get a new unique ID
    #   2. Call insertUI() to add the card's UI to the DOM
    #   3. Call the card's server function to register its reactive bindings
    #   4. Set up a per-instance observer for the remove button
    #   5. Update the active_ids list
    observeEvent(input$add, {

      # Step 1: Generate unique ID --- [2026-06-18]
      # Incrementing ensures uniqueness even if cards are added and removed.
      # paste0("card_", n) gives "card_1", "card_2", etc.
      new_count <- counter() + 1
      counter(new_count)
      card_id   <- paste0("card_", new_count)

      # Step 2: Insert card UI into the DOM --- [2026-06-18]
      # selector = paste0("#", session$ns("card_container")) targets the
      # container div rendered in the UI function, correctly namespaced.
      # where = "beforeEnd" appends inside the container.
      #
      # UI ids: session$ns() is REQUIRED here because insertUI() renders raw
      # HTML outside the normal module UI pipeline. The ids must be fully
      # qualified so they land in the correct namespace in the DOM.
      insertUI(
        selector = paste0("#", session$ns("card_container")),
        where    = "beforeEnd",
        ui       = div(
          id = session$ns(paste0("wrap_", card_id)),
          mod_dynamic_card_ui(session$ns(card_id))
        )
      )

      # Step 3: Call the card server function --- [2026-06-18]
      # CRITICAL: Pass the SHORT card_id, NOT session$ns(card_id).
      # moduleServer() automatically nests under the parent session namespace.
      # Using session$ns() here would double-namespace:
      #   session$ns("card_1") = "dynamic_host-card_1"
      #   moduleServer nests:    "dynamic_host-dynamic_host-card_1" — WRONG
      # The short id "card_1" becomes "dynamic_host-card_1" automatically — CORRECT.
      #
      # Note the asymmetry: UI uses session$ns() (raw DOM), server uses short id.
      remove_signal <- mod_dynamic_card_server(card_id, adae = adae)

      # Step 4: Per-instance remove observer --- [2026-06-18]
      # local() creates a new scope that captures card_id by value, not by
      # reference. Without local(), all observers in a loop would close over
      # the SAME card_id variable (the last value it held) — a classic R
      # closure bug. local() is the correct fix.
      local({
        cid <- card_id  # capture by value inside local scope

        observeEvent(remove_signal(), {
          # Only fire when the remove signal becomes TRUE (button clicked)
          req(remove_signal())

          # Remove the card's wrapper div from the DOM
          removeUI(
            selector = paste0("#", session$ns(paste0("wrap_", cid)))
          )

          # Remove the ID from the tracking list so instance count updates
          active_ids(setdiff(active_ids(), cid))
        }, ignoreInit = TRUE)
      })

      # Step 5: Update the active ID list --- [2026-06-18]
      active_ids(c(active_ids(), card_id))
    })
  })
}
