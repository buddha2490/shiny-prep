# setup.R — runs once before the testthat tests in this directory.
#
# Loads the packages the app helpers need and sources the factories + chart
# builders, matching how global.R wires them (testing rule 7). The AppDriver
# smoke test launches its own app process and does not depend on this; the unit
# tests below do.

suppressPackageStartupMessages({
  library(shiny)
  library(shinydashboard)
  library(dplyr)
  library(tibble)
  library(ggplot2)
  library(plotly)
})

R_DIR <- file.path("..", "..", "R")
source(file.path(R_DIR, "fct_sample_data.R"))
source(file.path(R_DIR, "utils_charts.R"))
