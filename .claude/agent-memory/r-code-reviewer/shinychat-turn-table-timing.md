---
name: shinychat-turn-table-timing
description: turn_data reactive in mod_advanced_ellmer fires on user input, not stream completion — table is always one exchange behind
type: pitfall
updated: 2026-06-19
---

In `examples/05. shinychat/R/mod_advanced_ellmer.R`, the `turn_data` reactive and the `token_summary` renderUI both declare `input$tool_chat_user_input` as their refresh dependency.

This fires immediately when the user submits — **before** the LLM stream completes. `tool_client$get_turns()` at that moment contains only the user turn. The assistant turn is added to the client only after the stream settles. The table therefore shows the assistant turn from the *previous* exchange, not the current one.

**Correct approach** for an example app: use a `reactiveVal` (e.g., `refresh_trigger <- reactiveVal(0L)`) incremented inside the `promises::then()` callback when the stream finishes, and have `turn_data` depend on that instead of the input. This defers the DT refresh until the data actually exists.

**Severity in this context:** Should-fix for a reference app (readers may copy the pattern and wonder why the table is stale).
