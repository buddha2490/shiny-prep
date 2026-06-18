# .Rprofile — Project startup configuration
# This file runs automatically when R opens this project.

# --- renv --------------------------------------------------------------------
# renv is activated by the line below; activate.R sets the library paths and
# loads renv. We then warn if the library has drifted from renv.lock.
# Run renv::snapshot() to record new packages, or renv::restore() to revert.
source("renv/activate.R")

if (requireNamespace("renv", quietly = TRUE)) {
  tryCatch(
    renv::status(dev = FALSE),
    error = function(e) message("renv status check failed: ", e$message)
  )
}
