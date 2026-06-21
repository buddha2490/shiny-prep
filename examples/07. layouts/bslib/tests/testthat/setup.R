# setup.R — runs once before the testthat tests in this directory.
#
# Loads the packages the helpers need and sources the app's data factories +
# plotting utilities, matching how global.R wires them (testing rule 7). The
# AppDriver smoke test launches its own process and does not rely on this; the
# unit tests do.

suppressPackageStartupMessages({
  library(shiny)
  library(bslib)
  library(ggplot2)
  library(dplyr)
  library(tibble)
  library(tidyr)
})

R_DIR <- file.path("..", "..", "R")
source(file.path(R_DIR, "fct_sample_data.R"))
source(file.path(R_DIR, "utils_plots.R"))
