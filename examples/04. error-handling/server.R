# =============================================================================
# server.R — Error Handling & Logging Reference App
# =============================================================================
server <- function(input, output, session) {

  # Log the lifecycle of every session. Useful in production for tying activity
  # to a window of log lines. session$token is a random id, not PHI.
  log_event("INFO", "Session started",
            code = "SESSION-START", session_token = session$token)
  session$onSessionEnded(function() {
    log_event("INFO", "Session ended",
              code = "SESSION-END", session_token = session$token)
  })

  # --- Module servers --------------------------------------------------------
  mod_log_demo_server("log_demo", log_file = LOG_FILE)
  mod_safe_load_server("safe_load", adsl = adsl)
  mod_validation_server("validation")
  mod_async_task_server("async_task")
}
