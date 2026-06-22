# setup.R — runs once before the testthat tests in this directory.
#
# Sources the pure simulation engine the way global.R does (testing rule 7).
# The AppDriver smoke test launches its own process and does not depend on this;
# the unit tests do.

R_DIR <- file.path("..", "..", "R")
source(file.path(R_DIR, "sim_engine.R"))
