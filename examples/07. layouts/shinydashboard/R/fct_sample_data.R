# fct_sample_data.R -----------------------------------------------------------
#
# Synthetic, CDISC-flavoured demo data for the shinydashboard showcase app.
# Everything here is fabricated (no PHI) and deterministic via set.seed(), so
# every session and every test sees identical numbers. The frames are tiny on
# purpose — this is a LAYOUT reference, not a data app.

#' Build a small ADSL-like subject-level data frame
#'
#' Creates a fabricated subject-level analysis dataset (ADSL flavour) with the
#' handful of columns the dashboard's value boxes, charts and table read from.
#' Deterministic: a fixed seed means the same rows every call.
#'
#' @param n Integer. Number of subjects to generate. Default `60`.
#'
#' @return A tibble with columns `USUBJID`, `ARM`, `AGE`, `SEX`, `REGION`,
#'   `ENRLDT` (enrollment date, Date), and `SAFFL` (safety flag, "Y"/"N").
#'
#' @examples
#' make_adsl(10)
#'
#' @export
make_adsl <- function(n = 60) {
  # --- Validate inputs --- [2026-06-20]
  # Guard the one numeric argument so a bad call fails loud at the boundary
  # rather than producing a malformed frame the UI silently mis-renders.
  if (!is.numeric(n) || length(n) != 1 || n < 1) {
    stop("`n` must be a single positive number.", call. = FALSE)
  }

  # --- Generate the subject-level frame --- [2026-06-20]
  # Fixed seed = reproducible demo. Three treatment arms, two regions, a spread
  # of ages and a Jan–Jun enrollment window to drive the "enrollment over time"
  # chart. SAFFL is mostly "Y" to mimic a real safety population.
  set.seed(101)

  arms <- c("Placebo", "Low Dose", "High Dose")
  regions <- c("North America", "Europe", "Asia-Pacific")

  tibble::tibble(
    USUBJID = sprintf("DEMO-01-%03d", seq_len(n)),
    ARM     = factor(sample(arms, n, replace = TRUE), levels = arms),
    AGE     = round(stats::rnorm(n, mean = 54, sd = 12)),
    SEX     = factor(sample(c("F", "M"), n, replace = TRUE), levels = c("F", "M")),
    REGION  = factor(sample(regions, n, replace = TRUE), levels = regions),
    ENRLDT  = as.Date("2025-01-01") + sample(0:180, n, replace = TRUE),
    SAFFL   = sample(c("Y", "N"), n, replace = TRUE, prob = c(0.9, 0.1))
  )
}

#' Build an enrollment-over-time data frame from an ADSL frame
#'
#' Aggregates an ADSL frame into cumulative enrollment by week, used by the
#' line chart on the Charts tab.
#'
#' @param adsl A data frame as returned by [make_adsl()] (needs `ENRLDT`).
#'
#' @return A tibble with `WEEK` (Date, week-start) and `CUM_ENROLLED` (integer).
#'
#' @export
make_enrollment <- function(adsl) {
  # --- Validate inputs --- [2026-06-20]
  if (!is.data.frame(adsl) || !"ENRLDT" %in% names(adsl)) {
    stop("`adsl` must be a data frame containing an `ENRLDT` column.",
         call. = FALSE)
  }

  # --- Aggregate to a cumulative weekly enrollment curve --- [2026-06-20]
  # Floor each enrollment date to its week start, count per week, then take the
  # running total so the chart shows the familiar monotonic accrual curve.
  # Base-R week floor (no lubridate dep): cut() with breaks = "week" buckets each
  # date to the Monday-anchored week start, which we coerce back to Date.
  adsl %>%
    dplyr::mutate(
      WEEK = as.Date(cut(.data$ENRLDT, breaks = "week"))
    ) %>%
    dplyr::count(.data$WEEK, name = "N") %>%
    dplyr::arrange(.data$WEEK) %>%
    dplyr::mutate(CUM_ENROLLED = cumsum(.data$N)) %>%
    dplyr::select("WEEK", "CUM_ENROLLED")
}

#' Build an AE-count-by-arm data frame from an ADSL frame
#'
#' Fabricates a per-arm adverse-event count summary (one row per arm) used by
#' the bar chart and the dynamic value box. Counts scale with arm size so the
#' demo looks plausible.
#'
#' @param adsl A data frame as returned by [make_adsl()] (needs `ARM`).
#'
#' @return A tibble with `ARM` (factor), `N_SUBJ` (integer subjects in arm),
#'   and `N_AE` (integer fabricated AE count).
#'
#' @export
make_ae_by_arm <- function(adsl) {
  # --- Validate inputs --- [2026-06-20]
  if (!is.data.frame(adsl) || !"ARM" %in% names(adsl)) {
    stop("`adsl` must be a data frame containing an `ARM` column.",
         call. = FALSE)
  }

  # --- Fabricate AE counts per arm --- [2026-06-20]
  # Seeded again so AE counts are stable independent of how ADSL was built.
  # AE burden rises with dose to give the bar chart a readable gradient.
  set.seed(202)

  adsl %>%
    dplyr::count(.data$ARM, name = "N_SUBJ", .drop = FALSE) %>%
    dplyr::mutate(
      rate  = dplyr::case_when(
        .data$ARM == "Placebo"   ~ 0.8,
        .data$ARM == "Low Dose"  ~ 1.3,
        .data$ARM == "High Dose" ~ 2.1,
        TRUE                     ~ 1.0
      ),
      N_AE = as.integer(round(.data$N_SUBJ * .data$rate +
                                stats::runif(dplyr::n(), 0, 5)))
    ) %>%
    dplyr::select("ARM", "N_SUBJ", "N_AE")
}
