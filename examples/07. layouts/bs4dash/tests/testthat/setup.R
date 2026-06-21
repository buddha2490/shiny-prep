# setup.R — runs once before the testthat tests in this directory.
#
# Loads the packages the helpers need and sources the data factories + theme
# builder, matching how global.R wires them (testing rule 7). The AppDriver
# smoke test launches its own process and does not depend on this; the unit
# tests (data factories) do.

suppressPackageStartupMessages({
  library(shiny)
  library(bs4Dash)
  library(fresh)
  library(dplyr)
  library(tibble)
})

R_DIR <- file.path("..", "..", "R")
source(file.path(R_DIR, "fct_sample_data.R"))
source(file.path(R_DIR, "utils_theme.R"))
