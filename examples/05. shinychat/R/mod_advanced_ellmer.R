# =============================================================================
# mod_advanced_ellmer.R — Tab 4: Advanced ellmer
# Created: 2026-06-19
# Purpose: Three sections always visible:
#   A. Tool calling — two tools (get_current_time, roll_dice) wired via tool()
#      and register_tool(), exercised through a chat_ui()
#   B. Structured output — sentiment analysis via chat_structured_async(),
#      result shown as value_box + confidence value_box
#   C. Turn inspector — DT showing all turns + per-turn token usage
# =============================================================================

# --- Helper: tool definitions ------------------------------------------------

#' Create ellmer tool for getting the current server time
#'
#' Returns current date/time as a string. No arguments needed.
#' @return An ellmer tool object.
make_time_tool <- function() {
  ellmer::tool(
    fun         = function() format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z"),
    description = "Get the current server date and time."
  )
}

#' Create ellmer tool for rolling dice
#'
#' Rolls N dice with S sides and returns the results plus sum.
#' @return An ellmer tool object.
make_dice_tool <- function() {
  ellmer::tool(
    fun = function(n_dice = 1, sides = 6) {
      rolls <- sample(sides, n_dice, replace = TRUE)
      list(
        rolls = rolls,
        total = sum(rolls),
        label = paste0(n_dice, "d", sides)
      )
    },
    description = "Roll one or more dice. Returns each die result and the total.",
    arguments   = list(
      n_dice = ellmer::type_integer("Number of dice to roll (default 1).", required = FALSE),
      sides  = ellmer::type_integer("Number of sides per die (default 6).", required = FALSE)
    )
  )
}

# --- Structured output type definition ---------------------------------------

# Sentiment analysis schema: { sentiment, confidence, reason }
.sentiment_type <- ellmer::type_object(
  "Sentiment analysis result for a piece of text.",
  sentiment  = ellmer::type_enum(
    c("positive", "neutral", "negative"),
    "Overall sentiment of the text."
  ),
  confidence = ellmer::type_number(
    "Confidence score from 0.0 to 1.0."
  ),
  reason     = ellmer::type_string(
    "One-sentence explanation of the sentiment classification."
  )
)

# --- Module UI ---------------------------------------------------------------

#' Advanced ellmer tab UI
#'
#' Three sections stacked: tool-calling + structured output side-by-side,
#' then turn inspector full-width below.
#'
#' @param id Module namespace id.
#' @return A `bslib::nav_panel` UI object.
#' @export
mod_advanced_ellmer_ui <- function(id) {
  ns <- NS(id)

  bslib::nav_panel(
    title = tags$span(bsicons::bs_icon("cpu", class = "me-1"), "Advanced ellmer"),
    value = "Advanced ellmer",

    # --- Row 1: tool calling + structured output (side by side) ----------
    bslib::layout_columns(
      col_widths = c(6, 6),
      fill       = FALSE,

      # Card A: Tool calling
      bslib::card(
        min_height = 400,
        bslib::card_header(
          bsicons::bs_icon("tools", class = "me-1"),
          "Tool Calling"
        ),
        bslib::card_body(
          padding = 0,
          class   = "chat-card-body",
          shinychat::chat_ui(
            ns("tool_chat"),
            fill        = FALSE,
            height      = "350px",
            placeholder = 'Try "What time is it?" or "Roll 3d6"'
          )
        )
      ),

      # Card B: Structured output
      bslib::card(
        bslib::card_header(
          bsicons::bs_icon("bar-chart-line", class = "me-1"),
          "Structured Output — Sentiment"
        ),
        bslib::card_body(
          textAreaInput(
            ns("sentiment_text"), "Text to analyze:",
            rows  = 3,
            value = "The new bslib update is absolutely fantastic!"
          ),
          actionButton(
            ns("run_sentiment"), "Analyze",
            class = "btn-primary"
          ),
          hr(),
          bslib::layout_column_wrap(
            width = "200px",
            uiOutput(ns("sentiment_box")),
            uiOutput(ns("confidence_box"))
          ),
          uiOutput(ns("sentiment_summary"))
        )
      )
    ),

    # --- Row 2: Turn inspector (full width) --------------------------------
    bslib::card(
      bslib::card_header(
        bsicons::bs_icon("table", class = "me-1"),
        "Turn Inspector"
      ),
      bslib::card_body(
        bslib::layout_columns(
          col_widths = c(8, 4),
          fill       = FALSE,
          DT::DTOutput(ns("turn_table")),
          bslib::card(
            class = "bg-light border-0",
            bslib::card_body(
              h6("Session Token Usage", class = "text-muted"),
              uiOutput(ns("token_summary"))
            )
          )
        )
      )
    )
  )
}

# --- Module Server -----------------------------------------------------------

#' Advanced ellmer tab server
#'
#' Wires tool-calling chat, structured output sentiment analysis, and turn
#' inspector. Three separate ellmer clients are used so tool registration
#' and structured output calls don't interfere with each other or the basic
#' chat tab.
#'
#' @param id      Module namespace id.
#' @param client  A reactive expression returning the main ellmer Chat object
#'   (used only for turn inspector / token data; tool_chat and sentiment use
#'   dedicated clients).
#' @return Invisibly NULL.
#' @export
mod_advanced_ellmer_server <- function(id, client) {
  moduleServer(id, function(input, output, session) {

    # --- Create dedicated clients for tool calling + sentiment --- [2026-06-19]
    # Tool client registers the two demo tools.
    tool_client <- with_error_handling(
      {
        cl <- ellmer::chat_anthropic(
          model         = "claude-sonnet-4-6",
          system_prompt = paste0(
            "You are a helpful assistant with access to tools. ",
            "When asked about the time, use the get_current_time tool. ",
            "When asked to roll dice (e.g., 3d6), use the roll_dice tool. ",
            "Report tool results clearly."
          )
        )
        cl$register_tool(make_time_tool())
        cl$register_tool(make_dice_tool())
        cl
      },
      code    = "ERR-LLM-001",
      context = list(module = "advanced_ellmer"),
      session = session
    )

    # Dedicated client for structured output (no tools, no chat history)
    sentiment_client <- with_error_handling(
      ellmer::chat_anthropic(
        model         = "claude-sonnet-4-6",
        system_prompt = "You are a sentiment analysis engine. Analyze text objectively."
      ),
      code    = "ERR-LLM-001",
      context = list(module = "advanced_ellmer"),
      session = session
    )

    # --- Tool chat: stream responses via chat_append --- [2026-06-19]
    # `stream_settled` is bumped only AFTER the async stream resolves, so the
    # turn inspector and token summary refresh once the assistant turn actually
    # exists on the client -- not at submit time (which would lag one exchange).
    stream_settled <- reactiveVal(0L)

    observeEvent(input$tool_chat_user_input, {
      req(input$tool_chat_user_input, !is.null(tool_client))

      stream <- with_error_handling(
        tool_client$stream_async(input$tool_chat_user_input),
        code    = "ERR-LLM-001",
        context = list(module = "advanced_ellmer", section = "tool_chat"),
        session = session
      )

      if (!is.null(stream)) {
        p <- shinychat::chat_append("tool_chat", stream, session = session)
        # Refresh dependents only once the turn is committed to the client.
        promises::then(p, function(...) stream_settled(stream_settled() + 1L))
      }
    })

    # --- Structured output: sentiment analysis --- [2026-06-19]
    # Uses chat_structured_async() which returns a promise resolving to
    # a named list matching .sentiment_type schema.
    sentiment_result <- reactiveVal(NULL)

    observeEvent(input$run_sentiment, {
      req(input$sentiment_text, nchar(trimws(input$sentiment_text)) > 0,
          !is.null(sentiment_client))

      # Show loading state
      sentiment_result(list(status = "loading"))

      p <- with_error_handling(
        sentiment_client$chat_structured_async(
          input$sentiment_text,
          type = .sentiment_type
        ),
        code    = "ERR-LLM-002",
        context = list(module = "advanced_ellmer", section = "sentiment"),
        session = session
      )

      if (!is.null(p)) {
        promises::then(
          p,
          function(result) {
            sentiment_result(list(status = "done", data = result))
            log_event("INFO", "Sentiment analysis complete",
                      module = "advanced_ellmer",
                      sentiment = result$sentiment)
          },
          function(err) {
            sentiment_result(NULL)
            log_event("ERROR", conditionMessage(err),
                      code = "ERR-LLM-002", module = "advanced_ellmer")
          }
        )
      } else {
        sentiment_result(NULL)
      }
    })

    # --- Sentiment value_box render --- [2026-06-19]
    output$sentiment_box <- renderUI({
      res <- sentiment_result()
      if (is.null(res)) return(NULL)

      if (res$status == "loading") {
        bslib::value_box(
          title    = "Sentiment",
          value    = tags$span(class = "spinner-border spinner-border-sm"),
          showcase = bsicons::bs_icon("hourglass-split"),
          theme    = "secondary"
        )
      } else {
        d <- res$data
        cfg <- switch(
          d$sentiment,
          "positive" = list(theme = "success",   icon = "emoji-smile-fill"),
          "neutral"  = list(theme = "secondary",  icon = "emoji-neutral-fill"),
          "negative" = list(theme = "danger",     icon = "emoji-frown-fill"),
                       list(theme = "secondary",   icon = "emoji-neutral-fill")
        )
        bslib::value_box(
          title    = "Sentiment",
          value    = toupper(d$sentiment),
          showcase = bsicons::bs_icon(cfg$icon),
          theme    = cfg$theme
        )
      }
    })

    # --- Confidence value_box render --- [2026-06-19]
    output$confidence_box <- renderUI({
      res <- sentiment_result()
      if (is.null(res) || res$status == "loading") return(NULL)

      bslib::value_box(
        title    = "Confidence",
        value    = percent(res$data$confidence, accuracy = 1),
        showcase = bsicons::bs_icon("speedometer2"),
        theme    = "info"
      )
    })

    # --- Sentiment reason text --- [2026-06-19]
    output$sentiment_summary <- renderUI({
      res <- sentiment_result()
      if (is.null(res) || res$status == "loading") return(NULL)
      tags$p(
        class = "text-muted mt-2 small",
        tags$em(res$data$reason)
      )
    })

    # --- Turn inspector DT --- [2026-06-19]
    # Shows all turns from the tool_client; refreshes on each new turn.
    turn_data <- reactive({
      # Refresh after each stream completes (not at submit time)
      stream_settled()

      if (is.null(tool_client)) return(data.frame())

      turns <- with_error_handling(
        tool_client$get_turns(include_system_prompt = FALSE),
        code    = "ERR-CALC-001",
        context = list(module = "advanced_ellmer", section = "turns"),
        notify  = FALSE,
        session = session
      )

      if (is.null(turns) || length(turns) == 0) {
        return(data.frame(
          Turn  = integer(0),
          Role  = character(0),
          Text  = character(0),
          stringsAsFactors = FALSE
        ))
      }

      rows <- lapply(seq_along(turns), function(i) {
        t <- turns[[i]]
        role <- tryCatch(t@role, error = function(e) "?")
        text <- tryCatch(
          {
            txt <- ellmer::contents_text(t@contents)
            if (nchar(txt) > 120) paste0(substr(txt, 1, 120), "...") else txt
          },
          error = function(e) "(non-text content)"
        )
        data.frame(Turn = i, Role = role, Text = text, stringsAsFactors = FALSE)
      })
      do.call(rbind, rows)
    })

    output$turn_table <- DT::renderDT({
      df <- turn_data()
      DT::datatable(
        df,
        options   = list(pageLength = 10, dom = "tp", scrollX = TRUE),
        rownames  = FALSE,
        selection = "single",
        class     = "display compact"
      )
    })

    # --- Token usage summary --- [2026-06-19]
    # get_tokens() returns a tibble with one row per turn. Sum across all turns.
    output$token_summary <- renderUI({
      stream_settled()  # refresh after each stream completes

      if (is.null(tool_client)) return(NULL)

      tok <- with_error_handling(
        tool_client$get_tokens(),
        code    = "ERR-CALC-001",
        context = list(module = "advanced_ellmer"),
        notify  = FALSE,
        session = session
      )

      if (is.null(tok) || nrow(tok) == 0) {
        return(tags$p(class = "text-muted small", "Send a message to see token usage."))
      }

      total_in  <- sum(tok$input,  na.rm = TRUE)
      total_out <- sum(tok$output, na.rm = TRUE)
      cost      <- with_error_handling(
        tool_client$get_cost(),
        code   = "ERR-CALC-001",
        notify = FALSE
      )
      cost_fmt <- if (!is.null(cost)) sprintf("$%.5f", as.numeric(cost)) else "n/a"

      tags$div(
        tags$p(tags$span("Input tokens: "),
               tags$span(class = "token-summary-value", format(total_in, big.mark = ","))),
        tags$p(tags$span("Output tokens: "),
               tags$span(class = "token-summary-value", format(total_out, big.mark = ","))),
        tags$p(tags$span("Cost: "),
               tags$span(class = "token-summary-value", cost_fmt))
      )
    })

  })
}
