# =============================================================================
# global.R — Shiny Modules Reference App
# =============================================================================
# Purpose: Demonstrates all major Shiny module patterns in a pharma/clinical
#          context. This file runs once at startup before any session begins.
#
# Patterns covered across 6 tabs:
#   1. Basic module (NS + moduleServer)
#   2. Module communication (returning reactives)
#   3. Shared state with reactiveValues
#   4. Shared state with R6
#   5. Nested modules
#   6. Dynamic modules (insertUI / removeUI)
#
# Created: 2026-06-18
# =============================================================================

# --- Packages ----------------------------------------------------------------
# Load all packages here. Never use require() or library() in server.R.
library(shiny)
library(bslib)
library(DT)
library(dplyr)
library(R6)

# --- Source module files -----------------------------------------------------
# Each tab's module(s) are defined in a dedicated R/ file. Sourcing here makes
# all module functions available to both ui.R and server.R.

# Tab 1: Basic module
source("R/mod_demographics.R")

# Tab 2: Module communication via returned reactives
source("R/mod_filter.R")
source("R/mod_listing.R")

# Tab 3: Shared state with reactiveValues
source("R/mod_ae_filters.R")
source("R/mod_ae_table.R")
source("R/mod_ae_summary.R")

# Tab 4: Shared state with R6
source("R/R6_PatientStore.R")
source("R/mod_r6_selector.R")
source("R/mod_r6_details.R")

# Tab 5: Nested modules
source("R/mod_profile_header.R")
source("R/mod_profile_labs.R")
source("R/mod_profile_aes.R")
source("R/mod_patient_profile.R")

# Tab 6: Dynamic modules
source("R/mod_dynamic_card.R")
source("R/mod_dynamic_host.R")

# --- Synthetic clinical trial data -------------------------------------------
# All datasets are small and inline — no external CSV files required.
# Built with set.seed(42) for reproducibility.
# Data follows CDISC ADaM naming conventions (USUBJID, PARAMCD, etc.).

set.seed(42)

# Number of subjects
n_subjects <- 50

# --- ADSL: Subject-level dataset (one row per patient) -----------------------
# Covers: USUBJID, AGE, SEX, RACE, ARM, COUNTRY
adsl <- data.frame(
  USUBJID = sprintf("SUBJ-%03d", seq_len(n_subjects)),
  AGE     = sample(18:80, n_subjects, replace = TRUE),
  SEX     = sample(c("M", "F"), n_subjects, replace = TRUE, prob = c(0.55, 0.45)),
  RACE    = sample(
    c("WHITE", "BLACK OR AFRICAN AMERICAN", "ASIAN", "OTHER"),
    n_subjects,
    replace = TRUE,
    prob    = c(0.60, 0.15, 0.15, 0.10)
  ),
  ARM = sample(
    c("Placebo", "Drug A 10mg", "Drug A 20mg"),
    n_subjects,
    replace = TRUE
  ),
  COUNTRY = sample(
    c("USA", "GBR", "DEU", "FRA", "JPN"),
    n_subjects,
    replace = TRUE
  ),
  stringsAsFactors = FALSE
)

# --- ADAE: Adverse events dataset (multiple rows per patient) ----------------
# ~200 rows. Each row is one AE for one subject.
n_ae <- 200

adae <- data.frame(
  USUBJID  = sample(adsl$USUBJID, n_ae, replace = TRUE),
  AEDECOD  = sample(
    c("HEADACHE", "NAUSEA", "FATIGUE", "DIZZINESS", "RASH",
      "VOMITING", "DIARRHEA", "INSOMNIA", "BACK PAIN", "COUGH"),
    n_ae,
    replace = TRUE
  ),
  AESEV = sample(
    c("MILD", "MODERATE", "SEVERE"),
    n_ae,
    replace = TRUE,
    prob    = c(0.55, 0.35, 0.10)
  ),
  AESTDTC = format(
    as.Date("2024-01-01") + sample(0:364, n_ae, replace = TRUE),
    "%Y-%m-%d"
  ),
  AESER = sample(
    c("Y", "N"),
    n_ae,
    replace = TRUE,
    prob    = c(0.08, 0.92)
  ),
  stringsAsFactors = FALSE
)

# Join ARM from ADSL so modules can filter AEs by treatment arm
adae <- adae %>%
  left_join(adsl %>% select(USUBJID, ARM), by = "USUBJID")

# --- ADLB: Lab results dataset (multiple rows per patient per visit) ---------
# ~500 rows. Each row is one lab parameter at one visit for one subject.
n_lb <- 500

lab_params <- data.frame(
  PARAMCD = c("ALT", "AST", "BILI", "CREAT", "HGB", "WBC"),
  PARAM   = c(
    "Alanine Aminotransferase (U/L)",
    "Aspartate Aminotransferase (U/L)",
    "Bilirubin (mg/dL)",
    "Creatinine (mg/dL)",
    "Hemoglobin (g/dL)",
    "White Blood Cells (10^9/L)"
  ),
  stringsAsFactors = FALSE
)

# Baseline means and SDs per parameter (approximate normal ranges)
param_means <- c(ALT = 25, AST = 22, BILI = 0.7, CREAT = 0.9, HGB = 13.5, WBC = 6.5)
param_sds   <- c(ALT = 10, AST = 8,  BILI = 0.2, CREAT = 0.2, HGB = 1.5,  WBC = 1.5)

adlb_rows <- lapply(seq_len(n_lb), function(i) {
  subj   <- sample(adsl$USUBJID, 1)
  param  <- sample(lab_params$PARAMCD, 1)
  visit  <- sample(1:5, 1)
  base   <- round(rnorm(1, param_means[param], param_sds[param]), 2)
  change <- round(rnorm(1, 0, param_sds[param] * 0.3), 2)
  aval   <- round(base + change, 2)
  data.frame(
    USUBJID = subj,
    PARAMCD = param,
    PARAM   = lab_params$PARAM[lab_params$PARAMCD == param],
    VISITNUM = visit,
    VISIT   = paste0("Week ", (visit - 1) * 4),
    BASE    = base,
    AVAL    = aval,
    CHG     = change,
    stringsAsFactors = FALSE
  )
})

adlb <- do.call(rbind, adlb_rows)

# Clean up temporary objects — keep global namespace tidy
rm(adlb_rows, lab_params, param_means, param_sds, n_subjects, n_ae, n_lb)

# --- App constants -----------------------------------------------------------
APP_TITLE   <- "Shiny Modules Reference"
APP_VERSION <- "1.0.0"
