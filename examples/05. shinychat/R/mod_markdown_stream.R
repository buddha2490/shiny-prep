# =============================================================================
# mod_markdown_stream.R — Tab 3: Markdown Stream
# Created: 2026-06-19
# Purpose: Demonstrates output_markdown_stream() / markdown_stream() — the
#   standalone streaming output API that renders streamed content outside of a
#   chat UI. Supports markdown, text, and html content types. The user enters
#   a prompt, clicks Generate, and watches the output render token-by-token.
# =============================================================================

# --- Module UI ---------------------------------------------------------------

#' Markdown Stream tab UI
#'
#' Two-column layout: left = controls card, right = streaming output card.
#'
#' @param id Module namespace id.
#' @return A `bslib::nav_panel` UI object.
#' @export
mod_markdown_stream_ui <- function(id) {
  ns <- NS(id)

  bslib::nav_panel(
    title = tags$span(bsicons::bs_icon("file-text", class = "me-1"), "Markdown Stream"),
    value = "Markdown Stream",
    bslib::layout_columns(
      col_widths = c(4, 8),
      fill       = FALSE,

      # --- Left: controls card ------------------------------------------
      bslib::card(
        bslib::card_header("Controls"),
        bslib::card_body(
          textAreaInput(
            ns("stream_prompt"), "Prompt:",
            rows  = 5,
            value = "Write a short markdown reference card for R's dplyr package, with a table of the 5 most used verbs, their descriptions, and a one-line example."
          ),
          selectInput(
            ns("content_type"), "Render as:",
            choices  = c(
              "Markdown" = "markdown",
              "Plain text" = "text",
              "HTML"     = "html"
            ),
            selected = "markdown"
          ),
          actionButton(
            ns("generate_stream"), "Generate",
            class = "btn-primary w-100"
          ),
          actionButton(
            ns("clear_stream"), "Clear",
            class = "btn-outline-secondary w-100 mt-2"
          )
        )
      ),

      # --- Right: output card -------------------------------------------
      bslib::card(
        min_height = "400px",
        bslib::card_header(
          class = "d-flex justify-content-between align-items-center",
          "Output",
          # Status badge for stream state
          tags$span(
            id    = ns("stream_status_badge"),
            class = "status-badge status-idle",
            tags$span(class = "status-dot"),
            "Idle"
          )
        ),
        bslib::card_body(
          shinychat::output_markdown_stream(
            ns("md_stream"),
            content      = "*Click Generate to stream output here.*",
            content_type = "markdown",
            auto_scroll  = TRUE,
            width        = "100%",
            height       = "auto"
          )
        )
      )
    )
  )
}

# --- Module Server -----------------------------------------------------------

#' Markdown Stream tab server
#'
#' Uses `markdown_stream()` to pipe an async ellmer stream into
#' `output_markdown_stream()`. The operation is "replace" each time Generate
#' is clicked. The content_type is read from input and respected on the server:
#' the stream replaces the output with the selected format.
#'
#' Note: `markdown_stream()` takes `content_stream` (not `stream`) as its
#' second argument per the verified signature.
#'
#' @param id      Module namespace id.
#' @param client  A reactive expression returning an ellmer Chat object.
#' @return Invisibly NULL.
#' @export
mod_markdown_stream_server <- function(id, client) {
  moduleServer(id, function(input, output, session) {

    # --- Generate: pipe LLM stream to markdown output --- [2026-06-19]
    # A fresh chat client is used for each stream so the markdown tab does
    # not accumulate context from the basic chat tab.
    observeEvent(input$generate_stream, {
      req(input$stream_prompt, nchar(trimws(input$stream_prompt)) > 0)

      session$sendCustomMessage(
        "update_status_badge",
        list(id = session$ns("stream_status_badge"), status = "streaming")
      )
      log_event("INFO", "Markdown stream started", module = "markdown_stream")

      # Each Generate click creates a fresh single-use client so history
      # doesn't accumulate across generate clicks.
      stream_client <- with_error_handling(
        ellmer::chat_anthropic(model = "claude-sonnet-4-6"),
        code    = "ERR-LLM-003",
        context = list(module = "markdown_stream"),
        session = session
      )

      if (is.null(stream_client)) {
        session$sendCustomMessage(
          "update_status_badge",
          list(id = session$ns("stream_status_badge"), status = "idle")
        )
        return()
      }

      # Build a prompt that requests the appropriate content type
      prompt <- switch(
        input$content_type,
        "html" = paste0(
          input$stream_prompt,
          "\n\nRespond with raw HTML only (no markdown, no code fences). ",
          "Use semantic HTML tags."
        ),
        "text" = paste0(
          input$stream_prompt,
          "\n\nRespond with plain text only — no markdown formatting, ",
          "no asterisks, no headers."
        ),
        input$stream_prompt  # markdown: no modification needed
      )

      stream <- with_error_handling(
        stream_client$stream_async(prompt),
        code    = "ERR-LLM-003",
        context = list(module = "markdown_stream"),
        session = session
      )

      if (!is.null(stream)) {
        p <- shinychat::markdown_stream(
          session$ns("md_stream"),
          content_stream = stream,
          operation      = "replace",
          session        = session
        )
        promises::finally(p, function() {
          session$sendCustomMessage(
            "update_status_badge",
            list(id = session$ns("stream_status_badge"), status = "idle")
          )
          log_event("DEBUG", "Markdown stream complete", module = "markdown_stream")
        })
      } else {
        session$sendCustomMessage(
          "update_status_badge",
          list(id = session$ns("stream_status_badge"), status = "idle")
        )
      }
    })

    # --- Clear output --- [2026-06-19]
    observeEvent(input$clear_stream, {
      shinychat::markdown_stream(
        session$ns("md_stream"),
        content_stream = "*Click Generate to stream output here.*",
        operation      = "replace",
        session        = session
      )
      session$sendCustomMessage(
        "update_status_badge",
        list(id = session$ns("stream_status_badge"), status = "idle")
      )
      log_event("DEBUG", "Markdown stream cleared", module = "markdown_stream")
    })

  })
}
