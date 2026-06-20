# =============================================================================
# mod_control_panel.R — Tab 5: Control Panel
# Created: 2026-06-19
# Purpose: Session-wide settings + analytics:
#   - Model selector (updates the shared client)
#   - System prompt editor with Apply button
#   - Temperature + advanced params (top_p, max_tokens) accordion
#   - Token usage DT (session-level via ellmer::token_usage())
#   - Session cost badge
#   - Export conversation (.md downloadHandler)
#   - Reset session button
# =============================================================================

# --- Module UI ---------------------------------------------------------------

#' Control Panel tab UI
#'
#' Sidebar layout: settings in sidebar, token analytics + export in main area.
#'
#' @param id Module namespace id.
#' @return A `bslib::nav_panel` UI object.
#' @export
mod_control_panel_ui <- function(id) {
  ns <- NS(id)

  bslib::nav_panel(
    title = tags$span(bsicons::bs_icon("sliders", class = "me-1"), "Control Panel"),
    value = "Control Panel",
    bslib::layout_sidebar(
      id = ns("control_panel_sidebar"),
      sidebar = bslib::sidebar(
        title  = "LLM Settings",
        width  = 320,
        open   = "always",

        # --- Model selector --- [2026-06-19]
        selectInput(
          ns("model_select"), "Model:",
          choices  = c(
            "Sonnet 4.6 (default)" = "claude-sonnet-4-6",
            "Haiku 4.5 (fast)"     = "claude-haiku-4-5-20251001",
            "Sonnet 4.5"           = "claude-sonnet-4-5-20250929"
          ),
          selected = "claude-sonnet-4-6"
        ),
        hr(),

        # --- System prompt --- [2026-06-19]
        textAreaInput(
          ns("system_prompt_edit"), "System Prompt:",
          rows  = 6,
          value = "You are a helpful AI assistant built with shinychat and ellmer in R Shiny."
        ),
        actionButton(
          ns("apply_system_prompt"), "Apply",
          class = "btn-sm btn-primary"
        ),
        hr(),

        # --- Temperature slider --- [2026-06-19]
        sliderInput(
          ns("temperature"), "Temperature:",
          min   = 0, max = 2,
          value = 1, step  = 0.1
        ),
        hr(),

        # --- Advanced params accordion --- [2026-06-19]
        bslib::accordion(
          id   = ns("advanced_params"),
          open = FALSE,
          bslib::accordion_panel(
            "Advanced Parameters",
            icon = bsicons::bs_icon("gear"),
            sliderInput(
              ns("top_p"), "top_p:",
              min   = 0, max = 1,
              value = 1, step  = 0.01
            ),
            numericInput(
              ns("max_tokens"), "max_tokens:",
              value = 4096, min = 256, max = 32768
            )
          )
        )
      ),

      # --- Main area: token analytics + export / reset ---------------------
      bslib::layout_columns(
        col_widths = c(12),
        fill       = FALSE,

        # Session token usage card
        bslib::card(
          bslib::card_header(
            class = "d-flex justify-content-between align-items-center",
            "Session Token Usage",
            uiOutput(ns("session_cost_badge"))
          ),
          bslib::card_body(
            DT::DTOutput(ns("token_usage_table"))
          )
        ),

        # Export + reset row
        bslib::layout_columns(
          col_widths = c(6, 6),
          fill       = FALSE,
          downloadButton(
            ns("export_conversation"), "Export Conversation (.md)",
            class = "btn-outline-secondary w-100"
          ),
          actionButton(
            ns("reset_session"), "Reset Session",
            class = "btn-outline-danger w-100",
            # actionButton$icon needs a shiny::icon() (Font Awesome), NOT a
            # bsicons SVG tag -- bs_icon() fails validateIcon() and breaks render.
            icon  = shiny::icon("rotate-left")
          )
        )
      )
    )
  )
}

# --- Module Server -----------------------------------------------------------

#' Control Panel tab server
#'
#' Manages session-wide LLM settings and feeds changes back to the shared
#' `AppState` R6 object so other tabs pick up the new client or params.
#' Token usage pulls from `ellmer::token_usage()` (session-level aggregator).
#'
#' @param id       Module namespace id.
#' @param app_state An `AppState` R6 object with `$client` (reactiveVal) and
#'   `$make_client(model, system_prompt, params_obj)` method.
#' @return Invisibly NULL.
#' @export
mod_control_panel_server <- function(id, app_state) {
  moduleServer(id, function(input, output, session) {

    # --- Apply model + system prompt + params --- [2026-06-19]
    # Rebuilds the shared client whenever settings are applied.
    # Temperature, top_p, and max_tokens are bundled into ellmer::params().
    observeEvent(input$apply_system_prompt, {
      new_params <- with_error_handling(
        ellmer::params(
          temperature = input$temperature,
          top_p       = input$top_p,
          max_tokens  = input$max_tokens
        ),
        code    = "ERR-CALC-001",
        context = list(module = "control_panel"),
        session = session
      )

      new_client <- with_error_handling(
        ellmer::chat_anthropic(
          model         = input$model_select,
          system_prompt = input$system_prompt_edit,
          params        = new_params
        ),
        code    = "ERR-LLM-001",
        context = list(module = "control_panel"),
        session = session
      )

      if (!is.null(new_client)) {
        app_state$client(new_client)
        shiny::showNotification(
          paste0("Settings applied: ", input$model_select),
          type = "message", duration = 3
        )
        log_event("INFO", "Client settings applied",
                  module = "control_panel", model = input$model_select)
      }
    })

    # --- Session cost badge --- [2026-06-19]
    # Shown in the card header. Refreshes when the token table does.
    output$session_cost_badge <- renderUI({
      usage <- with_error_handling(
        ellmer::token_usage(),
        code   = "ERR-CALC-001",
        notify = FALSE
      )
      if (is.null(usage) || nrow(usage) == 0) {
        return(tags$span(class = "badge bg-secondary", "$0.00"))
      }
      total_cost <- sum(as.numeric(usage$price), na.rm = TRUE)
      tags$span(
        class = "badge bg-success",
        sprintf("$%.5f", total_cost)
      )
    })

    # --- Session token usage DT --- [2026-06-19]
    # token_usage() returns a tibble with one row per (provider, model) combo.
    output$token_usage_table <- DT::renderDT({
      usage <- with_error_handling(
        ellmer::token_usage(),
        code   = "ERR-CALC-001",
        notify = FALSE
      )

      if (is.null(usage) || nrow(usage) == 0) {
        df <- data.frame(
          Provider = character(0), Model = character(0),
          Input = integer(0), Output = integer(0),
          "Cached Input" = integer(0), Cost = character(0),
          check.names = FALSE
        )
      } else {
        df <- data.frame(
          Provider       = usage$provider,
          Model          = usage$model,
          Input          = usage$input,
          Output         = usage$output,
          "Cached Input" = usage$cached_input,
          Cost           = sprintf("$%.5f", as.numeric(usage$price)),
          check.names    = FALSE,
          stringsAsFactors = FALSE
        )
      }

      DT::datatable(
        df,
        options  = list(dom = "t", pageLength = 25, scrollX = TRUE),
        rownames = FALSE,
        class    = "display compact"
      )
    })

    # --- Export conversation as Markdown --- [2026-06-19]
    # Pulls turns from the shared app_state client and formats as .md.
    output$export_conversation <- downloadHandler(
      filename = function() {
        paste0("conversation-", format(Sys.time(), "%Y%m%d-%H%M%S"), ".md")
      },
      content = function(file) {
        turns <- with_error_handling(
          app_state$client()$get_turns(include_system_prompt = FALSE),
          code    = "ERR-IO-001",
          context = list(module = "control_panel", action = "export"),
          session = session
        )

        if (is.null(turns) || length(turns) == 0) {
          writeLines("# Conversation\n\n*(no messages yet)*", file)
          return()
        }

        lines <- c(
          "# Exported Conversation",
          paste0("> Exported: ", format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z")),
          paste0("> Model: ", app_state$client()$get_model()),
          "",
          "---",
          ""
        )

        for (turn in turns) {
          role <- tryCatch(turn@role, error = function(e) "unknown")
          txt  <- tryCatch(
            ellmer::contents_text(turn@contents),
            error = function(e) "(non-text content)"
          )
          lines <- c(
            lines,
            paste0("## ", toupper(role)),
            "",
            txt,
            "",
            "---",
            ""
          )
        }

        writeLines(lines, file)
        log_event("INFO", "Conversation exported",
                  module = "control_panel", turns = length(turns))
      }
    )

    # --- Reset session --- [2026-06-19]
    # Rebuilds the shared client with default settings, clearing all history.
    observeEvent(input$reset_session, {
      new_client <- with_error_handling(
        ellmer::chat_anthropic(
          model         = "claude-sonnet-4-6",
          system_prompt = "You are a helpful AI assistant built with shinychat and ellmer in R Shiny."
        ),
        code    = "ERR-LLM-001",
        context = list(module = "control_panel", action = "reset"),
        session = session
      )

      if (!is.null(new_client)) {
        app_state$client(new_client)
        # Reset UI inputs to defaults
        updateSelectInput(session, "model_select", selected = "claude-sonnet-4-6")
        updateTextAreaInput(
          session, "system_prompt_edit",
          value = "You are a helpful AI assistant built with shinychat and ellmer in R Shiny."
        )
        updateSliderInput(session, "temperature", value = 1)
        updateSliderInput(session, "top_p",       value = 1)
        updateNumericInput(session, "max_tokens",  value = 4096)

        shiny::showNotification(
          "Session reset. All conversation history cleared.",
          type = "warning", duration = 4
        )
        log_event("INFO", "Session reset", module = "control_panel")
      }
    })

  })
}
