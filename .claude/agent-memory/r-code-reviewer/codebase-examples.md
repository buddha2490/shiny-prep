---
name: codebase-examples
description: Which reference example apps exist in examples/ and what each demonstrates
type: codebase-fact
updated: 2026-06-20
---

Reference examples live in `examples/`. Each is a self-contained three-file Shiny app.

| Dir | Purpose |
|---|---|
| `01. async/` | 7 async patterns: promises, future, ExtendedTask, mirai |
| `02. plotly/` | Plotly reference: scattergl, plotlyProxy, ggplotly, crosstalk, 10M-row GWAS data |
| `03. modules/` | 6-tab module patterns: basic, communication, reactiveValues, R6, nested, dynamic |
| `04. error-handling/` | log4r + error catalog reference; `utils_logger.R` + `utils_error.R` are copy targets |
| `05. shinychat/` | shinychat + ellmer + ragnar reference (6 tabs, updated 2026-06-20): streaming chat, chat_mod_server, markdown_stream, tool calling, structured output, turn inspector, RAG Chat |

`examples/05. shinychat/` now has 6 module files including `mod_rag_chat.R`, AppState R6 class, copied utils helpers, 145 unit tests (7+ test files), and a live-API AppDriver smoke test gated on `ANTHROPIC_API_KEY`.

## Key patterns established in example 05

- **ragnar + ellmer RAG pattern**: `ragnar_store_connect(read_only=TRUE)` per session (no explicit disconnect — DuckDB GC handles read-only connections); `ragnar_register_tool_retrieve()` on a DEDICATED ellmer client (not the shared AppState client); `ragnar_retrieve(top_k=5)` called directly after stream settles to populate a citations accordion.
- **Build step pattern**: `scripts/build_ragnar_store.R` is a one-shot build step, NOT sourced by global.R. Run via `Rscript -e 'source("renv/activate.R")' -e 'source("scripts/build_ragnar_store.R")'`.
- **Store unavailable degradation** (Testing Rule 6.3): `with_error_handling()` on `ragnar_store_connect()` → NULL check → early `return(invisible(NULL))` → renders instructional banner in card body. The `store_unavailable_ui` output is registered BEFORE the guard; `citations_ui` is registered AFTER, so it is absent on early return.
- **DBplyr masking note**: loading `dbplyr` after `dplyr` masks only internal rlang helpers (not user-facing dplyr verbs); no impact on this codebase which uses no dplyr verbs in the chat app modules. Example 03 modules uses dplyr verbs but not dbplyr.
- **DBI availability**: `DBI::dbDisconnect()` is accessible after `library(duckdb)` — DBI is on the search path as a duckdb dependency.
- **icon("plus") in actionButton**: confirmed safe pattern; "plus" is a valid Font Awesome 6 name. House convention: bare `icon()` for Font Awesome, `bsicons::bs_icon()` for Bootstrap Icons, NEVER mix them in `actionButton(icon=)`.
