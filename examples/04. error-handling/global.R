# =============================================================================
# global.R — Error Handling & Logging Reference App
# =============================================================================
# Purpose: the worked reference for logging + safe error handling in a
#          pharma/clinical Shiny app. Runs once at startup before any session.
#
# Patterns covered across 4 tabs:
#   1. Logging at each level (log4r via get_logger()/log_event())
#   2. Safe data load that never crashes the app (with_error_handling())
#   3. req() vs validate(need()) vs caught error
#   4. Error handling in async work (ExtendedTask + mirai)
#
# Created: 2026-06-18
# =============================================================================

# --- Packages ----------------------------------------------------------------
library(shiny)
library(bslib)
library(DT)
library(log4r)
library(mirai)

# --- Source helpers and modules ----------------------------------------------
source("R/utils_logger.R")   # init_logger(), get_logger(), log_event()
source("R/utils_error.R")    # with_error_handling(), error catalog, incident ids
source("R/mod_log_demo.R")
source("R/mod_safe_load.R")
source("R/mod_validation.R")
source("R/mod_async_task.R")

# --- Logging + error policy --------------------------------------------------
# One logger for the whole app. Threshold from LOG_LEVEL (DEBUG here so the
# demo shows every level); use INFO or WARN in production.
LOG_FILE <- file.path("logs", "error-handling-demo.log")
init_logger(app_name  = "error-handling-demo",
            log_dir   = "logs",
            threshold = Sys.getenv("LOG_LEVEL", "DEBUG"))

# In production NEVER leak internal error text to the browser. The user sees a
# generic message; the detail goes to the log via our handlers.
options(shiny.sanitize.errors = TRUE)

# Global safety net: anything that escapes a with_error_handling() wrapper and
# reaches Shiny's top level is logged as FATAL with an incident id, so nothing
# fails silently.
options(shiny.error = function() {
  log_event("FATAL", geterrmessage(),
            code = "ERR-APP-999", incident = new_incident_id())
})

# --- Background workers for the async demo -----------------------------------
mirai::daemons(2)
onStop(function() mirai::daemons(0))

log_event("INFO", "Application started", code = "APP-START")

# --- Sample data -------------------------------------------------------------
# Synthetic, non-identifiable subject-level data. Safe to display; still never
# logged at the row level.
set.seed(42)
adsl <- data.frame(
  USUBJID = sprintf("01-%03d", 1:50),
  AGE     = sample(18:85, 50, replace = TRUE),
  SEX     = sample(c("M", "F"), 50, replace = TRUE),
  ARM     = sample(c("Placebo", "Drug A", "Drug B"), 50, replace = TRUE),
  stringsAsFactors = FALSE
)
