# --- Packages ----------------------------------------------------------------
library(shiny)
library(bslib)
library(bsicons)
library(plotly)

# --- Source helpers ----------------------------------------------------------
source("R/sim_engine.R")
source("R/plot_arena.R")

# --- Simulation constants ----------------------------------------------------
# The box is a fixed [0, BOX_W] x [0, BOX_H] arena. The single exit ("door") is
# a gap on the right wall, centred vertically, whose height is user-controlled.
BOX_W <- 100
BOX_H <- 100

# Plot view extends past the box on the right so escaped points can be seen
# drifting away before they leave the frame entirely.
VIEW_X <- c(-5, 150)
VIEW_Y <- c(-5, 105)

# --- Palette -----------------------------------------------------------------
COL_TRAPPED <- "#2C3E50"  # dark slate — still bouncing inside the box
COL_ESCAPED <- "#18BC9C"  # teal — found the door and drifting out
COL_WALL    <- "#34495e"  # box walls
