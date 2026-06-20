---
name: shinychat-app
description: Full UI/UX design spec for examples/05. shinychat/ — 5-tab shinychat+ellmer reference app
type: decision
updated: 2026-06-19
---

## Decision: theme

`bs_theme(version = 5, bootswatch = "flatly")` with custom overrides:
- `primary = "#2C3E50"` (dark slate — readable navbar)
- `success = "#18BC9C"` (flatly teal — used for streaming state)
- `info = "#3498DB"` (flatly blue — used for AI/assistant accents)
- `base_font = font_google("Inter")`, `code_font = font_google("JetBrains Mono")`

Flatly rationale: clean, professional, good contrast, widely known as the "modern clean" Shiny
theme. Its teal success color maps naturally to "streaming active" state. Inter is the dominant
clean sans-serif for developer tooling UIs.

## Decision: page structure

`page_navbar()` with `fillable = c("Basic Chat", "Module Pattern")` — only the two primary
chat tabs get viewport fill; the remaining three tabs are fluid content pages.

## Decision: navbar

```r
page_navbar(
  title = tags$span(
    bsicons::bs_icon("chat-dots-fill", class = "me-2 text-info"),
    "shinychat + ellmer"
  ),
  id = "main_nav",
  fillable = c("Basic Chat", "Module Pattern"),
  theme = bs_theme(...),
  navbar_options = navbar_options(class = "bg-primary", theme = "dark"),
  ...nav_panels...,
  nav_spacer(),
  nav_item(
    tags$span(
      class = "navbar-text text-white-50 small",
      "v0.4.0 / ellmer"
    )
  )
)
```

Tab icons (bsicons names):
1. Basic Chat — `"chat-left-text"`
2. Module Pattern — `"puzzle"`
3. Markdown Stream — `"file-text"`
4. Advanced ellmer — `"cpu"`
5. Control Panel — `"sliders"`

Nav panel title format: `tags$span(bsicons::bs_icon("name", class="me-1"), "Tab Title")`

## Decision: Tab 1 — Basic Chat layout

`layout_sidebar()` inside a fillable `nav_panel`. The sidebar holds all controls; the main area
is the chat window.

```
nav_panel("Basic Chat",
  layout_sidebar(
    fill = TRUE,
    sidebar = sidebar(
      title = "Controls",
      width = 280,
      open = "desktop",
      # --- Conversation ---
      actionButton("new_chat", "New Conversation",
                   icon = icon("plus"), class = "btn-outline-secondary w-100 mb-3"),
      hr(),
      # --- Demo buttons ---
      h6("Demos", class = "text-muted small text-uppercase"),
      actionButton("fill_input_demo", "Fill Input Demo",
                   class = "btn-outline-primary btn-sm w-100 mb-2"),
      actionButton("inject_msg_demo", "Inject Message",
                   class = "btn-outline-primary btn-sm w-100 mb-2"),
    ),
    # Main: chat window in a fill card
    card(
      fill = TRUE,
      card_header(
        class = "d-flex justify-content-between align-items-center",
        "Chat",
        tags$span(id = "basic_status_badge", class = "status-badge status-idle",
                  tags$span(class = "status-dot"), "Idle")
      ),
      card_body(
        padding = 0,
        class = "p-0",
        chat_ui("basic_chat",
                fill = TRUE,
                height = "100%",
                placeholder = "Ask anything...")
      )
    )
  )
)
```

Suggestion chips live in the `chat_ui()` greeting (see server note below). The greeting is set
server-side via `chat_set_greeting()` with a `chat_greeting()` containing `<span class="suggestion">` elements.

## Decision: Tab 2 — Module Pattern layout

Two equal columns. Left = chat module. Right = info card with reactive inspector panel.

```
layout_columns(
  col_widths = c(7, 5),
  fill = TRUE,
  # Left: chat module
  card(
    fill = TRUE,
    card_header(
      class = "d-flex justify-content-between align-items-center",
      "Chat Module",
      tags$span(id = "mod_status_badge", class = "status-badge status-idle", ...)
    ),
    card_body(padding = 0, chat_mod_ui("mod_chat", fill = TRUE))
  ),
  # Right: inspector
  card(
    card_header("Module Reactives"),
    card_body(
      h6("Status"),
      uiOutput("mod_status_display"),
      hr(),
      h6("Last User Input"),
      verbatimTextOutput("mod_last_input"),
      hr(),
      h6("Last Assistant Turn (excerpt)"),
      verbatimTextOutput("mod_last_turn"),
      hr(),
      layout_columns(
        col_widths = c(6, 6),
        fill = FALSE,
        selectInput("swap_model", "Model:", choices = c("claude-3-5-haiku-latest", "claude-3-5-sonnet-latest")),
        div(class = "d-flex align-items-end",
            actionButton("clear_mod", "Clear", class = "btn-outline-danger w-100"))
      )
    )
  )
)
```

## Decision: Tab 3 — Markdown Stream layout

`layout_columns(col_widths = c(4, 8))`. Left = controls card. Right = output card.

Left card:
- `textAreaInput("stream_prompt", "Prompt:", rows = 5)`
- `selectInput("content_type", "Content Type:", choices = c("markdown", "text", "html"))`
- `actionButton("generate_stream", "Generate", class = "btn-primary w-100")`
- `actionButton("clear_stream", "Clear", class = "btn-outline-secondary w-100 mt-2")`

Right card:
- `card_header("Output")`
- `card_body` containing `output_markdown_stream("md_stream", height = "auto", width = "100%")`
- The card gets `min_height = "400px"` so it doesn't collapse when empty.

Empty state: `output_markdown_stream()` renders with `content = "*Click Generate to stream output here.*"` as the initial placeholder.

## Decision: Tab 4 — Advanced ellmer layout

Three sub-sections stacked vertically inside a scrollable fluid page. Use
`navset_card_tab()` approach: NO — use three separate cards to keep sections always visible
and scannable (this is a reference app — showing all three sections simultaneously aids
comprehension).

```
layout_columns(
  col_widths = c(6, 6),
  # Card A: tool-calling chat
  card(
    min_height = "400px",
    card_header(
      bsicons::bs_icon("tools", class = "me-1"),
      "Tool Calling"
    ),
    card_body(
      padding = 0,
      chat_ui("tool_chat", fill = FALSE, height = "350px",
              placeholder = 'Try "What time is it?" or "Roll 3d6"')
    )
  ),
  # Card B: structured output
  card(
    card_header(
      bsicons::bs_icon("bar-chart-line", class = "me-1"),
      "Structured Output — Sentiment"
    ),
    card_body(
      textAreaInput("sentiment_text", "Text to analyze:", rows = 3,
                    value = "The new bslib update is absolutely fantastic!"),
      actionButton("run_sentiment", "Analyze", class = "btn-primary"),
      hr(),
      layout_column_wrap(
        width = "200px",
        uiOutput("sentiment_box"),    # value_box rendered server-side
        uiOutput("confidence_box")
      ),
      uiOutput("sentiment_summary")
    )
  )
)
# Below: turn inspector (full width)
card(
  card_header(
    bsicons::bs_icon("table", class = "me-1"),
    "Turn Inspector"
  ),
  card_body(
    layout_columns(
      col_widths = c(8, 4),
      fill = FALSE,
      DTOutput("turn_table"),
      card(
        class = "bg-light border-0",
        card_body(
          h6("Session Token Usage", class = "text-muted"),
          uiOutput("token_summary")
        )
      )
    )
  )
)
```

## Decision: sentiment value_box color mapping

| Sentiment   | theme                        | icon                  |
|-------------|------------------------------|-----------------------|
| Positive    | `"bg-gradient-teal-green"`   | `"emoji-smile-fill"`  |
| Neutral     | `"secondary"`                | `"emoji-neutral-fill"`|
| Negative    | `"danger"`                   | `"emoji-frown-fill"`  |
| (loading)   | `"bg-light"` + spinner       | `"hourglass-split"`   |

Confidence box always `theme = "info"`, icon `"speedometer2"`, value = formatted percentage.
Both boxes render via `renderUI()` in server so they can swap theme dynamically.

## Decision: Tab 5 — Control Panel layout

`layout_sidebar()` with sidebar = settings, main = token/session analytics.

```
layout_sidebar(
  sidebar = sidebar(
    title = "LLM Settings",
    width = 320,
    open = "always",
    selectInput("model_select", "Model:", choices = ...),
    hr(),
    textAreaInput("system_prompt_edit", "System Prompt:", rows = 6),
    actionButton("apply_system_prompt", "Apply", class = "btn-sm btn-primary"),
    hr(),
    sliderInput("temperature", "Temperature:", min = 0, max = 2, value = 1, step = 0.1),
    hr(),
    accordion(
      id = "advanced_params",
      open = FALSE,
      accordion_panel(
        "Advanced Parameters",
        icon = bsicons::bs_icon("gear"),
        sliderInput("top_p", "top_p:", min = 0, max = 1, value = 1, step = 0.01),
        numericInput("max_tokens", "max_tokens:", value = 4096, min = 256, max = 32768)
      )
    )
  ),
  # Main area
  layout_columns(
    col_widths = c(12),
    fill = FALSE,
    card(
      card_header(
        class = "d-flex justify-content-between align-items-center",
        "Session Token Usage",
        uiOutput("session_cost_badge")
      ),
      card_body(DTOutput("token_usage_table"))
    ),
    layout_columns(
      col_widths = c(6, 6),
      fill = FALSE,
      downloadButton("export_conversation", "Export Conversation",
                     class = "btn-outline-secondary w-100"),
      actionButton("reset_session", "Reset Session",
                   class = "btn-outline-danger w-100",
                   icon = icon("arrow-counterclockwise"))
    )
  )
)
```

## Decision: Streaming/Idle badge (used on tabs 1 and 2)

HTML structure (in card_header via d-flex):
```html
<span class="status-badge status-idle">
  <span class="status-dot"></span>
  Idle
</span>
```

CSS in www/custom.css:
```css
.status-badge {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  font-size: 0.75rem;
  font-weight: 500;
  padding: 3px 10px;
  border-radius: 999px;
  letter-spacing: 0.03em;
  text-transform: uppercase;
}
.status-dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  flex-shrink: 0;
}
.status-idle { background: #f0f0f0; color: #6c757d; }
.status-idle .status-dot { background: #adb5bd; }
.status-streaming { background: #d4edda; color: #155724; }
.status-streaming .status-dot {
  background: #18BC9C;
  animation: pulse-dot 1.2s ease-in-out infinite;
}
@keyframes pulse-dot {
  0%, 100% { opacity: 1; transform: scale(1); }
  50%       { opacity: 0.4; transform: scale(0.7); }
}
```

Server toggles the badge class via `shinyjs::toggleClass()` or `session$sendCustomMessage()`.

## Decision: Suggestion chips (Tab 1 greeting)

Chips are `<span class="suggestion">` elements inside a `chat_greeting()` object — this is the
native shinychat pattern (confirmed in RAG). shinychat renders `.suggestion` spans as clickable
chips that fill the chat input. No custom CSS needed for the chips themselves; shinychat ships
the chip styles. The greeting markdown/HTML is set via `chat_set_greeting()` from server on
`input$basic_chat_greeting_requested`.

Example greeting content:
```r
paste(
  "## Welcome to shinychat\n\n",
  "This tab demonstrates streaming chat backed by Anthropic Claude.",
  "Try one of these to get started:\n\n",
  '<span class="suggestion">Explain async streaming in Shiny</span>\n',
  '<span class="suggestion">Write a haiku about R</span>\n',
  '<span class="suggestion">What can ellmer do?</span>'
)
```

## Decision: CSS file (www/custom.css)

Additions beyond the status badge:
```css
:root {
  --sc-chat-bg: #f8f9fa;
  --sc-accent: #18BC9C;
  --sc-border: #dee2e6;
}

/* Remove default padding from chat card_body so chat_ui fills flush */
.chat-card-body { padding: 0 !important; }

/* Turn inspector DT: compact row height */
#turn_table .dataTable td { font-size: 0.82rem; }

/* Token summary card in control panel: right-align numbers */
.token-summary-value { font-size: 1.4rem; font-weight: 600; color: var(--sc-accent); }

/* Markdown stream placeholder text */
.shiny-markdown-stream:empty::after {
  content: attr(data-placeholder);
  color: #adb5bd;
  font-style: italic;
}
```

## Related

See [[ux-conventions]] for project-wide rules.
