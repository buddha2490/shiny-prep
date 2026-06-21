# global.R --------------------------------------------------------------------
#
# Runs once at startup, before the app launches. Loads packages, sources the
# helper files, and builds the shared synthetic datasets.
#
# This is a *reference / demo* app: its whole purpose is to exercise as many
# shinydashboard layout features as is sensible in one place — header dropdowns,
# a rich sidebar, value/info boxes, every box flavour, a tabBox, dynamic boxes
# and a dynamic sidebar menu. Read it as a catalogue, not a minimal app.

# --- Packages ----------------------------------------------------------------
library(shiny)
library(shinydashboard)   # the layout system this app demonstrates
library(dplyr)            # data shaping in the factories
library(tibble)           # tibble() in the factories
library(ggplot2)          # static chart on the Charts tab
library(plotly)           # interactive chart on the Charts tab
library(DT)               # data table on the Data tab

# --- Source helpers ----------------------------------------------------------
# Raw three-file app: we source R/ explicitly (no framework auto-loader).
source("R/fct_sample_data.R")
source("R/utils_charts.R")

# --- Build the shared datasets once ------------------------------------------
# Deterministic (fixed seeds inside the factories) so every session/test is
# identical. Built here, in global scope, so UI and server both see them.
ADSL        <- make_adsl(n = 60)
ENROLLMENT  <- make_enrollment(ADSL)
AE_BY_ARM   <- make_ae_by_arm(ADSL)

# --- Constants ---------------------------------------------------------------
# AdminLTE 2 palette reminders, kept as named constants so the choice of color
# names is documented at one place. shinydashboard uses AdminLTE color names
# ("aqua", "light-blue", "navy", ...) for valueBox/infoBox/taskItem `color=`
# and box `background=`; box `status=` uses Bootstrap statuses ("primary",
# "success", "info", "warning", "danger"). These are NOT Bootstrap-5/bs4Dash
# names — do not swap them.
APP_TITLE <- "shinydashboard Showcase"
