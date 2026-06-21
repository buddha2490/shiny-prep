# utils_charts.R --------------------------------------------------------------
#
# Small, reusable chart builders kept out of server.R so the reactive code stays
# readable and the plotting logic is unit-testable on its own. Each function
# takes a plain data frame and returns a finished plot object; no reactivity
# lives here.

#' Build the cumulative-enrollment ggplot
#'
#' Static ggplot used inside a `box()` on the Charts tab. Separated from the
#' server so it can be tested with a controlled frame and reused if another tab
#' wants the same figure.
#'
#' @param enrollment A data frame as returned by [make_enrollment()] with
#'   `WEEK` (Date) and `CUM_ENROLLED` (numeric).
#'
#' @return A `ggplot` object.
#'
#' @export
plot_enrollment <- function(enrollment) {
  # --- Validate inputs --- [2026-06-20]
  req_cols <- c("WEEK", "CUM_ENROLLED")
  if (!is.data.frame(enrollment) || !all(req_cols %in% names(enrollment))) {
    stop("`enrollment` must have columns `WEEK` and `CUM_ENROLLED`.",
         call. = FALSE)
  }

  # --- Draw the accrual curve --- [2026-06-20]
  # An area + line + points combo reads as a familiar clinical accrual plot.
  # minimal theme keeps it clean inside the AdminLTE box chrome.
  ggplot2::ggplot(
    enrollment,
    ggplot2::aes(x = .data$WEEK, y = .data$CUM_ENROLLED)
  ) +
    ggplot2::geom_area(fill = "#3c8dbc", alpha = 0.25) +
    ggplot2::geom_line(color = "#3c8dbc", linewidth = 1) +
    ggplot2::geom_point(color = "#3c8dbc", size = 2) +
    ggplot2::labs(x = "Enrollment week", y = "Cumulative subjects") +
    ggplot2::theme_minimal(base_size = 13)
}

#' Build the AE-count-by-arm plotly bar chart
#'
#' Interactive plotly bar chart for the Charts tab. Returns a plotly object so
#' the demo shows a real interactive widget alongside the static ggplot.
#'
#' @param ae_by_arm A data frame as returned by [make_ae_by_arm()] with `ARM`
#'   and `N_AE`.
#'
#' @return A `plotly` htmlwidget.
#'
#' @export
plot_ae_by_arm <- function(ae_by_arm) {
  # --- Validate inputs --- [2026-06-20]
  req_cols <- c("ARM", "N_AE")
  if (!is.data.frame(ae_by_arm) || !all(req_cols %in% names(ae_by_arm))) {
    stop("`ae_by_arm` must have columns `ARM` and `N_AE`.", call. = FALSE)
  }

  # --- Draw the per-arm AE bar chart --- [2026-06-20]
  # Colour per arm; the AdminLTE-blue family keeps it on-theme. We pass the arm
  # as a factor so plotly preserves Placebo -> Low -> High ordering.
  plotly::plot_ly(
    data   = ae_by_arm,
    x      = ~ARM,
    y      = ~N_AE,
    color  = ~ARM,
    colors = c("#00c0ef", "#3c8dbc", "#605ca8"),
    type   = "bar"
  ) %>%
    plotly::layout(
      xaxis      = list(title = ""),
      yaxis      = list(title = "Adverse events"),
      showlegend = FALSE
    ) %>%
    plotly::config(displayModeBar = FALSE)
}
