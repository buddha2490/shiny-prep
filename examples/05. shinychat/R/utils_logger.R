# =============================================================================
# utils_logger.R — Application logging (log4r)
# =============================================================================
# Provides ONE package-level logger reachable from anywhere via get_logger().
# Initialised once in global.R with init_logger(). Modules never create their
# own logger and never receive one as an argument — they call get_logger() (or,
# more usually, the log_event() helper below).
#
# Design:
#   * Single logger stored in a private environment (not the global env).
#   * Console appender for human reading; file appender for persistence and
#     machine parsing. Both use a structured, greppable message (see log_event).
#   * Threshold from the LOG_LEVEL env var (defaults to INFO), so the same code
#     runs verbose in dev and quiet in production with no edits.
#
# PHARMA RULE: never put PHI/PII in a log message — no USUBJID, subject names,
# dates of birth, or free-text terms tied to a subject. Log identifiers that are
# safe in plain text (error codes, incident ids, row counts, module names), not
# patient data. See rules/logging.md.
#
# log4r functions are called with the `log4r::` prefix throughout: `debug()`
# would otherwise mask `base::debug`, and explicit qualification keeps the one
# place that touches the logging backend unambiguous.
# =============================================================================

# Private store for the singleton logger. emptyenv() parent => no accidental
# inheritance from the global environment.
.logger_store <- new.env(parent = emptyenv())

#' Initialise the application logger
#'
#' Call once in `global.R`. A second call replaces the logger.
#'
#' @param app_name  Used for the log file name.
#' @param log_dir   Directory for the log file; created if missing.
#' @param threshold Minimum level to emit. Defaults to env var `LOG_LEVEL`,
#'   falling back to `"INFO"`.
#' @param to_file   Whether to also write to a file appender.
#' @return The logger object, invisibly.
init_logger <- function(app_name  = "shiny-app",
                        log_dir    = "logs",
                        threshold  = Sys.getenv("LOG_LEVEL", "INFO"),
                        to_file    = TRUE) {

  # Console appender — for humans tailing the running app.
  appenders <- list(
    log4r::console_appender(layout = log4r::default_log_layout())
  )

  # File appender — for persistence and log aggregation.
  if (isTRUE(to_file)) {
    dir.create(log_dir, showWarnings = FALSE, recursive = TRUE)
    log_file  <- file.path(log_dir, paste0(app_name, ".log"))
    appenders <- c(
      appenders,
      log4r::file_appender(log_file, layout = log4r::default_log_layout())
    )
  }

  lg <- log4r::logger(threshold = threshold, appenders = appenders)
  .logger_store$logger <- lg
  invisible(lg)
}

#' Retrieve the application logger
#'
#' Returns the logger created by `init_logger()`. If none exists yet (e.g. a
#' unit test that never called `init_logger()`), a default console logger is
#' created so that logging never itself throws.
#'
#' @return A log4r logger.
get_logger <- function() {
  if (is.null(.logger_store$logger)) {
    .logger_store$logger <- log4r::logger()
  }
  .logger_store$logger
}

#' Write one structured log line
#'
#' Routes through the single app logger and appends any extra named fields as
#' `key=value` pairs (logfmt style), so log lines stay greppable and parseable
#' by log aggregators.
#'
#' @param level One of "DEBUG", "INFO", "WARN", "ERROR", "FATAL".
#' @param msg   Human-readable message. NO PHI/PII.
#' @param ...   Additional named fields, e.g. `code = "ERR-DATA-001"`,
#'   `incident = "..."`, `module = "ae_table"`. Values are coerced to character.
#' @return The composed line, invisibly.
log_event <- function(level, msg, ...) {
  fields <- list(...)

  # Render extra fields as key=value, quoting values that contain whitespace.
  kv <- ""
  if (length(fields) > 0) {
    parts <- vapply(names(fields), function(nm) {
      val <- as.character(fields[[nm]])
      if (grepl("\\s", val)) val <- paste0("\"", val, "\"")
      paste0(nm, "=", val)
    }, character(1))
    kv <- paste0(" ", paste(parts, collapse = " "))
  }

  line   <- paste0(msg, kv)
  logger <- get_logger()

  # Dispatch to the matching log4r severity function.
  switch(
    toupper(level),
    DEBUG = log4r::debug(logger, line),
    INFO  = log4r::info(logger, line),
    WARN  = log4r::warn(logger, line),
    ERROR = log4r::error(logger, line),
    FATAL = log4r::fatal(logger, line),
    log4r::info(logger, line)  # unknown level => treat as INFO
  )
  invisible(line)
}
