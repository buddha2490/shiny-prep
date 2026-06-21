# =============================================================================
# fct_sample_data.R — synthetic CDISC-flavored data factories
# =============================================================================
# WHY factories (not top-level objects):  testing rule 3 wants a FRESH copy per
# test so no test can mutate state another test relies on. The same factories
# back both the running app (called once in global.R) and the unit tests.
#
# All data here is tiny and entirely synthetic — there is NO PHI anywhere, so it
# is safe to display and (per the logging rule) nothing derived from it is ever
# logged. set.seed() makes every run reproducible.
# =============================================================================

# --- ADSL-like subject-level frame --- [2026-06-20]
# A minimal ADSL: one row per subject, the columns a safety reviewer expects
# (USUBJID, ARM, AGE, SEX, REGION) plus an enrollment date. Kept to ~60 rows so
# tables render instantly in a reference/demo context.
make_adsl <- function(n = 60) {
  set.seed(42)

  arms <- c("Placebo", "Low Dose", "High Dose")
  regions <- c("North America", "Europe", "Asia-Pacific")

  tibble::tibble(
    USUBJID  = sprintf("DEMO-01-%03d", seq_len(n)),
    ARM      = factor(sample(arms, n, replace = TRUE), levels = arms),
    AGE      = round(stats::rnorm(n, mean = 54, sd = 12)),
    SEX      = factor(sample(c("F", "M"), n, replace = TRUE), levels = c("F", "M")),
    REGION   = factor(sample(regions, n, replace = TRUE), levels = regions),
    # Enrollment spread across a ~6-month screening window.
    ENRLDT   = as.Date("2025-01-01") + sample(0:180, n, replace = TRUE)
  ) %>%
    # Keep AGE in a clinically plausible band so the demo plots look sensible.
    dplyr::mutate(AGE = pmin(pmax(AGE, 22L), 84L))
}

# --- Enrollment-over-time frame --- [2026-06-20]
# Cumulative enrollment per week per arm — the classic "enrollment curve" a
# trial dashboard shows. Derived from the ADSL so the two frames are consistent.
make_enrollment <- function(adsl = make_adsl()) {
  adsl %>%
    # Bucket each subject into the Monday of their enrollment week.
    dplyr::mutate(week = lubridate_floor_week(ENRLDT)) %>%
    dplyr::count(ARM, week, name = "n_enrolled") %>%
    dplyr::arrange(ARM, week) %>%
    dplyr::group_by(ARM) %>%
    # Cumulative sum gives the running enrollment total per arm.
    dplyr::mutate(cumulative = cumsum(n_enrolled)) %>%
    dplyr::ungroup()
}

# --- AE-count-by-arm frame --- [2026-06-20]
# A small adverse-event summary: count of AEs of each severity, per arm. Used by
# the bar chart and value boxes. Numbers are invented, not derived from real AEs.
make_ae_counts <- function() {
  set.seed(7)

  arms <- c("Placebo", "Low Dose", "High Dose")
  severities <- c("Mild", "Moderate", "Severe")

  tidyr::expand_grid(
    ARM      = factor(arms, levels = arms),
    SEVERITY = factor(severities, levels = severities)
  ) %>%
    dplyr::mutate(
      # Higher dose -> more AEs; higher severity -> fewer events. Purely cosmetic.
      base   = dplyr::case_when(
        ARM == "Placebo"   ~ 8L,
        ARM == "Low Dose"  ~ 14L,
        ARM == "High Dose" ~ 22L
      ),
      factor = dplyr::case_when(
        SEVERITY == "Mild"     ~ 1.0,
        SEVERITY == "Moderate" ~ 0.55,
        SEVERITY == "Severe"   ~ 0.25
      ),
      n_ae = round(base * factor) + sample(0:3, dplyr::n(), replace = TRUE)
    ) %>%
    dplyr::select(ARM, SEVERITY, n_ae)
}

# --- Week-floor helper --- [2026-06-20]
# Tiny base-R replacement for lubridate::floor_date(unit = "week") so the data
# factory has no extra package dependency. Returns the Monday on/before `x`.
lubridate_floor_week <- function(x) {
  # as.integer(format(x, "%u")) == ISO weekday (1 = Mon ... 7 = Sun).
  x - (as.integer(format(x, "%u")) - 1L)
}
