# global.R --------------------------------------------------------------------
#
# Runs once at startup, before the app launches. Loads packages, sources the
# module + helper files, and builds the synthetic datasets the whole app shares.
#
# This is a *reference* app: each tab is a worked example of one table package
# with as many features turned on as is sensible — the goal is to demonstrate
# capability, not to be a minimal production listing.

library(shiny)
library(bslib)
library(dplyr)
library(tibble)
library(tidyr)

# Table packages — one tab each.
library(DT)
library(reactable)
library(gt)
library(rhandsontable)
library(htmltools)         # tag helpers used by reactable cell renderers
library(sparkline)         # inline sparkline trends inside reactable cells
library(htmlwidgets)       # JS() for reactable callbacks

# --- Source helpers + modules -------------------------------------------------

source("R/fct_sample_data.R")
source("R/utils_table_helpers.R")
source("R/mod_dt_table.R")
source("R/mod_reactable_table.R")
source("R/mod_gt_table.R")
source("R/mod_rhandsontable_table.R")

# --- Build the shared datasets once -------------------------------------------
# Deterministic (fixed seeds inside the factories), so every session and every
# test sees identical data.

ADSL <- make_adsl()
ADAE <- make_adae(ADSL)
ADLB <- make_adlb(ADSL)

# --- App constants ------------------------------------------------------------

APP_TITLE <- "R Table Packages — Feature Showcase"

# A shared accent palette so the four tabs feel like one app.
SEV_COLORS <- c(MILD = "#2e7d32", MODERATE = "#ed6c02", SEVERE = "#c62828")
