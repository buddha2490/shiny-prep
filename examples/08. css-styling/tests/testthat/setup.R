# setup.R — runs once before the testthat tests in this directory.
#
# Loads the packages the modules/helpers need and sources them, matching how
# global.R wires them (testing rule 7). The AppDriver smoke test launches its
# own process and does not depend on this; the unit + testServer tests do.

suppressPackageStartupMessages({
  library(shiny)
  library(bslib)
  library(dplyr)
  library(tibble)
  library(htmltools)
})

R_DIR <- file.path("..", "..", "R")
source(file.path(R_DIR, "utils_style_helpers.R"))
source(file.path(R_DIR, "mod_computed_styles.R"))
source(file.path(R_DIR, "mod_metric_panel.R"))

# Factory for the subject data the computed-styles module consumes. A fresh
# copy per test (testing rule 3), seeded for determinism.
make_subjects <- function() {
  set.seed(42)
  tibble(
    subject    = sprintf("S-%03d", 1:8),
    arm        = sample(c("Placebo", "Low Dose", "High Dose"), 8, replace = TRUE),
    completion = sample(15:100, 8),
    lab_grade  = sample(0:4, 8, replace = TRUE)
  )
}
