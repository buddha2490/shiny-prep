# =============================================================================
# global.R — shinychat + ellmer Reference App
# Created: 2026-06-19
# Purpose: Package loading, module sourcing, logging initialisation, and
#   global safety hooks. Runs ONCE at startup before any session starts.
#   No reactive code here.
# =============================================================================

# --- Preflight (runs BEFORE library() so missing pieces fail clean) ---------
# utils_preflight.R is base-R only, so it is safe to source and run before any
# package is attached. Checking packages/secrets here means a missing dependency
# or unset key produces a readable message instead of a raw library()/runtime
# error. REQUIRED_PACKAGES is also the single source of truth for what to load.
source("R/utils_preflight.R")

REQUIRED_PACKAGES <- c(
  "shiny", "bslib", "bsicons", "shinychat", "ellmer", "coro",
  "DT", "R6", "log4r", "promises", "scales",
  "ragnar", "duckdb", "dbplyr"   # Tab 6: ragnar RAG store backend
)

PREFLIGHT <- preflight(
  packages = REQUIRED_PACKAGES,
  env_vars = "ANTHROPIC_API_KEY"   # the app builds an LLM client at startup
)

# Emit immediately via base R — the logger isn't up yet. Blocking problems
# (missing package/secret) are loud; drift warnings are informational.
if (length(PREFLIGHT) > 0) {
  warning(paste(c("Startup preflight problems:", PREFLIGHT), collapse = "\n  "),
          call. = FALSE)
}

# --- Package loading --------------------------------------------------------
# Load in dependency order. Namespace conflicts:
#   DT::datatable masks nothing critical here.
#   Keep ellmer after shinychat so ellmer exports are available unqualified
#   where needed; use ellmer:: prefix in modules for clarity.
for (pkg in REQUIRED_PACKAGES) {
  suppressPackageStartupMessages(library(pkg, character.only = TRUE))
}

# --- Source helpers and modules ---------------------------------------------
# Order matters: utils must come before modules that reference them.
source("R/utils_logger.R")
source("R/utils_error.R")
source("R/app_state.R")
source("R/mod_basic_chat.R")
source("R/mod_module_pattern.R")
source("R/mod_markdown_stream.R")
source("R/mod_advanced_ellmer.R")
source("R/mod_control_panel.R")
source("R/mod_rag_chat.R")

# --- Initialise logger ------------------------------------------------------
# One logger for the whole app. Threshold from LOG_LEVEL env var (default INFO).
# Log file: logs/shinychat-app.log. Directory is gitignored.
init_logger(
  app_name  = "shinychat-app",
  log_dir   = "logs",
  threshold = Sys.getenv("LOG_LEVEL", "INFO")
)

log_event("INFO", "Application starting", version = "0.1.0")

# --- Re-log preflight findings now that the logger exists --------------------
# (They were already warned() to the console above; this records them in the
# log file at the right severity. server.R surfaces them to the user too.)
for (p in PREFLIGHT) {
  log_event(if (startsWith(p, "ERROR")) "ERROR" else "WARN", p, code = "ERR-APP-002")
}

# --- Global safety hooks ----------------------------------------------------
# shiny.sanitize.errors: strip stack internals from any error that leaks to
#   the browser unhandled — users never see file paths or R internals.
# shiny.error: FATAL safety net for any error that escapes every handler.
options(shiny.sanitize.errors = TRUE)
options(shiny.error = function() {
  log_event("FATAL", geterrmessage(),
            code = "ERR-APP-999", incident = new_incident_id())
})
