# global.R --------------------------------------------------------------------
#
# Runs once at startup, before the app launches (shiny-app-structure rule:
# three-file layout, never app.R). Loads packages, sources helpers, builds the
# shared synthetic data, and constructs the fresh theme object.
#
# This is a REFERENCE / DEMO app: every tab deliberately turns on as many
# bs4Dash affordances as is sensible. The goal is to show capability, not to be
# a minimal production listing.

# --- Packages --- [2026-06-20]
# bs4Dash brings AdminLTE3 (Bootstrap 4); fresh themes it; waiter powers the
# preloader; DT/plotly/ggplot2 fill the boxes with real, rendered content.
library(shiny)
library(bs4Dash)
library(fresh)
library(waiter)
library(dplyr)
library(tibble)
library(DT)
library(plotly)
library(ggplot2)

# --- Source helpers --- [2026-06-20]
# R/ files hold the data factories and the theme builder so this file stays a
# thin manifest (shiny-app-structure rule).
source("R/fct_sample_data.R")
source("R/utils_theme.R")

# --- Build shared data once --- [2026-06-20]
# Deterministic (fixed seeds inside the factories), so every session and every
# test sees identical numbers behind the value boxes and charts.
ADSL       <- make_adsl()
ENROLLMENT <- make_enrollment(ADSL)
AE_COUNTS  <- make_ae_counts(ADSL)

# --- Constants --- [2026-06-20]
# The arm levels are reused by the Charts-tab filter; pulling them from the data
# keeps the control in sync if the factory changes.
ARM_LEVELS <- levels(ADSL$ARM)
APP_TITLE  <- "bs4Dash Showcase"

# --- Theme --- [2026-06-20]
# Built once here and passed to dashboardPage(freshTheme=) in ui.R. See
# utils_theme.R for the colour rationale.
DASH_THEME <- build_dashboard_theme()
