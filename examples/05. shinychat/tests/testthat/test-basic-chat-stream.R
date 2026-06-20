# =============================================================================
# test-basic-chat-stream.R — AppDriver E2E test for Basic Chat streaming
# =============================================================================
# This test exercises the headline feature: token-by-token LLM streaming via
# shinychat's chat_append() + ellmer's stream_async(). It launches the real
# app, submits a short deterministic prompt, waits for the response, and
# asserts that an assistant message appears in the chat DOM.
#
# The test hits the real Anthropic API. It is gated on ANTHROPIC_API_KEY
# being set, which is required for the server function to create an ellmer
# client successfully.
#
# NOTE: In shinytest2 0.5+, AppDriver tests live in tests/testthat/ alongside
# unit tests. test_app() scans tests/testthat/ only.
#
# NOTE on shinychat input: the chat textarea uses `data-shiny-no-bind-input`
# so Shiny does not register it as a standard input. Submission must be done
# via JavaScript — type into the textarea and dispatch the custom
# "shiny-chat-input-sent" event that shinychat's JS handler listens for.
# =============================================================================

library(shinytest2)
library(testthat)

# Gate the entire file on the API key being available.
testthat::skip_if(
  Sys.getenv("ANTHROPIC_API_KEY") == "",
  message = "ANTHROPIC_API_KEY not set — skipping live API tests"
)

# Path to the shinychat app directory (two levels up from tests/testthat/).
APP_DIR <- file.path("..", "..")

# --- Helper: submit a message to a shinychat chat_ui() ----------------------
# shinychat uses a Web Component (<shiny-chat-container>) whose textarea is NOT
# a standard Shiny input. The component listens for an "Enter" keydown event
# on the textarea. We simulate this via JavaScript.
submit_chat_message <- function(app, textarea_id, message) {
  js <- sprintf(
    "
    (function() {
      var ta = document.getElementById('%s');
      if (!ta) { return 'textarea not found'; }
      // Set the value
      var nativeInputValueSetter = Object.getOwnPropertyDescriptor(
        window.HTMLTextAreaElement.prototype, 'value').set;
      nativeInputValueSetter.call(ta, '%s');
      ta.dispatchEvent(new Event('input', { bubbles: true }));
      // Dispatch Enter keydown to trigger submission
      ta.dispatchEvent(new KeyboardEvent('keydown', {
        bubbles: true, cancelable: true, key: 'Enter', code: 'Enter', keyCode: 13
      }));
      return 'submitted';
    })()
    ",
    textarea_id,
    gsub("'", "\\\\'", message)   # escape single quotes in message
  )
  app$run_js(js)
}

# =============================================================================
# Test 1: Basic Chat — streaming response reaches the DOM
# =============================================================================

test_that("Basic Chat streams an assistant reply for a deterministic prompt", {
  app <- AppDriver$new(
    app_dir      = APP_DIR,
    name         = "basic-chat-stream",
    seed         = 42L,
    load_timeout = 90000L,  # generous: cold headless-Chrome + font_google theme build
    timeout      = 60000L
  )
  on.exit(app$stop(), add = TRUE)

  # Wait for the app to fully initialize and the greeting to appear.
  app$wait_for_idle(timeout = 20000L)

  # Submit the message via JavaScript (shinychat uses a Web Component —
  # set_inputs() does not reach the textarea).
  submit_chat_message(app, "basic_chat-chat_user_input", "Reply with exactly the word: pong")

  # Wait for the streaming response to complete.
  # The stream is done when Shiny becomes idle again.
  app$wait_for_idle(timeout = 45000L)

  # Take a screenshot as evidence of the streamed response.
  screenshot_path <- tempfile(fileext = ".png")
  app$get_screenshot(file = screenshot_path)
  message("Screenshot saved to: ", screenshot_path)

  # Assert that an assistant message appeared in the DOM.
  # shinychat renders streamed content inside the shiny-chat-messages area.
  page_html <- app$get_html("body")
  expect_match(
    page_html,
    "pong",
    ignore.case = TRUE,
    info = "Expected 'pong' in the chat response from the LLM"
  )
})

# =============================================================================
# Test 2: Basic Chat — "New Conversation" button clears chat state
# =============================================================================

test_that("New Conversation button clears chat and resets badge to Idle", {
  app <- AppDriver$new(
    app_dir      = APP_DIR,
    name         = "basic-chat-clear",
    seed         = 42L,
    load_timeout = 90000L,  # generous: cold headless-Chrome + font_google theme build
    timeout      = 60000L
  )
  on.exit(app$stop(), add = TRUE)

  app$wait_for_idle(timeout = 20000L)

  # Submit a message and wait for a response.
  submit_chat_message(app, "basic_chat-chat_user_input", "Say hello briefly")
  app$wait_for_idle(timeout = 45000L)

  # Click the "New Conversation" button.
  app$click(input = "basic_chat-new_chat")
  app$wait_for_idle(timeout = 5000L)

  # After clearing, the messages area should be empty (greeting only).
  messages_html <- app$get_html(".shiny-chat-messages-content")
  # The messages content area should be empty or contain only the greeting.
  expect_match(
    messages_html,
    "shiny-chat-messages-content",
    info = "Messages content element should be present after clear"
  )

  # Status badge should say Idle.
  badge_html <- app$get_html("#basic_chat-status_badge")
  expect_match(badge_html, "Idle", info = "Status badge should be Idle after clearing")

  # Take a final screenshot.
  app$get_screenshot(file = tempfile(fileext = ".png"))
})

# =============================================================================
# Test 3: Fill Input Demo — pre-populates the input field
# =============================================================================

test_that("Fill Input Demo pre-populates the chat input without submitting", {
  app <- AppDriver$new(
    app_dir      = APP_DIR,
    name         = "basic-chat-fill-demo",
    seed         = 42L,
    load_timeout = 90000L,  # generous: cold headless-Chrome + font_google theme build
    timeout      = 30000L
  )
  on.exit(app$stop(), add = TRUE)

  app$wait_for_idle(timeout = 20000L)

  # Click the "Fill Input Demo" button.
  app$click(input = "basic_chat-fill_input_demo")
  app$wait_for_idle(timeout = 5000L)

  # The chat input textarea should now contain the demo text.
  # Use get_js() (not run_js()) to retrieve the JavaScript return value.
  ta_value <- app$get_js(
    "document.getElementById('basic_chat-chat_user_input').value"
  )

  # The fill demo sets: "Describe three use cases for shinychat in a pharma/clinical context."
  expect_match(
    ta_value,
    "pharma",
    ignore.case = TRUE,
    info = "Fill Input Demo should pre-populate with pharma/clinical text"
  )
})
