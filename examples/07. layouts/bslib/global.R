# =============================================================================
# global.R — runs ONCE at startup, before the app launches (shiny-app-structure)
# =============================================================================
# Responsibilities (per the shiny-app-structure rule):
#   * library() every package the app uses — NO library() calls live elsewhere.
#   * source() the R/ helpers and data factories.
#   * build the static synthetic data once, into constants the UI/server reuse.
# No reactive code, no shinyApp() call, no data files on disk — all synthetic.
# =============================================================================

# --- Packages --- [2026-06-20]
# bslib drives every layout primitive in this showcase; bsicons supplies the
# value_box / tooltip icons; DT + plotly + ggplot2 give the tabs real, rendered
# content instead of placeholders. Loaded last-masks-first per the style rule;
# none of these conflict, so all calls stay unqualified.
library(shiny)
library(bslib)
library(bsicons)
library(DT)
library(plotly)
library(ggplot2)
library(dplyr)
library(tibble)
library(tidyr)

# --- Source helpers + factories --- [2026-06-20]
# R/ is sourced explicitly (raw three-file app — no auto-loader). Factories
# first, then the plotting/theme utilities that the server renders with.
source("R/fct_sample_data.R")
source("R/utils_plots.R")

# --- Build static demo data --- [2026-06-20]
# Built once here so every session shares the same immutable frames (they are
# never mutated, only displayed/plotted). Reproducible via the set.seed() inside
# each factory.
adsl        <- make_adsl()
enrollment  <- make_enrollment(adsl)
ae_counts   <- make_ae_counts()

# --- Bootswatch presets offered on the Theming tab --- [2026-06-20]
# A curated subset of bslib's bootswatch_themes() so the live theme switcher has
# a tidy dropdown. "default" maps to the plain Bootstrap 5 preset (no bootswatch).
BOOTSWATCH_PRESETS <- c(
  "Default (Bootstrap)" = "default",
  "Flatly"   = "flatly",
  "Cosmo"    = "cosmo",
  "Minty"    = "minty",
  "Lux"      = "lux",
  "Morph"    = "morph",
  "Sandstone" = "sandstone",
  "Darkly"   = "darkly"
)

# --- App-wide base theme --- [2026-06-20]
# The starting theme for the page_navbar shell. Demonstrates bs_theme() with a
# custom primary color, a Google base font, and a preset. The Theming tab swaps
# this live via session$setCurrentTheme().
app_theme <- bs_theme(
  version   = 5,
  preset    = "shiny",
  primary   = "#0d6efd",
  base_font = font_google("Inter"),
  heading_font = font_google("Inter")
)
