# setup.R — runs once before the testthat tests in this directory.
#
# Loads the packages the modules need and sources the app's helpers + modules,
# matching how global.R wires them (testing rule 7). The AppDriver smoke test
# launches its own process and does not depend on this; the unit + testServer
# tests do.

suppressPackageStartupMessages({
  library(shiny)
  library(bslib)
  library(dplyr)
  library(tibble)
  library(tidyr)
  library(DT)
  library(reactable)
  library(gt)
  library(rhandsontable)
  library(htmltools)
  library(sparkline)
  library(htmlwidgets)
})

R_DIR <- file.path("..", "..", "R")
source(file.path(R_DIR, "fct_sample_data.R"))
source(file.path(R_DIR, "utils_table_helpers.R"))
source(file.path(R_DIR, "mod_dt_table.R"))
source(file.path(R_DIR, "mod_reactable_table.R"))
source(file.path(R_DIR, "mod_gt_table.R"))
source(file.path(R_DIR, "mod_rhandsontable_table.R"))

# Constants the modules reference that normally live in global.R.
SEV_COLORS <- c(MILD = "#2e7d32", MODERATE = "#ed6c02", SEVERE = "#c62828")
