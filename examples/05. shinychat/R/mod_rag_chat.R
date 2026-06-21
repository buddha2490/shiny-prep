# =============================================================================
# mod_rag_chat.R — Tab 6: RAG Chat
# Created: 2026-06-20
# Purpose: Teaching reference for ragnar + ellmer + shinychat integration.
#   The module:
#     A. Connects read-only to the pre-built ragnar DuckDB store (shiny_kb.duckdb)
#     B. Creates a dedicated ellmer Chat client with a retrieval tool registered
#        via ragnar::ragnar_register_tool_retrieve()
#     C. Streams responses via chat_append() with promises
#     D. After each exchange, retrieves the top-5 nearest chunks and renders
#        them as a citable accordion below the chat window
#
# RUNTIME PREREQUISITE: Ollama must be running (http://localhost:11434) with the
# nomic-embed-text model pulled. ragnar embeds the QUERY at retrieve time via
# Ollama. If Ollama is not running, ragnar_retrieve() throws (caught as ERR-RAG-002).
#
# If the knowledge store is missing, the tab degrades cleanly: a visible message
# directs the user to run scripts/build_ragnar_store.R rather than cascading into
# a cryptic "closure is not subsettable" error (Testing Rule 6.3).
# =============================================================================


# --- Citation formatter helper -----------------------------------------------

#' Format retrieved ragnar chunks as a bslib accordion
#'
#' Converts the tibble returned by \code{ragnar::ragnar_retrieve()} into a
#' \code{bslib::accordion()} with one panel per chunk, titled by the source
#' file (\code{origin}) and showing a truncated text excerpt in the body.
#' Returns a placeholder paragraph when \code{chunks} is NULL or empty.
#'
#' Extracted as a named helper so the test developer can unit-test citation
#' rendering with a factory-made tibble without launching the full app.
#'
#' @param chunks A data frame / tibble with at least \code{origin} (character)
#'   and \code{text} (character) columns, as returned by
#'   \code{ragnar::ragnar_retrieve()}. May be NULL or zero-row.
#' @param excerpt_chars Integer. Maximum number of characters to show from each
#'   chunk's \code{text} field. Default 200.
#' @return A \code{shiny::tagList} containing either a
#'   \code{bslib::accordion()} or a placeholder paragraph.
#' @export
format_rag_citations <- function(chunks, excerpt_chars = 200L) {
  # --- Validate inputs --- [2026-06-20]
  # Accept NULL (no query yet) and zero-row tibbles (no results found) cleanly.
  if (!is.integer(excerpt_chars)) excerpt_chars <- as.integer(excerpt_chars)
  if (excerpt_chars < 1L) stop("`excerpt_chars` must be a positive integer.", call. = FALSE)

  # --- Empty / null state ---------------------------------------------------- [2026-06-20]
  # Shown before the first question and when retrieval returns nothing. The
  # is.data.frame() guard also turns an accidental non-data-frame argument into
  # the placeholder rather than an opaque nrow() error.
  if (is.null(chunks) || !is.data.frame(chunks) || nrow(chunks) == 0L) {
    return(
      tags$p(
        class = "text-muted small fst-italic mt-1",
        "Ask a question to see retrieved sources."
      )
    )
  }

  # --- Build one accordion panel per chunk ----------------------------------- [2026-06-20]
  # Each panel is titled with the source filename (origin) so the reader can
  # immediately see which documentation file the model drew from. The body
  # shows a truncated excerpt — enough to judge relevance without drowning the
  # sidebar. Ellipsis is added only when the text is actually truncated.
  panels <- lapply(seq_len(nrow(chunks)), function(i) {
    row     <- chunks[i, ]
    origin  <- if (is.na(row$origin) || row$origin == "") "unknown source" else row$origin
    txt     <- if (is.na(row$text) || row$text == "") "" else row$text

    excerpt <- if (nchar(txt) > excerpt_chars) {
      paste0(substr(txt, 1L, excerpt_chars), "…")   # … character
    } else {
      txt
    }

    bslib::accordion_panel(
      title = tags$span(
        bsicons::bs_icon("file-earmark-text", class = "me-1 text-muted"),
        tags$code(class = "small", origin)
      ),
      # value must be an explicit character string when title is a tag object.
      # bslib 0.9.0 cannot coerce a shiny.tag to character for the default
      # value = title path — pass origin directly.
      value = origin,
      tags$p(class = "small text-muted mb-0", excerpt)
    )
  })

  # Wrap panels in a closed accordion (open = FALSE) so they don't expand by
  # default and crowd the citations area on first render.
  do.call(
    bslib::accordion,
    c(
      list(open = FALSE, class = "mt-1"),
      panels
    )
  )
}


# --- Module UI ---------------------------------------------------------------

#' RAG Chat tab UI
#'
#' Layout: \code{bslib::layout_sidebar()} with a narrow sidebar holding a brief
#' explainer + New Conversation button, and a fill card containing the
#' \code{shinychat::chat_ui()}. A \code{bslib::accordion()} for retrieved
#' source citations is rendered below the chat card via \code{uiOutput()}.
#'
#' @param id Module namespace id.
#' @return A \code{bslib::nav_panel} UI object.
#' @export
mod_rag_chat_ui <- function(id) {
  ns <- NS(id)

  # --- Tab panel with sidebar layout --- [2026-06-20]
  # fill = TRUE so the chat card expands to use remaining viewport height.
  # The citations accordion sits below the layout and scrolls normally.
  bslib::nav_panel(
    title = tags$span(bsicons::bs_icon("database-check", class = "me-1"), "RAG Chat"),
    value = "RAG Chat",

    bslib::layout_sidebar(
      fill    = TRUE,
      sidebar = bslib::sidebar(
        title = "RAG Chat",
        width = 300,
        open  = "desktop",

        # --- Explainer card ------------------------------------------------- [2026-06-20]
        # Teaches the reader what this tab demonstrates without requiring a README.
        bslib::card(
          class = "bg-light border-0 mb-3",
          bslib::card_body(
            padding = "0.75rem",
            tags$p(
              class = "small mb-2",
              tags$strong("What this tab demonstrates:")
            ),
            tags$ul(
              class = "small ps-3 mb-2",
              tags$li(
                tags$strong("ragnar"), " — embedded DuckDB store (",
                tags$code("shiny_kb.duckdb"),
                "), BM25 keyword retrieval by default"
              ),
              tags$li(
                "Retrieval tool registered on the ellmer client via ",
                tags$code("ragnar_register_tool_retrieve()")
              ),
              tags$li("Streaming responses via ", tags$code("chat_append()")),
              tags$li("Citations accordion updated after each exchange")
            ),
            tags$p(
              class = "small text-muted mb-0",
              tags$strong("Zero system dependencies"),
              " in the default BM25 mode — just R packages from ",
              tags$code("renv"), ". Semantic (vector) mode is optional and ",
              "requires an embedding provider; see ",
              tags$code("scripts/build_ragnar_store.R"), "."
            )
          )
        ),

        # --- Conversation control ------------------------------------------- [2026-06-20]
        actionButton(
          ns("new_chat"), "New Conversation",
          icon  = icon("plus"),
          class = "btn-outline-secondary w-100 mb-3"
        ),

        hr(class = "mt-0"),

        # --- Citation heading ----------------------------------------------- [2026-06-20]
        # Accordion lives in the sidebar below the controls so it doesn't
        # push the chat window down on narrow screens.
        tags$h6(
          class = "text-muted small text-uppercase mb-2",
          bsicons::bs_icon("journals", class = "me-1"),
          "Retrieved Sources"
        ),
        uiOutput(ns("citations_ui"))
      ),

      # --- Main: chat window ------------------------------------------------- [2026-06-20]
      # The fill card expands with the viewport. A degradation notice is shown
      # here (not just in the sidebar) when the store is unavailable, so the
      # blank chat area is never silent.
      bslib::card(
        fill = TRUE,
        bslib::card_header(
          bsicons::bs_icon("database-check", class = "me-1"),
          "RAG-grounded Chat",
          tags$span(
            class = "ms-auto small text-muted",
            "Sources: shinychat · ellmer · ragnar · bslib · shiny"
          )
        ),
        bslib::card_body(
          padding = 0,
          class   = "chat-card-body",
          # Degradation banner: rendered into the card body when the store is
          # unavailable. Otherwise the chat_ui() renders on top.
          uiOutput(ns("store_unavailable_ui")),
          shinychat::chat_ui(
            ns("rag_chat"),
            fill        = TRUE,
            height      = "100%",
            placeholder = "Ask about Shiny, shinychat, ellmer, ragnar, or bslib…",
            enable_cancel = TRUE
          )
        )
      )
    )
  )
}


# --- Module Server -----------------------------------------------------------

#' RAG Chat tab server
#'
#' Wires a ragnar DuckDB store to an ellmer streaming chat via the ragnar
#' retrieval tool. Key design points:
#'
#' \itemize{
#'   \item Store connection is guarded (Testing Rule 6.3): if the .duckdb file
#'     is absent, the tab degrades to a clean message rather than cascading into
#'     a broken-object error.
#'   \item A dedicated ellmer Chat client is created internally (not shared);
#'     the retrieval tool is registered once and the LLM calls it autonomously.
#'   \item After each stream settles, \code{ragnar_retrieve()} is called directly
#'     with the same query to populate the citations accordion.
#'   \item Ollama failures at retrieve time are caught as ERR-RAG-002 with
#'     \code{notify = FALSE} to avoid double-notification.
#' }
#'
#' @param id Module namespace id.
#' @return Invisibly NULL. Side effects only.
#' @export
mod_rag_chat_server <- function(id) {
  moduleServer(id, function(input, output, session) {

    # =========================================================================
    # SECTION A — Knowledge store connection                        [2026-06-20]
    # =========================================================================
    # The store path is relative to the app working directory (set by Shiny to
    # the app root at launch). open read_only so the build script can still
    # write to the same file in a development session without lock conflicts.
    # If the store is absent or corrupt, with_error_handling() returns NULL and
    # the tab renders a clean instructional message — no downstream reactives
    # are wired with a broken object (Testing Rule 6.3).
    store <- with_error_handling(
      ragnar::ragnar_store_connect(
        "data/shiny_kb.duckdb",
        read_only = TRUE
      ),
      code    = "ERR-RAG-001",
      context = list(module = "rag_chat"),
      session = session
    )

    # --- Connection lifecycle ------------------------------------------------ [2026-06-20]
    # Register an explicit disconnect on session end. DuckDB's R driver also
    # registers a C-level finalizer that closes the connection on GC, so for a
    # read_only store this is belt-and-suspenders — but a write-capable module
    # MUST do this to flush the WAL before GC has a chance to run, so the
    # reference shows the correct habit.
    if (!is.null(store)) {
      session$onSessionEnded(function() {
        tryCatch(
          DBI::dbDisconnect(store@con, shutdown = TRUE),
          error = function(e) NULL
        )
      })
    }

    # --- Degradation gate — store unavailable -------------------------------- [2026-06-20]
    # Show a clearly instructional message in the card body. Return early so no
    # downstream reactive is wired with a NULL store.
    store_available <- !is.null(store)

    output$store_unavailable_ui <- renderUI({
      if (store_available) return(NULL)

      # Prominent warning inside the chat area so the user cannot miss it.
      tags$div(
        class = "p-4",
        bslib::card(
          class = "border-warning",
          bslib::card_header(
            class = "bg-warning text-dark",
            bsicons::bs_icon("exclamation-triangle-fill", class = "me-1"),
            "Knowledge store not found"
          ),
          bslib::card_body(
            tags$p(
              "The RAG knowledge store (", tags$code("data/shiny_kb.duckdb"),
              ") could not be found or opened."
            ),
            tags$p("To build it, run the following from the repo root:"),
            tags$pre(
              class = "bg-light p-2 rounded small",
              paste0(
                'NOT_CRAN=true Rscript -e \'source("renv/activate.R")\' \\\n',
                '  "examples/05. shinychat/scripts/build_ragnar_store.R"'
              )
            ),
            tags$p(
              class = "text-muted small mb-0",
              "The default build needs no extra services — just the ",
              tags$code("renv"), " library. (Semantic mode, ",
              tags$code("RAG_RETRIEVAL_MODE=vss"),
              ", additionally needs an embedding provider such as Ollama.)"
            )
          )
        )
      )
    })

    # Guard: if the store is unavailable, stop wiring — no broken objects.
    if (!store_available) {
      log_event("WARN", "RAG store unavailable; rag_chat tab not wired",
                code = "ERR-RAG-001", module = "rag_chat")
      return(invisible(NULL))
    }

    # =========================================================================
    # SECTION B — Dedicated ellmer Chat client with retrieval tool  [2026-06-20]
    # =========================================================================
    # A DEDICATED client is used (not the shared AppState client) so:
    #   1. Conversation history stays scoped to this tab.
    #   2. The retrieval tool does not appear on other tabs.
    #   3. The system prompt can be RAG-specific.
    #
    # The system prompt instructs the model to ALWAYS call the retrieval tool
    # before answering R/Shiny questions, and to cite the sources used.
    # ragnar_register_tool_retrieve() wraps the DuckDB store as an ellmer tool
    # the model can invoke autonomously. Returns `chat` invisibly.
    client <- with_error_handling(
      {
        cl <- ellmer::chat_anthropic(
          model = "claude-sonnet-4-6",
          system_prompt = paste0(
            "You are a knowledgeable R and Shiny assistant backed by a curated ",
            "documentation knowledge base covering: Shiny, shinychat, ellmer, ",
            "ragnar, and bslib. ",
            "\n\n",
            "RETRIEVAL POLICY: Before answering any question about R, Shiny, or ",
            "these packages, you MUST call the retrieve tool to look up relevant ",
            "documentation. Do not answer from memory alone — always ground your ",
            "response in the retrieved chunks. ",
            "\n\n",
            "CITATION POLICY: After your answer, briefly list which source files ",
            "you retrieved from (e.g. 'Sources: shinychat.md, bslib.md'). ",
            "If the retrieved chunks do not contain enough information, say so ",
            "honestly and suggest what to look for. ",
            "\n\n",
            "TONE: Be concise and practical. Prefer working code examples. ",
            "Do not fabricate function signatures — use only what the retrieved ",
            "documentation supports."
          )
        )
        # Register ragnar retrieval as an ellmer tool. The LLM calls it
        # autonomously when it needs documentation context.
        ragnar::ragnar_register_tool_retrieve(
          cl,
          store,
          store_description = paste0(
            "Documentation for R Shiny, shinychat, ellmer, ragnar, and bslib. ",
            "Use it to look up function signatures, usage examples, and patterns."
          )
        )
        cl
      },
      code    = "ERR-LLM-001",
      context = list(module = "rag_chat"),
      session = session
    )

    # --- Guard: both store AND client must be non-NULL ----------------------- [2026-06-20]
    # req() short-circuits any downstream reactive that fires before these are ready.
    # If client creation failed, we log and bail — the tab shows the LLM error
    # notification already surfaced by with_error_handling() above.
    if (is.null(client)) {
      log_event("WARN", "RAG chat client unavailable; rag_chat tab not wired",
                code = "ERR-LLM-001", module = "rag_chat")
      return(invisible(NULL))
    }

    # =========================================================================
    # SECTION C — Reactive state                                    [2026-06-20]
    # =========================================================================

    # Holds the tibble of retrieved chunks from the LAST query, or NULL if no
    # query has been made yet / after a reset. The citations accordion reads this.
    retrieved_chunks <- reactiveVal(NULL)

    # Bumped after each stream settles (not at submit time) so the citations
    # accordion does not flash prematurely while the model is still generating.
    stream_settled <- reactiveVal(0L)

    # =========================================================================
    # SECTION D — Handle user input + stream                        [2026-06-20]
    # =========================================================================
    # The core streaming pattern (identical to mod_basic_chat / mod_advanced_ellmer):
    #   1. stream_async() launches the async generator (the LLM will call the
    #      retrieval tool internally before generating the answer).
    #   2. chat_append() pipes chunks token-by-token into the UI.
    #   3. promises::then() fires ONLY after the stream settles: at that point we
    #      call ragnar_retrieve() directly to populate the citations panel. We use
    #      the same query string captured at submit time (not input$rag_chat_user_input
    #      re-read, which may have been cleared by shinychat already).
    observeEvent(input$rag_chat_user_input, {
      req(input$rag_chat_user_input, !is.null(client), !is.null(store))

      # Capture query at submit time before shinychat clears the input field
      query <- input$rag_chat_user_input

      log_event("INFO", "RAG chat query received", module = "rag_chat")

      # --- Launch async stream ------------------------------------------------
      stream <- with_error_handling(
        client$stream_async(query),
        code    = "ERR-LLM-001",
        context = list(module = "rag_chat"),
        session = session
      )

      if (!is.null(stream)) {
        p <- shinychat::chat_append("rag_chat", stream, session = session)

        # --- After stream settles: retrieve citations ----------------------- [2026-06-20]
        # ragnar_retrieve() embeds the QUERY via Ollama and does cosine + BM25
        # retrieval from the DuckDB store. Wrapped because Ollama might be down.
        # notify = FALSE: the stream response already signals success to the user;
        # a silent citation failure (Ollama down mid-session) should not double-
        # notify — the citation panel simply stays in its prior state.
        promises::then(p, function(...) {
          chunks <- with_error_handling(
            ragnar::ragnar_retrieve(store, query, top_k = 5L),
            code    = "ERR-RAG-002",
            context = list(module = "rag_chat"),
            notify  = FALSE,
            session = session
          )

          # Update the citations reactiveVal (NULL on failure → placeholder shown)
          retrieved_chunks(chunks)

          # Log chunk count (NOT the query text — could contain sensitive info;
          # log codes/counts only per the no-PHI logging rule)
          chunk_count <- if (is.null(chunks)) 0L else nrow(chunks)
          log_event("INFO", "RAG retrieval complete",
                    module = "rag_chat", chunks_retrieved = chunk_count)

          # Bump stream_settled to refresh any dependents once the full turn is done
          stream_settled(stream_settled() + 1L)
        })
      }
    })

    # =========================================================================
    # SECTION E — Citations render                                  [2026-06-20]
    # =========================================================================
    # Delegates all formatting logic to format_rag_citations() — a named,
    # testable helper. The accordion collapses between questions so the sidebar
    # is not flooded with open panels.
    output$citations_ui <- renderUI({
      # Depend on stream_settled so the citations update only after the full
      # assistant turn is committed (not while chunks are still streaming).
      stream_settled()
      format_rag_citations(retrieved_chunks())
    })

    # =========================================================================
    # SECTION F — New Conversation button                           [2026-06-20]
    # =========================================================================
    # Clears the chat UI via shinychat::chat_clear(), resets the ellmer client's
    # turn history, and clears the citations accordion.
    observeEvent(input$new_chat, {
      shinychat::chat_clear("rag_chat", greeting = FALSE, session = session)
      client$set_turns(list())
      retrieved_chunks(NULL)
      log_event("INFO", "RAG chat conversation cleared", module = "rag_chat")
    })

  })
}
