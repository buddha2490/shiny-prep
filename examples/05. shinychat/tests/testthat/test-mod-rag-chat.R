# =============================================================================
# test-mod-rag-chat.R — Unit + testServer() tests for R/mod_rag_chat.R
# =============================================================================
# Coverage:
#   A. format_rag_citations() unit tests (pure function, no Shiny required)
#      - NULL input -> placeholder paragraph
#      - zero-row tibble -> placeholder paragraph
#      - multi-row tibble -> accordion, one panel per row, truncation, origin in output
#      - excerpt_chars < 1 -> stop()
#      - excerpt_chars coercion from numeric to integer
#      - short text not truncated (no ellipsis added)
#      - NA origin -> "unknown source" fallback
#   B. mod_rag_chat_server() testServer() tests
#      - NULL-store degradation: server returns without error; store_unavailable_ui renders
#        "Knowledge store not found" message; no downstream crash
#      - NULL-client degradation: server returns without error when API key is absent
#        (gated: skip if DuckDB store file is absent)
#
# Testing Rule 3 — all test data via factory functions, no top-level objects.
# Testing Rule 6.3 — the NULL-store degradation path is the critical "no
#   closure-not-subsettable cascade" guarantee exercised here.
#
# Source strategy: sources must match how global.R wires them.
# =============================================================================

library(testthat)
library(shiny)
library(tibble)

source(file.path("..", "..", "R", "utils_logger.R"))
source(file.path("..", "..", "R", "utils_error.R"))
source(file.path("..", "..", "R", "mod_rag_chat.R"))

# Silence logger output during tests (no file writes).
init_logger(app_name = "test-rag", log_dir = tempdir(), to_file = FALSE)

# Path to the real store — used to decide whether store-present tests can run.
STORE_PATH <- file.path("..", "..", "data", "shiny_kb.duckdb")

# =============================================================================
# A. format_rag_citations() — Unit tests
# =============================================================================

# --- Factory -----------------------------------------------------------------

#' Factory: a well-formed chunk tibble as returned by ragnar_retrieve().
#' The `origin` column holds a filename string; `text` holds the chunk body.
#' @param n Number of rows to generate (default 3).
#' @param text_length Characters in each row's text field (default 300).
make_mock_chunks <- function(n = 3L, text_length = 300L) {
  tibble(
    origin = paste0("source_", seq_len(n), ".md"),
    text   = vapply(
      seq_len(n),
      function(i) paste(rep(letters[(i - 1L) %% 26L + 1L], text_length), collapse = ""),
      character(1L)
    )
  )
}

#' Factory: a single-row chunk whose text is shorter than 200 chars (the default).
make_short_chunk <- function() {
  tibble(origin = "short_source.md", text = "Short text under 200 chars.")
}

#' Factory: a chunk with NA origin and NA text.
make_na_chunk <- function() {
  tibble(origin = NA_character_, text = NA_character_)
}

# --- NULL input --------------------------------------------------------------

test_that("format_rag_citations returns placeholder tag when chunks is NULL", {
  result <- format_rag_citations(NULL)
  # Must be a Shiny tag (not NULL, not a list of tags)
  expect_s3_class(result, "shiny.tag")
  # The placeholder text must be present
  rendered <- as.character(result)
  expect_true(grepl("Ask a question", rendered, fixed = TRUE))
})

# --- Zero-row tibble ---------------------------------------------------------

test_that("format_rag_citations returns placeholder tag when chunks is a zero-row tibble", {
  empty <- make_mock_chunks(n = 0L)
  result <- format_rag_citations(empty)
  expect_s3_class(result, "shiny.tag")
  rendered <- as.character(result)
  expect_true(grepl("Ask a question", rendered, fixed = TRUE))
})

# --- Non-data-frame input ----------------------------------------------------

test_that("format_rag_citations returns placeholder for non-data-frame non-NULL input", {
  # A stray character vector / list must degrade to the placeholder, not throw
  # an opaque nrow() error.
  result <- format_rag_citations("not a data frame")
  expect_s3_class(result, "shiny.tag")
  expect_true(grepl("Ask a question", as.character(result), fixed = TRUE))
})

# --- Non-empty input: structure ----------------------------------------------

test_that("format_rag_citations returns an accordion (shiny.tag) for non-empty chunks", {
  result <- format_rag_citations(make_mock_chunks(n = 2L))
  # bslib::accordion() returns a shiny.tag
  expect_s3_class(result, "shiny.tag")
})

test_that("format_rag_citations renders one panel per chunk row", {
  # 3 rows -> 3 accordion panels. Count by checking each origin string appears.
  chunks <- make_mock_chunks(n = 3L)
  rendered <- as.character(format_rag_citations(chunks))
  # Each origin value must appear in the rendered HTML.
  for (i in seq_len(nrow(chunks))) {
    expect_true(
      grepl(chunks$origin[[i]], rendered, fixed = TRUE),
      info = paste("Origin", chunks$origin[[i]], "not found in rendered accordion")
    )
  }
})

# --- Truncation --------------------------------------------------------------

test_that("format_rag_citations truncates long text and appends ellipsis", {
  # text_length = 300 > default excerpt_chars = 200 -> should be truncated.
  chunks <- make_mock_chunks(n = 1L, text_length = 300L)
  rendered <- as.character(format_rag_citations(chunks, excerpt_chars = 200L))
  # The Unicode ellipsis character must appear (u+2026).
  expect_true(grepl("…", rendered, fixed = TRUE))
})

test_that("format_rag_citations does NOT append ellipsis when text is short", {
  result <- format_rag_citations(make_short_chunk(), excerpt_chars = 200L)
  rendered <- as.character(result)
  expect_false(grepl("…", rendered, fixed = TRUE))
})

test_that("format_rag_citations respects a custom excerpt_chars value", {
  # Text of exactly 50 chars; excerpt_chars = 20 -> must truncate.
  chunks <- tibble(origin = "src.md", text = paste(rep("x", 50L), collapse = ""))
  rendered <- as.character(format_rag_citations(chunks, excerpt_chars = 20L))
  expect_true(grepl("…", rendered, fixed = TRUE))
})

# --- origin in output --------------------------------------------------------

test_that("format_rag_citations includes the origin value in rendered HTML", {
  chunks <- tibble(origin = "my_special_source.md",
                   text   = "Some content here.")
  rendered <- as.character(format_rag_citations(chunks))
  expect_true(grepl("my_special_source.md", rendered, fixed = TRUE))
})

# --- NA handling -------------------------------------------------------------

test_that("format_rag_citations falls back to 'unknown source' for NA origin", {
  result <- format_rag_citations(make_na_chunk())
  rendered <- as.character(result)
  expect_true(grepl("unknown source", rendered, fixed = TRUE))
})

test_that("format_rag_citations renders empty string for NA text without crashing", {
  result <- format_rag_citations(make_na_chunk())
  # Must return a tag, not throw
  expect_s3_class(result, "shiny.tag")
})

# --- excerpt_chars validation ------------------------------------------------

test_that("format_rag_citations stops when excerpt_chars < 1", {
  expect_error(
    format_rag_citations(make_mock_chunks(n = 1L), excerpt_chars = 0L),
    "`excerpt_chars` must be a positive integer.",
    fixed = TRUE
  )
})

test_that("format_rag_citations stops when excerpt_chars is negative", {
  expect_error(
    format_rag_citations(make_mock_chunks(n = 1L), excerpt_chars = -5L),
    "`excerpt_chars` must be a positive integer.",
    fixed = TRUE
  )
})

# --- excerpt_chars coercion --------------------------------------------------

test_that("format_rag_citations coerces numeric excerpt_chars to integer without error", {
  # 200.0 (numeric) must be accepted and work identically to 200L (integer).
  expect_no_error(
    format_rag_citations(make_mock_chunks(n = 1L), excerpt_chars = 200.0)
  )
})

test_that("format_rag_citations coercion: numeric and integer excerpt_chars produce truncated output", {
  # bslib::accordion() generates auto-incremented element IDs on each call, so
  # two separate renders will differ in id attributes even with identical input.
  # Assert the observable content (truncation + ellipsis) rather than exact HTML equality.
  chunks <- make_mock_chunks(n = 1L, text_length = 300L)
  res_int <- as.character(format_rag_citations(chunks, excerpt_chars = 200L))
  res_num <- as.character(format_rag_citations(chunks, excerpt_chars = 200.0))
  # Both must truncate (ellipsis present) — that is what coercion correctness means here.
  expect_true(grepl("…", res_int, fixed = TRUE))
  expect_true(grepl("…", res_num, fixed = TRUE))
})

# =============================================================================
# B. mod_rag_chat_server() — testServer() degradation tests
# =============================================================================

# --- B.1 NULL-store degradation (store file absent) --------------------------
# Strategy: run testServer inside a temporary directory where shiny_kb.duckdb
# does NOT exist. ragnar_store_connect() will throw; with_error_handling()
# returns NULL; the server renders store_unavailable_ui and returns early.
# This is the critical "no closure-not-subsettable cascade" test (Rule 6.3).

test_that("mod_rag_chat_server returns without error when store file is absent", {
  # withr::with_dir sets the working directory for the duration of the block.
  # In a tempdir, "data/shiny_kb.duckdb" will not exist.
  withr::with_dir(tempdir(), {
    expect_no_error(
      testServer(mod_rag_chat_server, {
        # Just flush — the server should return early without wiring anything.
        session$flushReact()
      })
    )
  })
})

test_that("mod_rag_chat_server renders store_unavailable_ui when store is absent", {
  withr::with_dir(tempdir(), {
    testServer(mod_rag_chat_server, {
      session$flushReact()
      # output$store_unavailable_ui in testServer() returns list(html=, deps=).
      # The $html element is the rendered HTML character string.
      ui_output <- output$store_unavailable_ui
      expect_false(
        is.null(ui_output),
        info = "store_unavailable_ui should render a non-NULL value when store is absent"
      )
      # Extract the HTML element from the renderUI result.
      rendered <- as.character(ui_output$html)
      expect_true(
        grepl("Knowledge store not found", rendered, fixed = TRUE),
        info = paste("Expected 'Knowledge store not found' in rendered UI, got:", rendered)
      )
    })
  })
})

test_that("mod_rag_chat_server does not crash with 'closure is not subsettable' when store is absent", {
  # Belt-and-suspenders: confirm no downstream reactives were wired with a NULL store.
  # If citations_ui were wired with a broken store object, an internal reactive
  # would throw "object of type 'closure' is not subsettable" when flushed.
  # After the early-return guard the server exits before registering citations_ui,
  # so testServer() will throw "undefined output" if we try to READ it — we
  # must NOT access it. Instead we verify the server body flushes without any
  # error OTHER than an "undefined output" error, which signals the early return
  # succeeded (citations_ui simply was never wired).
  #
  # We rely on the first test (mod_rag_chat_server returns without error) to
  # confirm the server itself does not throw; here we verify the degradation
  # path by checking store_unavailable_ui is populated (the only registered
  # output after early return) and citations_ui is correctly absent.
  withr::with_dir(tempdir(), {
    testServer(mod_rag_chat_server, {
      session$flushReact()
      # store_unavailable_ui IS registered (before the early-return guard).
      expect_false(is.null(output$store_unavailable_ui))
      # citations_ui is NOT registered (registered after the guard).
      # Verify by catching the "not defined yet" error from testServer.
      citations_error <- tryCatch(
        output$citations_ui,
        error = function(e) conditionMessage(e)
      )
      expect_true(
        grepl("hasn't been defined", citations_error, fixed = TRUE),
        info = paste(
          "Expected 'hasn't been defined' error confirming early-return prevented",
          "citations_ui from being wired; got:", citations_error
        )
      )
    })
  })
})

# --- B.2 NULL-client degradation (API key absent, store present) -------------
# Gated: skip if the real store file does not exist, because connecting to it
# requires the file to be present. When the store IS present but the API key is
# unset, with_error_handling() around chat_anthropic() returns NULL and the
# server performs the same early-return guard used for the NULL-store case.
#
# NOTE: The Anthropic API key is the guard here, not Ollama. The client is
# constructed with ellmer::chat_anthropic() which reads ANTHROPIC_API_KEY.
# Ollama is only needed at *retrieve time* (after a query is submitted), so the
# server CAN fully initialise with the store present and the API key unset —
# the client creation simply fails and the server returns early.

test_that("mod_rag_chat_server returns without error when API key is absent but store exists", {
  skip_if(
    !file.exists(STORE_PATH),
    message = "shiny_kb.duckdb not found — skipping store-present/no-client test"
  )
  # Run from the app root so "data/shiny_kb.duckdb" resolves correctly.
  app_dir <- file.path("..", "..")
  withr::with_dir(app_dir, {
    withr::with_envvar(c(ANTHROPIC_API_KEY = ""), {
      expect_no_error(
        testServer(mod_rag_chat_server, {
          session$flushReact()
        })
      )
    })
  })
})
