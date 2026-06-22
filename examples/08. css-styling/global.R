# global.R --------------------------------------------------------------------
#
# Runs once at startup, before the app launches. Loads packages, builds the
# app theme (Rule 8 — theme-level changes belong in bs_theme(), not CSS),
# sources the modules + helpers, and makes the tiny synthetic dataset the
# computed-styles tab visualises.
#
# This is a *reference* app for the `css-styling` rule. Each tab is a worked
# example of one or more of that rule's eight clauses — the goal is to show
# every place styling can live and which clause governs it, not to be a
# usable application. The README maps each rule to the tab + file that
# demonstrates it.

library(shiny)
library(bslib)
library(dplyr)
library(tibble)
library(htmltools)

# --- Source helpers + modules -------------------------------------------------

source("R/utils_style_helpers.R")
source("R/ui_gallery.R")
source("R/mod_computed_styles.R")
source("R/mod_metric_panel.R")

# --- App theme (Rule 8 — bs_theme / bs_add_rules) -----------------------------
#
# App-wide colour, font, and border-radius decisions live HERE, in the theme,
# not in www/custom.css. www/custom.css is reserved for app-specific component
# styles that sit *on top of* this theme. `bs_add_rules()` is for a rule that
# needs a Bootstrap Sass variable ($font-size-lg) that no bs_theme() argument
# exposes.
#
# This theme is deliberately static. Live theme switching (bootswatch swap,
# dark-mode toggle via session$setCurrentTheme) is demonstrated in
# `examples/07. layouts/bslib`; we don't duplicate it here.

APP_THEME <- bs_theme(
  version      = 5,
  bootswatch   = "flatly",
  primary      = "#2C3E50",        # brand navy — flows to .btn-primary, navbar, links
  success      = "#18BC9C",        # flatly teal — reused as --app-accent in custom.css
  "border-radius" = "0.5rem",      # softer corners app-wide (one edit, every card)
  base_font    = font_google("Inter"),
  heading_font = font_google("Inter")
) %>%
  # A rule that needs a Sass variable bs_theme() has no argument for. Reserve
  # this for exactly that case — anything expressible as a bs_theme() arg should
  # be one.
  bs_add_rules(".section-lead { font-size: $font-size-lg; color: $gray-600; }")

# --- Synthetic data for the computed-styles tab (no real patients) ------------
# One row per subject: a completion percentage (drives a data-bound bar width)
# and a lab grade 0-4 (drives a conditional cell colour). Both are computed
# styles per Rule 2 — they depend on R data and cannot live in a static file.

set.seed(42)
SUBJECTS <- tibble(
  subject    = sprintf("S-%03d", 1:8),
  arm        = sample(c("Placebo", "Low Dose", "High Dose"), 8, replace = TRUE),
  completion = sample(15:100, 8),                 # % of planned visits done
  lab_grade  = sample(0:4, 8, replace = TRUE)     # CTCAE-style toxicity grade
)

# --- App constants ------------------------------------------------------------

APP_TITLE <- "CSS Styling — Reference Showcase"
