# fct_sample_data.R -----------------------------------------------------------
#
# Synthetic, CDISC-flavored sample data for the bs4Dash layout showcase.
# These are tiny demo frames — NOT real patient data, and nothing here is ever
# logged (no PHI). Each factory fixes its own seed so every session and every
# test sees identical data (testing rule 3: factories return a fresh copy).

#' Build a tiny ADSL-like subject-level tibble
#'
#' One row per synthetic subject. Mirrors the shape of an ADaM ADSL: a subject
#' id, treatment arm, demographics, region, and an enrollment date. Values are
#' invented — this is reference/demo data only.
#'
#' @param n Integer. Number of subjects to generate. Default `60`.
#'
#' @return A tibble with columns `USUBJID`, `ARM`, `AGE`, `SEX`, `REGION`,
#'   `ENROLL_DT` (Date).
#'
#' @examples
#' make_adsl(10)
#'
#' @export
make_adsl <- function(n = 60) {
  # --- Validate inputs --- [2026-06-20]
  # A single up-front check keeps the factory honest; the showcase always calls
  # it with the default, but a bad n would otherwise fail deep in sample().
  if (!is.numeric(n) || length(n) != 1 || n < 1) {
    stop("`n` must be a single positive number.", call. = FALSE)
  }

  # --- Deterministic generation --- [2026-06-20]
  # Fixed seed so the dashboard's value boxes / charts are stable across runs.
  set.seed(42)

  arms <- c("Placebo", "Low Dose", "High Dose")
  regions <- c("North America", "Europe", "Asia-Pacific")

  # Enrollment spread across ~18 months, built from a base date + day offsets.
  # Base R date math (no lubridate dependency) keeps the example lightweight.
  base_dt <- as.Date("2023-01-01")

  tibble::tibble(
    USUBJID   = sprintf("STUDY01-%03d", seq_len(n)),
    ARM       = factor(sample(arms, n, replace = TRUE), levels = arms),
    AGE       = as.integer(round(stats::rnorm(n, mean = 54, sd = 12))),
    SEX       = factor(sample(c("F", "M"), n, replace = TRUE)),
    REGION    = factor(sample(regions, n, replace = TRUE), levels = regions),
    ENROLL_DT = base_dt + sample(0:540, n, replace = TRUE)
  )
}

#' Summarise enrollment over time (cumulative)
#'
#' Collapses an ADSL-like frame to a monthly enrollment curve: how many
#' subjects had enrolled by the end of each calendar month. Drives the
#' "enrollment over time" line chart on the Charts tab.
#'
#' @param adsl A tibble from [make_adsl()] containing `ENROLL_DT` (Date).
#'
#' @return A tibble with `MONTH` (Date, first of month), `N` (monthly count),
#'   and `CUM_N` (cumulative count).
#'
#' @examples
#' make_enrollment(make_adsl(20))
#'
#' @export
make_enrollment <- function(adsl) {
  # --- Validate inputs --- [2026-06-20]
  if (!is.data.frame(adsl) || !"ENROLL_DT" %in% names(adsl)) {
    stop("`adsl` must be a data frame with an `ENROLL_DT` column.",
         call. = FALSE)
  }

  # --- Bucket enrollment dates to the first of their month --- [2026-06-20]
  # format(..., "%Y-%m-01") snaps each date to month start; counting then gives
  # a per-month enrollment, and cumsum() turns it into the recruitment curve.
  months <- as.Date(format(adsl$ENROLL_DT, "%Y-%m-01"))

  tibble::tibble(MONTH = months) %>%
    dplyr::count(MONTH, name = "N") %>%
    dplyr::arrange(.data$MONTH) %>%
    dplyr::mutate(CUM_N = cumsum(.data$N))
}

#' Summarise adverse-event counts by treatment arm and severity
#'
#' Produces a small synthetic AE-count frame keyed by arm and severity, for the
#' grouped bar chart and the data-table tab. Counts scale loosely with dose to
#' make the demo chart look plausible (not a real safety signal).
#'
#' @param adsl A tibble from [make_adsl()] containing `ARM` (factor).
#'
#' @return A tibble with `ARM` (factor), `SEVERITY` (factor:
#'   Mild/Moderate/Severe), and `N` (integer count).
#'
#' @examples
#' make_ae_counts(make_adsl(20))
#'
#' @export
make_ae_counts <- function(adsl) {
  # --- Validate inputs --- [2026-06-20]
  if (!is.data.frame(adsl) || !"ARM" %in% names(adsl)) {
    stop("`adsl` must be a data frame with an `ARM` column.", call. = FALSE)
  }

  set.seed(7)  # independent seed so AE counts don't track the ADSL draw

  arms <- levels(adsl$ARM)
  sev <- c("Mild", "Moderate", "Severe")

  # --- Cross arm x severity, then assign plausible counts --- [2026-06-20]
  # expand.grid gives every arm/severity cell; a dose multiplier + severity
  # taper (fewer severe than mild) shapes the synthetic counts.
  grid <- expand.grid(ARM = arms, SEVERITY = sev,
                      stringsAsFactors = FALSE)
  dose_mult <- c(Placebo = 1, `Low Dose` = 1.4, `High Dose` = 1.9)
  sev_taper <- c(Mild = 1, Moderate = 0.6, Severe = 0.3)

  grid$N <- as.integer(round(
    stats::rpois(nrow(grid), lambda = 18) *
      dose_mult[grid$ARM] * sev_taper[grid$SEVERITY]
  ))

  tibble::as_tibble(grid) %>%
    dplyr::mutate(
      ARM      = factor(.data$ARM, levels = arms),
      SEVERITY = factor(.data$SEVERITY, levels = sev)
    ) %>%
    dplyr::arrange(.data$ARM, .data$SEVERITY)
}
