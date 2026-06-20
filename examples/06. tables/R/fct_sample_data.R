# fct_sample_data.R ------------------------------------------------------------
#
# Factory functions that build deterministic, synthetic CDISC-flavoured data for
# the table-showcase app. Nothing here is real patient data — every value is
# randomly generated under a fixed seed so the app (and its tests) are perfectly
# reproducible. These mirror the testing-rule factory pattern: each call returns
# a fresh copy, no shared mutable top-level objects.

# --- Constants ----------------------------------------------------------------

ARMS  <- c("Placebo", "Low Dose", "High Dose")
N_SUB <- 120L                       # 40 subjects per arm
STUDYID <- "ABC-101"

# --- Demographics (ADSL-like) -------------------------------------------------

#' Build a one-row-per-subject demographics table (ADSL shape).
#' @return tibble with subject-level baseline characteristics
make_adsl <- function() {
  set.seed(42)

  arm <- rep(ARMS, each = N_SUB / length(ARMS))
  # Dose-dependent age/BMI drift so the summary table shows real differences.
  arm_age_shift <- c(Placebo = 0, `Low Dose` = 2, `High Dose` = 4)[arm]

  tibble::tibble(
    STUDYID  = STUDYID,
    USUBJID  = sprintf("%s-%04d", STUDYID, seq_len(N_SUB)),
    SITEID   = sprintf("S%02d", sample(1:8, N_SUB, replace = TRUE)),
    ARM      = factor(arm, levels = ARMS),
    AGE      = round(stats::rnorm(N_SUB, 56 + arm_age_shift, 11)),
    SEX      = sample(c("F", "M"), N_SUB, replace = TRUE, prob = c(0.46, 0.54)),
    RACE     = sample(
      c("WHITE", "BLACK OR AFRICAN AMERICAN", "ASIAN",
        "AMERICAN INDIAN OR ALASKA NATIVE"),
      N_SUB, replace = TRUE, prob = c(0.62, 0.18, 0.15, 0.05)
    ),
    REGION   = sample(c("North America", "Europe", "Asia-Pacific"),
                      N_SUB, replace = TRUE, prob = c(0.45, 0.35, 0.20)),
    BMIBL    = round(stats::rnorm(N_SUB, 27 + arm_age_shift / 4, 4.5), 1),
    WEIGHTBL = round(stats::rnorm(N_SUB, 78, 14), 1),
    HEIGHTBL = round(stats::rnorm(N_SUB, 169, 9), 1),
    SAFFL    = "Y",
    ITTFL    = sample(c("Y", "N"), N_SUB, replace = TRUE, prob = c(0.95, 0.05)),
    DISCONFL = sample(c("Y", "N"), N_SUB, replace = TRUE, prob = c(0.18, 0.82))
  ) %>%
    dplyr::mutate(
      AGEGR1 = dplyr::case_when(
        AGE < 45            ~ "<45",
        AGE >= 45 & AGE < 65 ~ "45-64",
        TRUE                ~ ">=65"
      ),
      AGEGR1 = factor(AGEGR1, levels = c("<45", "45-64", ">=65"))
    )
}

# --- Adverse events (ADAE-like) -----------------------------------------------

# A small dictionary of System Organ Class -> Preferred Term so the AE listing
# looks like MedDRA-coded data without shipping the real dictionary.
.AE_DICT <- tibble::tribble(
  ~AEBODSYS,                                          ~AEDECOD,
  "Gastrointestinal disorders",                       "Nausea",
  "Gastrointestinal disorders",                       "Diarrhoea",
  "Gastrointestinal disorders",                       "Vomiting",
  "Nervous system disorders",                         "Headache",
  "Nervous system disorders",                         "Dizziness",
  "General disorders",                                "Fatigue",
  "General disorders",                                "Pyrexia",
  "Skin and subcutaneous tissue disorders",           "Rash",
  "Skin and subcutaneous tissue disorders",           "Pruritus",
  "Musculoskeletal and connective tissue disorders",  "Arthralgia",
  "Infections and infestations",                      "Nasopharyngitis",
  "Infections and infestations",                      "Upper respiratory tract infection"
)

#' Build a one-row-per-adverse-event listing (ADAE shape).
#' @param adsl demographics table from [make_adsl()] (for subject/arm linkage)
#' @return tibble of adverse-event records
make_adae <- function(adsl = make_adsl()) {
  set.seed(101)

  # ~70% of subjects have at least one AE; high dose carries more events.
  arm_rate <- c(Placebo = 1.4, `Low Dose` = 2.1, `High Dose` = 3.0)
  n_ae <- stats::rpois(nrow(adsl), arm_rate[as.character(adsl$ARM)])

  idx <- rep(seq_len(nrow(adsl)), times = n_ae)
  n   <- length(idx)
  dict_row <- sample(seq_len(nrow(.AE_DICT)), n, replace = TRUE)

  aestdy <- sample(1:84, n, replace = TRUE)
  tibble::tibble(
    STUDYID  = STUDYID,
    USUBJID  = adsl$USUBJID[idx],
    ARM      = adsl$ARM[idx],
    AEBODSYS = .AE_DICT$AEBODSYS[dict_row],
    AEDECOD  = .AE_DICT$AEDECOD[dict_row],
    AESEV    = factor(
      sample(c("MILD", "MODERATE", "SEVERE"), n, replace = TRUE,
             prob = c(0.55, 0.33, 0.12)),
      levels = c("MILD", "MODERATE", "SEVERE")
    ),
    AESER    = sample(c("N", "Y"), n, replace = TRUE, prob = c(0.88, 0.12)),
    AEREL    = sample(c("NOT RELATED", "POSSIBLY RELATED", "RELATED"),
                      n, replace = TRUE, prob = c(0.5, 0.32, 0.18)),
    AESTDY   = aestdy,
    AEDUR    = sample(1:21, n, replace = TRUE),
    AEOUT    = sample(c("RECOVERED", "RECOVERING", "NOT RECOVERED", "FATAL"),
                      n, replace = TRUE, prob = c(0.7, 0.18, 0.11, 0.01))
  ) %>%
    dplyr::mutate(AEENDY = AESTDY + AEDUR) %>%
    dplyr::arrange(USUBJID, AESTDY)
}

# --- Laboratory results (ADLB-like, long over visits) -------------------------

.LB_PARAMS <- tibble::tribble(
  ~PARAMCD, ~PARAM,                        ~UNIT,   ~MEAN, ~SD,  ~ULN,
  "ALT",    "Alanine Aminotransferase",    "U/L",   28,    12,   55,
  "AST",    "Aspartate Aminotransferase",  "U/L",   26,    10,   48,
  "CREAT",  "Creatinine",                  "umol/L", 78,   16,   106,
  "HGB",    "Hemoglobin",                  "g/dL",  14.2,  1.5,  17.5
)

.LB_VISITS <- tibble::tibble(
  AVISIT  = c("Baseline", "Week 2", "Week 4", "Week 8", "Week 12"),
  AVISITN = c(0, 2, 4, 8, 12)
)

#' Build a long lab dataset: one row per subject x parameter x visit (ADLB shape).
#' @param adsl demographics table from [make_adsl()]
#' @return tibble of longitudinal lab measurements with baseline + change
make_adlb <- function(adsl = make_adsl()) {
  set.seed(202)

  grid <- tidyr::expand_grid(
    adsl[, c("USUBJID", "ARM")],
    .LB_PARAMS,
    .LB_VISITS
  )

  # Dose-dependent on-treatment drift in liver enzymes (ALT/AST) for realism.
  arm_factor <- c(Placebo = 0, `Low Dose` = 0.04, `High Dose` = 0.10)
  grid %>%
    dplyr::group_by(USUBJID, PARAMCD) %>%
    dplyr::mutate(
      BASE  = round(stats::rnorm(1, MEAN[1], SD[1]), 1),
      # Scalar `if` (condition is constant within the subject x param group):
      # only liver enzymes drift on treatment, scaled by visit week.
      drift = if (PARAMCD[1] %in% c("ALT", "AST")) {
        arm_factor[as.character(ARM[1])] * AVISITN
      } else {
        0
      },
      AVAL  = round(BASE * (1 + drift) + stats::rnorm(dplyr::n(), 0, SD / 4), 1),
      AVAL  = dplyr::if_else(AVISIT == "Baseline", BASE, AVAL),
      CHG   = round(AVAL - BASE, 1),
      PCHG  = round(100 * CHG / BASE, 1)
    ) %>%
    dplyr::ungroup() %>%
    dplyr::mutate(
      # CTCAE-flavoured grade for hepatic labs vs ULN (illustrative only).
      ANRIND = dplyr::case_when(
        AVAL > 3 * ULN ~ "HIGH-3x",
        AVAL > ULN     ~ "HIGH",
        TRUE           ~ "NORMAL"
      ),
      AVISIT = factor(AVISIT, levels = .LB_VISITS$AVISIT)
    ) %>%
    dplyr::select(USUBJID, ARM, PARAMCD, PARAM, UNIT, ULN,
                  AVISIT, AVISITN, BASE, AVAL, CHG, PCHG, ANRIND)
}

# --- Data-management queries (editable grid source) ---------------------------

#' Build a small data-management query log for the editable rhandsontable demo.
#' @param adsl demographics table from [make_adsl()]
#' @return tibble of open/answered data queries
make_queries <- function(adsl = make_adsl()) {
  set.seed(303)
  n <- 25L
  subj <- sample(adsl$USUBJID, n)

  tibble::tibble(
    QUERYID  = sprintf("Q-%04d", seq_len(n)),
    USUBJID  = subj,
    DOMAIN   = sample(c("AE", "LB", "VS", "CM", "DM"), n, replace = TRUE),
    FIELD    = sample(c("Start Date", "Severity", "Result", "Dose", "Outcome"),
                      n, replace = TRUE),
    QUERYTXT = sample(
      c("Value out of expected range — please verify.",
        "Date precedes informed consent.",
        "Missing required value.",
        "Inconsistent with prior visit.",
        "Units do not match lab reference."),
      n, replace = TRUE
    ),
    PRIORITY = factor(sample(c("Low", "Medium", "High"), n, replace = TRUE,
                             prob = c(0.4, 0.4, 0.2)),
                      levels = c("Low", "Medium", "High")),
    STATUS   = factor(sample(c("Open", "Answered", "Closed"), n, replace = TRUE,
                             prob = c(0.5, 0.3, 0.2)),
                      levels = c("Open", "Answered", "Closed")),
    AGE_DAYS = sample(1:60, n, replace = TRUE),
    CONFIRM  = FALSE
  ) %>%
    dplyr::arrange(QUERYID)
}
