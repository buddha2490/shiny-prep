# Source the app's helper files so their functions are available to tests.
# Raw Shiny app (not a package), so we source rather than load_all().
library(testthat)
library(log4r)

app_root <- normalizePath(file.path("..", ".."))
source(file.path(app_root, "R", "utils_logger.R"))
source(file.path(app_root, "R", "utils_error.R"))
