# =============================================================================
# utils_error.R — Safe error handling + error code catalog
# =============================================================================
# Every caught error is identified TWO ways:
#
#   * CATALOG CODE — stable, identifies the error TYPE (e.g. "ERR-DATA-001").
#                    Lives in the registry below alongside a SAFE user message.
#   * INCIDENT ID  — unique per occurrence (e.g. "20260618T141233-a3f9c1").
#                    Shown to the user AND written to the log, so a user's
#                    bug report ties back to one exact log line.
#
# The core helper is with_error_handling(): wrap any risky expression so a
# failure is (1) logged with its code + incident id, (2) optionally shown to the
# user as a dismissible notification, and (3) swallowed so the session keeps
# running — the wrapped expression returns `fallback` instead of crashing.
#
# See rules/error-handling.md for when to reach for this vs req()/validate().
# =============================================================================

# --- Error code catalog ------------------------------------------------------
# code -> list(user, severity).
#   user     : what the END USER sees. Free of internals and PHI.
#   severity : drives the log level for this error type.
#
# Code format: ERR-<DOMAIN>-<NNN>. Domains used here:
#   DATA   data load / validation        IO     file read / write / export
#   CALC   computation                   ASYNC  background (future/mirai) tasks
#   RENDER output rendering              APP    startup / config / catch-all
#   LLM    LLM API calls (shinychat/ellmer specific)
.error_catalog <- list(
  "ERR-DATA-001"   = list(user = "The data could not be loaded. Please contact support if this persists.", severity = "ERROR"),
  "ERR-DATA-002"   = list(user = "The selected dataset failed validation and was not loaded.",             severity = "ERROR"),
  "ERR-CALC-001"   = list(user = "A calculation could not be completed for the current selection.",        severity = "ERROR"),
  "ERR-RENDER-001" = list(user = "This output could not be displayed.",                                    severity = "ERROR"),
  "ERR-IO-001"     = list(user = "The file could not be exported.",                                        severity = "ERROR"),
  "ERR-ASYNC-001"  = list(user = "A background task failed. Please try again.",                            severity = "ERROR"),
  "ERR-LLM-001"    = list(user = "The LLM request failed. Please try again.",                              severity = "ERROR"),
  "ERR-LLM-002"    = list(user = "Structured output could not be parsed.",                                 severity = "ERROR"),
  "ERR-LLM-003"    = list(user = "Markdown stream failed to generate.",                                    severity = "ERROR"),
  "ERR-APP-999"    = list(user = "An unexpected error occurred. Please contact support.",                  severity = "FATAL"),
  "ERR-UNKNOWN-000"= list(user = "An unexpected error occurred.",                                          severity = "ERROR"),
  # --- RAG Chat (Tab 6) catalog codes --- [2026-06-20]
  # ERR-RAG-001: store file missing or unreadable — direct user to the build script.
  # ERR-RAG-002: retrieval failed at query time. In the default BM25 mode this
  #   points to a store/index problem; in semantic (vss) mode it most often
  #   means the embedding provider (e.g. Ollama) is unreachable.
  "ERR-RAG-001"    = list(user = "The knowledge store could not be loaded. Run scripts/build_ragnar_store.R to rebuild it.", severity = "ERROR"),
  "ERR-RAG-002"    = list(user = "Retrieval failed. If using semantic search mode, ensure the embedding provider is reachable; otherwise rebuild the store with scripts/build_ragnar_store.R.", severity = "ERROR")
)

#' Safe user-facing message for a catalog code (falls back to the generic one).
#' @param code Catalog code.
#' @return Character message safe to show end users.
error_user_message <- function(code) {
  entry <- .error_catalog[[code]]
  if (is.null(entry)) .error_catalog[["ERR-UNKNOWN-000"]]$user else entry$user
}

#' Log severity for a catalog code (defaults to "ERROR").
#' @param code Catalog code.
#' @return One of the log4r level names.
error_severity <- function(code) {
  entry <- .error_catalog[[code]]
  if (is.null(entry)) "ERROR" else entry$severity
}

#' Generate a unique incident id: `<UTC timestamp>-<6 hex chars>`.
#'
#' Unique enough to disambiguate occurrences within the same second, short
#' enough for a user to read back over the phone.
#' @return A character incident id.
new_incident_id <- function() {
  stamp <- format(Sys.time(), "%Y%m%dT%H%M%S", tz = "UTC")
  rand  <- paste(sample(c(0:9, letters[1:6]), 6, replace = TRUE), collapse = "")
  paste0(stamp, "-", rand)
}

#' Show a dismissible error notification referencing the incident id.
#'
#' The user sees the SAFE catalog message plus a reference string they can quote
#' in a support request. No internal error text is ever shown.
#' @param code     Catalog code.
#' @param incident Incident id from `new_incident_id()`.
#' @param session  Shiny session (defaults to the current reactive domain).
#' @return Invisibly NULL.
notify_error <- function(code, incident,
                         session = shiny::getDefaultReactiveDomain()) {
  if (is.null(session)) return(invisible(NULL))
  shiny::showNotification(
    ui = shiny::tagList(
      shiny::strong(error_user_message(code)),
      shiny::br(),
      shiny::tags$small(sprintf("Reference: %s (%s)", incident, code))
    ),
    type     = "error",
    duration = NULL,   # error stays until the user dismisses it
    session  = session
  )
  invisible(NULL)
}

#' Run an expression with safe error handling + logging
#'
#' Errors are logged (with `code` + a fresh incident id), optionally shown to
#' the user, then swallowed — `expr` returns `fallback` instead of crashing the
#' session. Warnings are logged and muffled (the log becomes the single source
#' of truth) so they don't also spam the console.
#'
#' `expr` is evaluated lazily inside the handler, so the risky code only runs
#' under protection.
#'
#' @param expr     Expression to evaluate.
#' @param code     Catalog code identifying this failure type.
#' @param context  Optional named list of SAFE context fields for the log, e.g.
#'   `list(module = "ae_table", n = nrow(x))`. NO PHI.
#' @param fallback Value returned if `expr` errors. Default `NULL`.
#' @param notify   Show a user notification on error? Default `TRUE`.
#' @param session  Shiny session for the notification.
#' @return The value of `expr`, or `fallback` on error.
with_error_handling <- function(expr,
                                code     = "ERR-UNKNOWN-000",
                                context  = NULL,
                                fallback = NULL,
                                notify   = TRUE,
                                session  = shiny::getDefaultReactiveDomain()) {
  withCallingHandlers(
    tryCatch(
      expr,
      error = function(e) {
        incident <- new_incident_id()
        # Log the REAL message (with safe context) at the catalog severity.
        do.call(log_event, c(
          list(level    = error_severity(code),
               msg      = conditionMessage(e),
               code     = code,
               incident = incident),
          context
        ))
        if (isTRUE(notify)) notify_error(code, incident, session)
        fallback
      }
    ),
    warning = function(w) {
      do.call(log_event, c(
        list(level = "WARN", msg = conditionMessage(w), code = code),
        context
      ))
      invokeRestart("muffleWarning")
    }
  )
}
