# =============================================================================
# server.R — shinychat + ellmer Reference App
# Created: 2026-06-19
# Purpose: Main server function. Creates the shared AppState R6 object (which
#   holds the primary ellmer Chat client as a reactiveVal), wires all module
#   servers, and logs session lifecycle events.
# =============================================================================

server <- function(input, output, session) {

  # --- Session lifecycle logging --- [2026-06-19]
  # Bound to session$token so concurrent sessions stay distinguishable in logs.
  log_event("INFO", "Session started", token = session$token)

  # --- Surface preflight findings to the user --- [2026-06-19]
  # PREFLIGHT is computed once in global.R (missing packages/secrets + version
  # drift). Tell the user plainly instead of letting the environment crash the
  # app with a cryptic "object not found" deep in a dependency.
  if (length(PREFLIGHT) > 0) {
    blocking <- preflight_blocking(PREFLIGHT)
    showNotification(
      tagList(
        tags$strong(if (blocking) {
          "The app's environment is incomplete — it may not work."
        } else {
          "Environment warning — package versions don't match the lockfile."
        }),
        tags$ul(lapply(PREFLIGHT, function(p) tags$li(sub("^(ERROR|WARN): ", "", p)))),
        tags$small("Restore your library (e.g. ", tags$code("renv::restore()"),
                   ") and restart R.")
      ),
      type = if (blocking) "error" else "warning", duration = NULL
    )
  }
  onSessionEnded(function() {
    log_event("INFO", "Session ended", token = session$token)
  })

  # --- Shared application state --- [2026-06-19]
  # AppState holds the primary ellmer Chat client used by Basic Chat and
  # Control Panel. It MUST be instantiated inside the server function because
  # reactiveVal() requires an active reactive context.
  app_state <- with_error_handling(
    AppState$new(
      model         = "claude-sonnet-4-6",
      system_prompt = "You are a helpful AI assistant built with shinychat and ellmer in R Shiny."
    ),
    code    = "ERR-APP-999",
    context = list(action = "init_app_state"),
    session = session
  )

  # --- Fail fast and clean if the client could not be created --- [2026-06-19]
  # with_error_handling() returns NULL on failure. Wiring modules with a NULL
  # client cascades into cryptic errors deep inside shinychat/ellmer reactives
  # (e.g. "object of type 'closure' is not subsettable"). Instead, surface one
  # clear message and stop — the app stays up, the user knows what to fix.
  if (is.null(app_state)) {
    log_event("FATAL", "App state unavailable; modules not wired",
              code = "ERR-APP-999", incident = new_incident_id())
    showNotification(
      paste(
        "The LLM client could not be initialised. Check that ANTHROPIC_API_KEY",
        "is set and that the app is running against the renv library",
        "(renv::restore())."
      ),
      type = "error", duration = NULL
    )
    return(invisible(NULL))
  }

  # --- Module servers -------------------------------------------------------

  # Tab 1: Basic Chat
  # Passes a reactive that reads the current shared client so the tab
  # automatically uses whatever model/settings the Control Panel applied.
  mod_basic_chat_server(
    "basic_chat",
    client = reactive(app_state$client())
  )

  # Tab 2: Module Pattern
  # make_client is a zero-arg factory so mod_module_pattern can create a fresh
  # client internally and still respect Control Panel's current model selection.
  # Uses a dedicated client so Module Pattern conversation history stays
  # separate from the Basic Chat conversation.
  # isolate() is required because this factory is called synchronously in the
  # module server body (not inside reactive()/observe()), so the reactiveVal
  # read must be protected from the reactive graph scheduler.
  mod_module_pattern_server(
    "module_pattern",
    make_client = function() {
      ellmer::chat_anthropic(
        model         = shiny::isolate(app_state$client())$get_model(),
        system_prompt = shiny::isolate(app_state$client())$get_system_prompt()
      )
    }
  )

  # Tab 3: Markdown Stream
  # Gets its own fresh client per generate click (inside the module server),
  # but uses the shared client here as the source-of-truth for model/prompt.
  mod_markdown_stream_server(
    "markdown_stream",
    client = reactive(app_state$client())
  )

  # Tab 4: Advanced ellmer
  # Uses dedicated per-section clients internally; receives the shared client
  # only for the turn inspector token display of the main conversation.
  mod_advanced_ellmer_server(
    "advanced_ellmer",
    client = reactive(app_state$client())
  )

  # Tab 5: Control Panel
  # Receives the full app_state object so it can write new clients and
  # read/export the shared conversation history.
  mod_control_panel_server(
    "control_panel",
    app_state = app_state
  )

}
