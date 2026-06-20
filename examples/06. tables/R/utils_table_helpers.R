# utils_table_helpers.R -------------------------------------------------------
#
# Pure data-prep helpers shared by the table modules. Kept out of the modules so
# they can be unit-tested directly with testthat (testing rule 1). None of these
# touch Shiny reactivity — they take a data frame and return a data frame.

# --- Lab summary for the reactable tab ----------------------------------------

#' Summarise the long lab dataset to one row per parameter x arm.
#'
#' Produces the aggregates the reactable tab visualises: subject counts, baseline
#' and end-of-study means, mean change, an abnormal rate, and a per-visit mean
#' trend (a list-column) that feeds the inline sparkline.
#'
#' @param adlb long lab table from [make_adlb()]
#' @return tibble, one row per `PARAM` x `ARM`
summarise_labs <- function(adlb) {
  # Per-visit arm means drive the sparkline trend.
  visit_means <- adlb %>%
    dplyr::group_by(PARAMCD, PARAM, UNIT, ARM, AVISITN) %>%
    dplyr::summarise(mean_val = mean(AVAL, na.rm = TRUE), .groups = "drop") %>%
    dplyr::arrange(AVISITN) %>%
    dplyr::group_by(PARAMCD, PARAM, UNIT, ARM) %>%
    dplyr::summarise(trend = list(round(mean_val, 1)), .groups = "drop")

  adlb %>%
    dplyr::group_by(PARAMCD, PARAM, UNIT, ULN, ARM) %>%
    dplyr::summarise(
      n_subj    = dplyr::n_distinct(USUBJID),
      base_mean = mean(BASE[AVISIT == "Baseline"], na.rm = TRUE),
      end_mean  = mean(AVAL[AVISIT == "Week 12"], na.rm = TRUE),
      chg_mean  = mean(CHG[AVISIT == "Week 12"], na.rm = TRUE),
      pct_high  = mean(ANRIND != "NORMAL", na.rm = TRUE),
      .groups   = "drop"
    ) %>%
    dplyr::left_join(visit_means, by = c("PARAMCD", "PARAM", "UNIT", "ARM")) %>%
    dplyr::mutate(
      dplyr::across(c(base_mean, end_mean, chg_mean), ~ round(.x, 1))
    ) %>%
    dplyr::arrange(PARAMCD, ARM)
}

# --- "Table 1" baseline characteristics for the gt tab ------------------------

#' Build a publication-style baseline characteristics ("Table 1") data frame.
#'
#' Rows are characteristics/statistics; columns are the treatment arms plus a
#' Total column. A `group` column drives gt row-grouping; an `order` column keeps
#' the rows in display order after the per-arm pivot. Continuous variables report
#' `mean (SD)`; categorical variables report `n (%)`.
#'
#' @param adsl demographics table from [make_adsl()]
#' @return tibble ready to pipe into `gt()` with `groupname_col = "group"`
build_table1 <- function(adsl) {
  arms  <- levels(adsl$ARM)
  total <- adsl %>% dplyr::mutate(ARM = "Total")
  pooled <- dplyr::bind_rows(
    adsl %>% dplyr::mutate(ARM = as.character(ARM)),
    total
  )
  pooled$ARM <- factor(pooled$ARM, levels = c(arms, "Total"))

  # Header row: N per arm (used as a column-spanner subtitle in the module).
  n_row <- pooled %>%
    dplyr::count(ARM, name = "n") %>%
    dplyr::mutate(val = as.character(n), group = "Subjects",
                  label = "N", stat = "n", order = 0)

  # --- Continuous: mean (SD) --------------------------------------------------
  cont <- function(var, group, label, order, digits = 1) {
    pooled %>%
      dplyr::group_by(ARM) %>%
      dplyr::summarise(
        val = sprintf(
          paste0("%.", digits, "f (%.", digits, "f)"),
          mean(.data[[var]], na.rm = TRUE),
          stats::sd(.data[[var]], na.rm = TRUE)
        ),
        .groups = "drop"
      ) %>%
      dplyr::mutate(group = group, label = label, stat = "mean_sd", order = order)
  }

  # --- Categorical: n (%) per level ------------------------------------------
  catg <- function(var, group, order0) {
    # Preserve the source factor's level order (so age groups read
    # <45, 45-64, >=65 — not alphabetically). Falls back to sorted unique
    # values for plain character columns.
    src   <- pooled[[var]]
    levs  <- if (is.factor(src)) levels(src) else sort(unique(src))
    pooled %>%
      dplyr::count(ARM, level = factor(.data[[var]], levels = levs)) %>%
      dplyr::group_by(ARM) %>%
      dplyr::mutate(pct = 100 * n / sum(n)) %>%
      dplyr::ungroup() %>%
      dplyr::mutate(val = sprintf("%d (%.1f%%)", n, pct)) %>%
      dplyr::transmute(ARM, val, group = group, label = as.character(level),
                       stat = "n_pct",
                       order = order0 + as.integer(level))
  }

  long <- dplyr::bind_rows(
    n_row %>% dplyr::select(ARM, val, group, label, stat, order),
    cont("AGE",      "Age (years)",          "Mean (SD)",        10),
    cont("BMIBL",    "Baseline BMI (kg/m²)", "Mean (SD)",   20),
    cont("WEIGHTBL", "Baseline weight (kg)", "Mean (SD)",        30),
    catg("SEX",      "Sex, n (%)",           40),
    catg("AGEGR1",   "Age group, n (%)",     50),
    catg("REGION",   "Region, n (%)",        60)
  )

  # Pivot arms to columns, preserve display order, set group factor for gt.
  wide <- long %>%
    tidyr::pivot_wider(
      id_cols     = c(group, label, order),
      names_from  = ARM,
      values_from = val
    ) %>%
    dplyr::arrange(order)

  wide$group <- factor(wide$group, levels = unique(wide$group))
  wide %>% dplyr::select(-order)
}

# --- AE incidence summary for the gt tab --------------------------------------

#' Subject-incidence of adverse events by System Organ Class and arm.
#'
#' One row per SOC; for each arm a count of subjects with >= 1 event and the
#' percentage of that arm's subjects. Numeric `n_`/`pct_` columns are kept
#' separate (the gt module merges them into "n (%)" after colouring the rates).
#'
#' @param adae adverse-event listing from [make_adae()]
#' @param adsl demographics table from [make_adsl()] (supplies arm denominators)
#' @return tibble, one row per `AEBODSYS`, sorted by overall incidence
build_ae_summary <- function(adae, adsl) {
  # Short, syntactic arm codes keep the pivoted column names backtick-free.
  arm_code <- c(Placebo = "PBO", `Low Dose` = "LD", `High Dose` = "HD")
  denom <- adsl %>%
    dplyr::count(ARM, name = "N") %>%
    dplyr::mutate(ARMCD = arm_code[as.character(ARM)])

  inc <- adae %>%
    dplyr::distinct(AEBODSYS, ARM, USUBJID) %>%
    dplyr::count(AEBODSYS, ARM, name = "n") %>%
    dplyr::mutate(ARMCD = arm_code[as.character(ARM)]) %>%
    dplyr::left_join(denom[, c("ARMCD", "N")], by = "ARMCD") %>%
    dplyr::mutate(pct = n / N)

  wide <- inc %>%
    dplyr::select(AEBODSYS, ARMCD, n, pct) %>%
    tidyr::pivot_wider(
      id_cols     = AEBODSYS,
      names_from  = ARMCD,
      values_from = c(n, pct),
      values_fill = list(n = 0, pct = 0)
    )

  # Order SOC by total subject incidence (most frequent first).
  wide %>%
    dplyr::mutate(total_n = rowSums(dplyr::across(dplyr::starts_with("n_")))) %>%
    dplyr::arrange(dplyr::desc(total_n)) %>%
    dplyr::select(-total_n)
}
