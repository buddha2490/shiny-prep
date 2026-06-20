---
name: codebase-examples
description: Which reference example apps exist in examples/ and what each demonstrates
type: codebase-fact
updated: 2026-06-19
---

Reference examples live in `examples/`. Each is a self-contained three-file Shiny app.

| Dir | Purpose |
|---|---|
| `01. async/` | 7 async patterns: promises, future, ExtendedTask, mirai |
| `02. plotly/` | Plotly reference: scattergl, plotlyProxy, ggplotly, crosstalk, 10M-row GWAS data |
| `03. modules/` | 6-tab module patterns: basic, communication, reactiveValues, R6, nested, dynamic |
| `04. error-handling/` | log4r + error catalog reference; `utils_logger.R` + `utils_error.R` are copy targets |
| `05. shinychat/` | shinychat + ellmer reference (added 2026-06-19): streaming chat, chat_mod_server, markdown_stream, tool calling, structured output, turn inspector |

`examples/05. shinychat/` has 5 module files, AppState R6 class, copied utils helpers, 97 unit tests (6 test files), and a live-API AppDriver E2E test gated on `ANTHROPIC_API_KEY`.
