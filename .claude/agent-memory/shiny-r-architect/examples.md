---
name: examples-built
description: Reference apps built in examples/ and their key architectural facts (packages, data, helpers)
type: codebase-fact
updated: 2026-06-19
---

# Examples Built

## `examples/02. plotly/` — Plotly Reference App
- 5-tab app demonstrating all major plotly patterns
- 10M-row GWAS dataset (`gwas_data.csv`), uses `scattergl` + downsampling
- Reusable theme helpers in `R/utils_plotly_theme.R`
- Key packages: shiny, bslib, data.table, plotly, ggplot2, viridisLite

## `examples/03. modules/` — Shiny Modules Reference App
- 6-tab bslib `page_navbar` app demonstrating all major module patterns
- Inline synthetic clinical data (adsl/adae/adlb, no CSV)
- See [[module-patterns]] for the per-pattern cheat sheet

## `examples/05. shinychat/` — shinychat + ellmer Reference App (2026-06-19)
- 5-tab bslib flatly `page_navbar` (three-file layout). Packages: shinychat 0.4.0, ellmer 0.4.1, coro 1.1.0, bsicons 0.1.2, httr2 1.2.2
- Modules: `mod_basic_chat`, `mod_module_pattern`, `mod_markdown_stream`, `mod_advanced_ellmer`, `mod_control_panel`
- Shared state via `AppState` R6 class (`R/app_state.R`) — holds primary ellmer Chat client as `reactiveVal`
- **Tab 1 Basic Chat**: `chat_ui()` with `enable_cancel=TRUE`; streaming via `chat_append(id, client$stream_async(input))`;
  greeting with suggestion chips via `chat_set_greeting()` on `input$chat_greeting_requested`;
  badge toggled via `session$sendCustomMessage("update_status_badge", ...)` + JS handler in `www/status_badge.js`
- **Tab 2 Module Pattern**: `chat_mod_server()` returns locked env with `$status()`, `$last_input()`, `$last_turn()`,
  `$set_client()`, `$clear()`; `last_turn()` is an ellmer Turn object — extract text with `ellmer::contents_text(turn@contents)`
- **Tab 3 Markdown Stream**: `output_markdown_stream()` + `markdown_stream(id, content_stream=stream, operation="replace")`
  — note arg is `content_stream` (NOT `stream`); fresh client per click
- **Tab 4 Advanced ellmer**: `tool()` with `arguments=list(name=type_integer(...))` syntax; `chat_structured_async(text, type=.type)`
  returns a promise; sentiment type built with `type_object()` + `type_enum()` + `type_number()` + `type_string()`
- **Tab 5 Control Panel**: `ellmer::token_usage()` (session-level, no args); `client$get_tokens()` (per-client tibble 5 cols);
  `downloadHandler` exports turns as .md; `params(temperature=, top_p=, max_tokens=)` for LLM params
- Default model: `claude-sonnet-4-6` (ellmer default in this environment is `claude-sonnet-4-5-20250929`)
- `utils_logger.R` + `utils_error.R` copied verbatim from examples/04
- Status badge: CSS + JS in `www/`; NOT shinyjs (not installed)

Related: [[confirmed-conventions]]
