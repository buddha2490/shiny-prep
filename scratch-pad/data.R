# --- Simulate HCRU Baseline questionnaire dataset ----------------------------
# Mimics a clinical HCRU (Healthcare Resource Utilization) QS domain dataset.
# All columns are character, matching the source structure.

library(dplyr)
library(tibble)

set.seed(42)

n <- 50

# --- Helper functions --------------------------------------------------------

# Sample character counts with optional NA probability
sample_counts <- function(n, values = c("0", "1", "2", "3"), probs = NULL,
                          na_prob = 0) {
  x <- sample(values, n, replace = TRUE, prob = probs)
  if (na_prob > 0) {
    na_mask <- runif(n) < na_prob
    x[na_mask] <- NA_character_
  }
  x
}

sample_yes_no <- function(n, yes_prob = 0.7, na_prob = 0) {
  x <- sample(c("Yes", "No"), n, replace = TRUE, prob = c(yes_prob, 1 - yes_prob))
  if (na_prob > 0) {
    na_mask <- runif(n) < na_prob
    x[na_mask] <- NA_character_
  }
  x
}

# --- Build dataset -----------------------------------------------------------

hcru <- tibble(
  subjectId = sprintf("%06d", sample(350000:420000, n)),

  QSPERF = sample_yes_no(n, yes_prob = 0.95),

  QSREASND = {
    x <- rep(NA_character_, n)
    x[sample(n, 2)] <- "SUBJECT SF DUE TO COMPLIANCE"
    x
  },

  QSDAT = format(
    seq.Date(as.Date("2024-12-01"), as.Date("2025-06-30"), length.out = n),
    "%Y-%m-%dT00:00:00"
  ),

  # HRU101A: count 0-3, skewed toward 0

QSORRES_HRU101A = sample_counts(n, c("0", "1", "2", "3"),
                                  probs = c(0.5, 0.25, 0.15, 0.1)),

  # HRU101B: count 0-1, skewed toward 0
  QSORRES_HRU101B = sample_counts(n, c("0", "1"), probs = c(0.8, 0.2),
                                  na_prob = 0.1),

  # HRU102A: count 0-1, skewed toward 0
  QSORRES_HRU102A = sample_counts(n, c("0", "1"), probs = c(0.85, 0.15)),

  # HRU102B: decimal counts, mostly NA (conditional on HRU102A)
  QSORRES_HRU102B = ifelse(
    QSORRES_HRU102A == "1",
    sample(c("0.0", "1.0", "2.0"), sum(QSORRES_HRU102A == "1"), replace = TRUE),
    NA_character_
  ),

  # HRU102C: decimal counts, mostly NA (conditional on HRU102A)
  QSORRES_HRU102C = ifelse(
    QSORRES_HRU102A == "1",
    sample(c("1.0", "2.0", "3.0"), sum(QSORRES_HRU102A == "1"), replace = TRUE),
    NA_character_
  ),

  # HRU103A: count 0-3
  QSORRES_HRU103A = sample_counts(n, c("0", "1", "2", "3"),
                                  probs = c(0.2, 0.4, 0.25, 0.15)),

  # HRU103B1-B5: sub-counts, NA when HRU103A is "0"
  QSORRES_HRU103B1 = ifelse(
    QSORRES_HRU103A == "0", NA_character_,
    sample_counts(n, c("0", "1", "2"), probs = c(0.5, 0.3, 0.2))
  ),

  QSORRES_HRU103B2 = ifelse(
    QSORRES_HRU103A == "0", NA_character_,
    sample_counts(n, c("0", "1", "2", "3"), probs = c(0.5, 0.3, 0.1, 0.1))
  ),

  QSORRES_HRU103B3 = ifelse(
    QSORRES_HRU103A == "0", NA_character_,
    sample_counts(n, c("0", "1", "2", "3"), probs = c(0.3, 0.35, 0.2, 0.15))
  ),

  QSORRES_HRU103B4 = ifelse(
    QSORRES_HRU103A == "0", NA_character_,
    sample_counts(n, c("0", "1", "2", "3"), probs = c(0.3, 0.3, 0.25, 0.15))
  ),

  QSORRES_HRU103B5 = ifelse(
    QSORRES_HRU103A == "0", NA_character_,
    sample_counts(n, c("0"), probs = 1)
  ),

  # SUPPQS_OTHSP: all NA in the source
  SUPPQS_OTHSP = NA_character_,

  # HRU104A: count 1-3
  QSORRES_HRU104A = sample_counts(n, c("1", "2", "3"),
                                  probs = c(0.5, 0.35, 0.15)),

  # HRU105: Yes/No
  QSORRES_HRU105 = sample_yes_no(n, yes_prob = 0.85),

  # HRU106: Yes/No with some NA
  QSORRES_HRU106 = sample_yes_no(n, yes_prob = 0.85, na_prob = 0.05),

  # HRU107: numeric string (days/hours), wide range
  QSORRES_HRU107 = as.character(
    sample(c(2, 4, 6, 8, 10, 12, 14, 20, 24, 32, 40, 66),
           n, replace = TRUE)
  ),

  # HRU108: Yes/No, skewed toward No
  QSORRES_HRU108 = sample_yes_no(n, yes_prob = 0.15),

  # HRU109: numeric string, mostly NA (conditional on HRU108)
  QSORRES_HRU109 = ifelse(
    QSORRES_HRU108 == "Yes",
    as.character(sample(1:10, sum(QSORRES_HRU108 == "Yes"), replace = TRUE)),
    NA_character_
  ),

  # HRU110: Yes/No/Not Applicable
  QSORRES_HRU110 = sample(c("Yes", "No", "Not Applicable"), n,
                           replace = TRUE, prob = c(0.15, 0.7, 0.15)),

  # HRU111: No/Not Applicable
  QSORRES_HRU111 = sample(c("No", "Not Applicable"), n,
                           replace = TRUE, prob = c(0.6, 0.4)),

  # QSCAT: constant
  QSCAT = "HCRU Baseline"
)

# --- Verify ------------------------------------------------------------------
glimpse(hcru)
