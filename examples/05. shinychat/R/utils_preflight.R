# =============================================================================
# utils_preflight.R — portable startup health check
# Created: 2026-06-19
# Purpose: Catch the environment problems that break a Shiny app on SOMEONE
#   ELSE'S machine — before they turn into a cryptic mid-flight crash. Three
#   classes, in order of how often they bite:
#     1. a required PACKAGE is missing       -> app errors on first use
#     2. a required SECRET / env var is unset -> client/DB/API construction fails
#     3. a package VERSION drifts from the pin -> "object 'X' not found" deep in
#        a dependency (a symbol that exists in one version, not another)
#
# Design goals (this is a DROP-IN helper — copy it into any app):
#   * Zero hard dependencies. Uses only base R. The lockfile parse is best-effort
#     and works with renv OR jsonlite OR neither (then version drift is skipped).
#   * Makes NO assumption about the deployment environment — renv, packrat,
#     Docker, Posit Connect, a bare library(), all fine. Whatever it cannot
#     check, it skips silently rather than failing.
#   * NEVER throws. Preflight must never be the thing that breaks startup.
#   * Returns plain data; the CALLER decides how to surface it (message, warning,
#     log, Shiny notification). That keeps it usable before a logger exists.
# =============================================================================

#' Run startup preflight checks
#'
#' @param packages       Character vector of packages the app needs installed.
#' @param env_vars       Character vector of environment variables / secrets the
#'   app needs set (non-empty).
#' @param check_versions Logical. If TRUE and a lockfile can be found and parsed,
#'   compare installed package versions against it. Skipped silently otherwise.
#' @param lockfile_name  Name of the lockfile to look for (default `"renv.lock"`).
#' @return Character vector of problems, each prefixed `"ERROR: "` (the app will
#'   likely not work) or `"WARN: "` (it may work but the environment is suspect).
#'   Empty vector means a clean bill of health.
#' @export
preflight <- function(packages       = character(0),
                      env_vars       = character(0),
                      check_versions = TRUE,
                      lockfile_name  = "renv.lock") {
  problems <- character(0)

  # The whole body is guarded: a preflight that crashes is worse than no
  # preflight, because it would take down the app it was meant to protect.
  tryCatch({

    # --- 1. Required packages installed ------------------------------------
    for (pkg in packages) {
      if (!requireNamespace(pkg, quietly = TRUE)) {
        problems <- c(problems, sprintf(
          "ERROR: required package '%s' is not installed", pkg))
      }
    }

    # --- 2. Required secrets / env vars present ----------------------------
    for (v in env_vars) {
      if (!nzchar(Sys.getenv(v))) {
        problems <- c(problems, sprintf(
          "ERROR: required environment variable '%s' is not set", v))
      }
    }

    # --- 3. Version drift vs a discoverable lockfile (best effort) ----------
    if (isTRUE(check_versions)) {
      expected <- discover_locked_versions(lockfile_name)
      for (pkg in intersect(packages, names(expected))) {
        if (!requireNamespace(pkg, quietly = TRUE)) next   # already an ERROR above
        want <- expected[[pkg]]
        if (is.na(want)) next
        have <- as.character(utils::packageVersion(pkg))
        if (!identical(have, want)) {
          problems <- c(problems, sprintf(
            paste0("WARN: package '%s' is %s but the lockfile pins %s ",
                   "(rebuild/restore your library to match)"),
            pkg, have, want))
        }
      }
    }

  }, error = function(e) {
    problems <<- c(problems,
                   paste("WARN: preflight check incomplete:", conditionMessage(e)))
  })

  problems
}

#' Are any preflight problems blocking (ERROR severity)?
#' @param problems Output of [preflight()].
#' @return Logical scalar.
#' @export
preflight_blocking <- function(problems) {
  any(startsWith(problems, "ERROR:"))
}

#' Discover locked package versions, if a lockfile is reachable
#'
#' Walks up from the working directory to find `lockfile_name`, then parses it
#' without requiring any one tool: prefers `renv`, falls back to `jsonlite`, and
#' if neither is available returns empty (version checking is simply skipped).
#'
#' @param lockfile_name File name to search for.
#' @return Named character vector (package -> version); empty if not found.
#' @keywords internal
discover_locked_versions <- function(lockfile_name = "renv.lock") {
  path <- find_file_upwards(lockfile_name)
  if (is.null(path)) return(character(0))

  lock <- NULL
  if (requireNamespace("renv", quietly = TRUE)) {
    lock <- tryCatch(renv::lockfile_read(path), error = function(e) NULL)
  }
  if (is.null(lock) && requireNamespace("jsonlite", quietly = TRUE)) {
    lock <- tryCatch(jsonlite::fromJSON(path, simplifyVector = FALSE),
                     error = function(e) NULL)
  }
  if (is.null(lock) || is.null(lock$Packages)) return(character(0))

  vapply(lock$Packages, function(p) {
    v <- p$Version
    if (is.null(v)) NA_character_ else as.character(v)
  }, character(1))
}

#' Find a file by walking up parent directories from a starting point
#' @keywords internal
find_file_upwards <- function(name, start = getwd(), max_up = 6L) {
  dir <- normalizePath(start, mustWork = FALSE)
  for (i in seq_len(max_up)) {
    candidate <- file.path(dir, name)
    if (file.exists(candidate)) return(candidate)
    parent <- dirname(dir)
    if (identical(parent, dir)) break   # reached filesystem root
    dir <- parent
  }
  NULL
}
