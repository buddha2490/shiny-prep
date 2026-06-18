# .Rprofile — Project startup configuration
# This file runs automatically when R opens this project.

# --- renv --------------------------------------------------------------------
# Activate renv and warn if the lockfile is out of sync with the library.
# Run renv::snapshot() to record new packages, or renv::restore() to revert.

if (requireNamespace("renv", quietly = TRUE)) {
  renv::load()
  tryCatch(
    renv::status(dev = FALSE),
    error = function(e) message("renv status check failed: ", e$message)
  )
}
