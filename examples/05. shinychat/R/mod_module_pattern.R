# =============================================================================
# mod_module_pattern.R — Tab 2: Module Pattern
# Created: 2026-06-19
# Purpose: Demonstrates chat_mod_ui() / chat_mod_server() — the higher-level
#   shinychat module abstraction. The right panel inspects the reactive env
#   returned by chat_mod_server() to show: status, last_input, last_turn.
#   Also demonstrates set_client() for swapping models mid-session and clear().
# =============================================================================

# --- Module UI ---------------------------------------------------------------

#' Module Pattern tab UI
#'
#' Two-column layout: left = chat_mod_ui(), right = reactive inspector card.
#' Both tabs that use chat are declared fillable in page_navbar.
#'
#' @param id Module namespace id.
#' @return A `bslib::nav_panel` UI object.
#' @export
mod_module_pattern_ui <- function(id) {
  ns <- NS(id)

  bslib::nav_panel(
    title = tags$span(bsicons::bs_icon("puzzle", class = "me-1"), "Module Pattern"),
    value = "Module Pattern",
    bslib::layout_columns(
      col_widths = c(7, 5),
      fill       = TRUE,

      # --- Left: chat module ------------------------------------------------
      bslib::card(
        fill = TRUE,
        bslib::card_header(
          class = "d-flex justify-content-between align-items-center",
          "Chat Module",
          tags$span(
            id    = ns("mod_status_badge"),
            class = "status-badge status-idle",
            tags$span(class = "status-dot"),
            "Idle"
          )
        ),
        bslib::card_body(
          padding = 0,
          class   = "chat-card-body",
          shinychat::chat_mod_ui(ns("mod_chat"))
        )
      ),

      # --- Right: reactive inspector ----------------------------------------
      bslib::card(
        bslib::card_header("Module Reactives"),
        bslib::card_body(
          h6("Status", class = "text-muted small text-uppercase"),
          uiOutput(ns("mod_status_display")),
          hr(),

          h6("Last User Input", class = "text-muted small text-uppercase"),
          verbatimTextOutput(ns("mod_last_input")),
          hr(),

          h6("Last Assistant Turn (excerpt)", class = "text-muted small text-uppercase"),
          verbatimTextOutput(ns("mod_last_turn")),
          hr(),

          # Model swap + clear controls
          bslib::layout_columns(
            col_widths = c(6, 6),
            fill       = FALSE,
            selectInput(
              ns("swap_model"), "Swap Model:",
              choices = c(
                "Haiku 4.5 (fast)"   = "claude-haiku-4-5-20251001",
                "Sonnet 4.6 (default)" = "claude-sonnet-4-6"
              )
            ),
            div(
              class = "d-flex align-items-end",
              actionButton(
                ns("clear_mod"), "Clear Chat",
                class = "btn-outline-danger w-100"
              )
            )
          ),
          actionButton(
            ns("apply_swap"), "Apply Model",
            class = "btn-sm btn-primary w-100 mt-1"
          )
        )
      )
    )
  )
}

# --- Module Server -----------------------------------------------------------

#' Module Pattern tab server
#'
#' Calls `chat_mod_server()` and inspects the returned reactive environment:
#' - `chat_env$status()` — "idle" | "streaming"
#' - `chat_env$last_input()` — last user message text
#' - `chat_env$last_turn()` — last ellmer Turn object
#' - `chat_env$set_client()` — swap the underlying ellmer client
#' - `chat_env$clear()` — reset conversation
#'
#' The status reactive also drives the badge via JS custom message handler.
#'
#' @param id           Module namespace id.
#' @param make_client  A function (no args) that creates a fresh ellmer Chat
#'   object. Called once at startup and again on model swap.
#' @return Invisibly NULL.
#' @export
mod_module_pattern_server <- function(id, make_client) {
  moduleServer(id, function(input, output, session) {

    # --- Create the initial ellmer client --- [2026-06-19]
    chat_client <- with_error_handling(
      make_client(),
      code    = "ERR-LLM-001",
      context = list(module = "module_pattern"),
      session = session
    )

    # --- Guard: do not wire the module with a NULL client --- [2026-06-19]
    # If make_client() failed, chat_client is NULL. Passing NULL into
    # chat_mod_server() leaves shinychat internals (e.g. append_stream_task) in
    # a broken state, so the status observer below crashes with
    # "object of type 'closure' is not subsettable". Surface a clean badge and
    # stop wiring this tab instead.
    if (is.null(chat_client)) {
      output$mod_status_display <- renderUI(
        tags$span(class = "badge bg-danger", "CLIENT UNAVAILABLE")
      )
      output$mod_last_input <- renderText("(LLM client unavailable)")
      output$mod_last_turn  <- renderText("(LLM client unavailable)")
      return(invisible(NULL))
    }

    # --- Wire chat_mod_server and capture its return env --- [2026-06-19]
    # chat_mod_server() returns a locked environment with reactive bindings:
    # last_input, last_turn, status, client (active binding), plus methods
    # append, update_user_input, clear, set_greeting, set_client.
    chat_env <- shinychat::chat_mod_server(
      "mod_chat",
      client = chat_client
    )

    # --- Badge: observe status reactive and push JS update --- [2026-06-19]
    observe({
      status <- chat_env$status()
      session$sendCustomMessage(
        "update_status_badge",
        list(id = session$ns("mod_status_badge"), status = status)
      )
    })

    # --- Render status badge UI in inspector panel --- [2026-06-19]
    output$mod_status_display <- renderUI({
      status <- chat_env$status()
      cls <- if (status == "streaming") "badge bg-success" else "badge bg-secondary"
      tags$span(class = cls, toupper(status))
    })

    # --- Render last user input --- [2026-06-19]
    output$mod_last_input <- renderText({
      inp <- chat_env$last_input()
      if (is.null(inp)) "(no input yet)" else inp
    })

    # --- Render last assistant turn excerpt --- [2026-06-19]
    # last_turn() returns an ellmer Turn object. We extract text via
    # ellmer::contents_text() and truncate for display.
    output$mod_last_turn <- renderText({
      turn <- chat_env$last_turn()
      if (is.null(turn)) {
        "(no turn yet)"
      } else {
        txt <- tryCatch(
          ellmer::contents_text(turn@contents),
          error = function(e) "(unable to extract text)"
        )
        if (nchar(txt) > 300) paste0(substr(txt, 1, 300), "...") else txt
      }
    })

    # --- Swap model --- [2026-06-19]
    # Creates a new ellmer client for the selected model and hot-swaps it
    # into the running module. sync = TRUE copies current conversation history.
    observeEvent(input$apply_swap, {
      req(input$swap_model)
      new_client <- with_error_handling(
        ellmer::chat_anthropic(
          model         = input$swap_model,
          system_prompt = chat_env$client$get_system_prompt()
        ),
        code    = "ERR-LLM-001",
        context = list(module = "module_pattern", action = "swap_model"),
        session = session
      )
      if (!is.null(new_client)) {
        chat_env$set_client(new_client, sync = TRUE)
        log_event("INFO", "Model swapped",
                  module = "module_pattern", model = input$swap_model)
      }
    })

    # --- Clear conversation --- [2026-06-19]
    observeEvent(input$clear_mod, {
      chat_env$clear(client_history = "clear")
      log_event("INFO", "Module conversation cleared", module = "module_pattern")
    })

  })
}
