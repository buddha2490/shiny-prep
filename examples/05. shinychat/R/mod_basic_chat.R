# =============================================================================
# mod_basic_chat.R — Tab 1: Basic Chat module
# Created: 2026-06-19
# Purpose: Demonstrates the core shinychat pattern:
#   - chat_ui() with fill, placeholder, and cancel support
#   - Streaming responses via chat_append(id, client$stream_async(...))
#   - Greeting with suggestion chips via chat_set_greeting()
#   - Sidebar controls: New Conversation, Fill Input Demo, Inject Message Demo
#   - Status badge toggling (Streaming / Idle) via JS custom message handler
# =============================================================================

# --- Module UI ---------------------------------------------------------------

#' Basic Chat tab UI
#'
#' Layout: `layout_sidebar()` with controls sidebar + fill card containing
#' `chat_ui()`. Fill is TRUE so the chat window expands to the viewport.
#'
#' @param id Module namespace id.
#' @return A `bslib::nav_panel` UI object.
#' @export
mod_basic_chat_ui <- function(id) {
  ns <- NS(id)

  # --- Tab panel with sidebar layout --- [2026-06-19]
  # fill = TRUE on nav_panel so the chat window takes remaining viewport height.
  bslib::nav_panel(
    title = tags$span(bsicons::bs_icon("chat-left-text", class = "me-1"), "Basic Chat"),
    value = "Basic Chat",
    bslib::layout_sidebar(
      fill     = TRUE,
      sidebar  = bslib::sidebar(
        title = "Controls",
        width = 280,
        open  = "desktop",

        # --- Conversation controls --- [2026-06-19]
        actionButton(
          ns("new_chat"), "New Conversation",
          icon  = icon("plus"),
          class = "btn-outline-secondary w-100 mb-3"
        ),
        hr(),

        # --- Demo buttons --- [2026-06-19]
        # These showcase the update_chat_user_input() and chat_append() APIs.
        h6("Demos", class = "text-muted small text-uppercase"),
        actionButton(
          ns("fill_input_demo"), "Fill Input Demo",
          class = "btn-outline-primary btn-sm w-100 mb-2"
        ),
        actionButton(
          ns("inject_msg_demo"), "Inject Message",
          class = "btn-outline-primary btn-sm w-100 mb-2"
        )
      ),

      # --- Main: chat window ------------------------------------------------
      bslib::card(
        fill = TRUE,
        bslib::card_header(
          class = "d-flex justify-content-between align-items-center",
          "Chat",
          # Status badge: class swapped by status_badge.js handler
          tags$span(
            id    = ns("status_badge"),
            class = "status-badge status-idle",
            tags$span(class = "status-dot"),
            "Idle"
          )
        ),
        bslib::card_body(
          padding = 0,
          class   = "chat-card-body",
          shinychat::chat_ui(
            ns("chat"),
            fill          = TRUE,
            height        = "100%",
            placeholder   = "Ask anything...",
            enable_cancel = TRUE
          )
        )
      )
    )
  )
}

# --- Module Server -----------------------------------------------------------

#' Basic Chat tab server
#'
#' Wires the chat UI to an ellmer client for streaming responses. Handles:
#' - Greeting with suggestion chips on session start
#' - Token-by-token streaming via `chat_append(id, client$stream_async(...))`
#' - Status badge toggling (idle <-> streaming) via JS message handler
#' - New Conversation button (clears UI + client history)
#' - Fill Input Demo (pre-populates the input field)
#' - Inject Message Demo (appends a message programmatically)
#'
#' @param id      Module namespace id.
#' @param client  A reactive expression returning an ellmer Chat object.
#'   Must return an object created by `ellmer::chat_anthropic()`.
#' @return Invisibly NULL. Side effects only.
#' @export
mod_basic_chat_server <- function(id, client) {
  moduleServer(id, function(input, output, session) {

    # --- Set greeting with suggestion chips --- [2026-06-19]
    # The greeting_requested input fires once when chat_ui() is ready.
    # We use chat_set_greeting() with HTML suggestion chips — shinychat
    # renders <span class="suggestion"> elements as clickable chips that
    # auto-fill the chat input.
    observeEvent(input$chat_greeting_requested, {
      greeting_content <- paste0(
        "## Welcome to shinychat\n\n",
        "This tab demonstrates token-by-token streaming chat backed by ",
        "Anthropic Claude via ellmer. Try one of these to get started:\n\n",
        '<span class="suggestion">Explain async streaming in Shiny</span>\n',
        '<span class="suggestion">Write a haiku about R programming</span>\n',
        '<span class="suggestion">What can ellmer do that other LLM packages cannot?</span>'
      )
      shinychat::chat_set_greeting(
        "chat",
        shinychat::chat_greeting(greeting_content),
        session = session
      )
      log_event("DEBUG", "Basic chat greeting set", module = "basic_chat")
    })

    # --- Handle user input — core streaming pattern --- [2026-06-19]
    # input$chat_user_input fires when the user submits. We immediately
    # toggle the badge to "streaming", invoke stream_async() and pipe the
    # async generator into chat_append() which handles chunk-by-chunk
    # rendering. The badge resets to "idle" in the observer below.
    observeEvent(input$chat_user_input, {
      req(input$chat_user_input)

      # Toggle badge to streaming
      session$sendCustomMessage(
        "update_status_badge",
        list(id = session$ns("status_badge"), status = "streaming")
      )

      log_event("INFO", "User message received", module = "basic_chat")

      # Stream response — the promise resolves once the full turn completes
      stream <- with_error_handling(
        client()$stream_async(input$chat_user_input),
        code    = "ERR-LLM-001",
        context = list(module = "basic_chat"),
        session = session
      )

      if (!is.null(stream)) {
        p <- shinychat::chat_append("chat", stream, session = session)
        # When the stream promise settles, reset the badge
        promises::finally(p, function() {
          session$sendCustomMessage(
            "update_status_badge",
            list(id = session$ns("status_badge"), status = "idle")
          )
          log_event("DEBUG", "Stream complete, badge reset", module = "basic_chat")
        })
      } else {
        # stream_async() returned NULL (error was handled), reset badge
        session$sendCustomMessage(
          "update_status_badge",
          list(id = session$ns("status_badge"), status = "idle")
        )
      }
    })

    # --- New Conversation button --- [2026-06-19]
    # Clears the chat UI and resets client history so the next message
    # starts a fresh conversation without any prior context.
    observeEvent(input$new_chat, {
      shinychat::chat_clear("chat", greeting = TRUE, session = session)
      client()$set_turns(list())
      # Reset badge in case a stream was cut short
      session$sendCustomMessage(
        "update_status_badge",
        list(id = session$ns("status_badge"), status = "idle")
      )
      log_event("INFO", "Conversation cleared", module = "basic_chat")
    })

    # --- Fill Input Demo --- [2026-06-19]
    # Demonstrates update_chat_user_input(): pre-populates the text field
    # without submitting, letting the user edit before sending.
    observeEvent(input$fill_input_demo, {
      shinychat::update_chat_user_input(
        "chat",
        value   = "Describe three use cases for shinychat in a pharma/clinical context.",
        focus   = TRUE,
        submit  = FALSE,
        session = session
      )
      log_event("DEBUG", "Fill input demo triggered", module = "basic_chat")
    })

    # --- Inject Message Demo --- [2026-06-19]
    # Demonstrates chat_append(): adds an assistant message directly to the
    # UI without going through the LLM. Useful for system announcements or
    # pre-canned responses.
    observeEvent(input$inject_msg_demo, {
      injected <- paste0(
        "**Injected message** (demo): This message was added directly via ",
        "`chat_append()` without calling the LLM. ",
        "In production you might use this for system notifications or ",
        "cached responses."
      )
      shinychat::chat_append(
        "chat",
        injected,
        role    = "assistant",
        session = session
      )
      log_event("DEBUG", "Inject message demo triggered", module = "basic_chat")
    })

  })
}
