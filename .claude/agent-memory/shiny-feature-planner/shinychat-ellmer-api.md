---
name: shinychat-ellmer-api
description: Complete shinychat + ellmer API surface enumerated from RAG for examples/05 planning session
type: codebase-fact
updated: 2026-06-19
---

## shinychat API surface (v0.4.0, 12 functions)

### Core UI/Server pair
- `chat_ui(id, ..., messages, greeting, placeholder, width, height, fill, icon_assistant, enable_cancel, footer)`
  - Input event: `input$<id>_user_input`
  - Greeting event: `input$<id>_greeting_requested`
- `chat_mod_ui(id, messages)` — module variant of chat_ui
- `chat_mod_server(id, client, greeting)` — returns env with:
  - `$last_input` (reactive), `$last_turn` (reactive), `$status` (reactive: "idle"/"streaming")
  - `$client` (active binding), `$set_client(new_client, sync=TRUE)`
  - `$update_user_input(...)`, `$append(...)`, `$clear(messages, client_history)`, `$set_greeting(...)`

### Message appending
- `chat_append(id, response, role, icon, session)` — high-level; accepts string/generator/promise/promise-generator
- `chat_append_message(id, msg, chunk, operation, icon, session)` — low-level chunked control

### Greeting system
- `chat_greeting(content, dismissible=TRUE)` — wraps static/streaming content
- `chat_set_greeting(id, greeting, session)` — server-side greeting setter
- `chat_clear(id, greeting=FALSE, session)` — clear chat; greeting=TRUE re-fires greeting_requested

### update / reset
- `update_chat_user_input(id, ..., value, placeholder, submit, focus, session)`

### markdown_stream (standalone streaming outside chat)
- `output_markdown_stream(id, ..., content, content_type, auto_scroll, width, height)` — UI
- `markdown_stream(id, stream, session)` — server (implied from RAG context)

### chat_app
- `chat_app(client)` — standalone single-user console app, NOT for multi-user Shiny

## ellmer API surface (v1.5.0, key methods)

### Chat client creation
- `chat_anthropic(system_prompt, params, model, cache, api_key, ...)` — default model: "claude-sonnet-4-5-20250929"
- `chat_claude()` — alias for chat_anthropic
- `models_anthropic()` / `models_claude()` — list available models
- `chat(name, ..., system_prompt, params)` — generic "provider/model" string interface

### params() helper
- `params(temperature, top_p, top_k, max_tokens, seed, reasoning_effort, ...)`

### Chat R6 methods (key ones)
- `$get_turns(include_system_prompt=FALSE)` / `$set_turns(value)` / `$add_turn()`
- `$get_system_prompt()` / `$set_system_prompt(value)` / `$get_model()`
- `$get_tokens()` — df: input/output/cached_input/cost per turn
- `$get_cost(include=c("all","last"))`
- `$last_turn(role)`
- `$chat(...)` — sync, returns string
- `$stream(...)` — sync streaming generator
- `$stream_async(...)` — async streaming generator (use in Shiny)
- `$chat_structured(...)` / `$chat_structured_async(...)` — structured output
- `$register_tool(tool)` / `$register_tools(tools)` / `$get_tools()` / `$set_tools()`
- `$on_tool_request(callback)` / `$on_tool_result(callback)` — tool lifecycle hooks
- `$clone()` — used by chat_mod_server for greeting client

### Tool definition
- `tool(fun, description, ..., arguments, name, convert, annotations)`
- `tool_reject(reason)` — reject from within tool function
- `create_tool_def(topic, chat)` — interactive helper to generate tool() call

### Content types for input
- `content_image_url(url, detail)` — remote image
- `content_image_file(path, content_type, resize)` — local image
- `content_image_plot(width, height)` — current R plot
- `content_pdf_file(path)` / `content_pdf_url(url)` — PDF input

### Content types (output inspection)
- `ContentText`, `ContentImageRemote`, `ContentImageInline`, `ContentToolRequest`, `ContentToolResult`
- `contents_text(content)`, `contents_markdown(content)`, `contents_html(content)`

### Async cancellation
- `stream_controller()` — returns object with `$cancel()`, `$reset()`, `$cancelled`, `$reason`
- Pass `controller=` to `$stream_async()` to enable mid-stream cancellation

### Token tracking
- `token_usage()` — session-level cumulative token + cost report

### Prompt helpers
- `interpolate(prompt, ...)` / `interpolate_file(path, ...)` — glue-based prompt templating with {{ }}

## Key integration notes

- `chat_append(id, client$stream_async(input))` is the core streaming pattern
- `enable_cancel = TRUE` in `chat_ui()` + `stream_controller()` enables cancel button
- `chat_mod_server()` returned `$status` reactive = "idle"/"streaming" for UI state management
- `chat_mod_server()` `set_client(new_client, sync=TRUE)` swaps model mid-conversation
- Token display: `client$get_tokens()` after each turn, `token_usage()` for session total
- `$get_cost()` returns dollar cost of conversation
- Streaming greetings use `ExtendedTask` internally (session stays responsive)
- `coro` package is required for `async_generator` used in `chat_append_message` examples

## Packages required for examples/05

Must install + `renv::snapshot()`:
1. `shinychat` (GitHub: posit-dev/shinychat or CRAN)
2. `ellmer` (CRAN)
3. `coro` (CRAN — async generator support)
4. `bsicons` (CRAN — for icon_assistant / custom icons)
