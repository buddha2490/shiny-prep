# =============================================================================
# utils_plots.R — plotting + theme-color helpers shared across the app
# =============================================================================
# WHY this file exists:  the Theming tab lets the user switch Bootswatch presets
# and toggle dark mode at runtime. We want the ggplot to RECOLOR to match. The
# project rule set says do NOT add package deps, and `thematic` is not in the
# locked library, so instead of thematic_shiny() we read the current mode and
# build a matching ggplot theme by hand. These helpers centralize that logic so
# both server.R and tests can use them.
# =============================================================================

# --- Brand palette --- [2026-06-20]
# A small, fixed palette for the three treatment arms. Reused by every chart so
# arm colors are consistent across tabs (a real dashboard convention).
ARM_COLORS <- c(
  "Placebo"   = "#6c757d",  # Bootstrap secondary grey
  "Low Dose"  = "#0d6efd",  # Bootstrap primary blue
  "High Dose" = "#dc3545"   # Bootstrap danger red
)

# --- Severity palette --- [2026-06-20]
# Traffic-light scale for AE severity — green/amber/red is the universal clinical
# convention for mild/moderate/severe.
SEV_COLORS <- c(
  "Mild"     = "#2e7d32",
  "Moderate" = "#ed6c02",
  "Severe"   = "#c62828"
)

#' Build a ggplot2 theme that matches the app's current light/dark mode
#'
#' Returns a `theme()` object with background, text, and grid colors chosen for
#' either light or dark mode. This is the hand-rolled stand-in for
#' `thematic::thematic_shiny()` (which is not in the locked library): call it
#' inside a `renderPlot()` that depends on the dark-mode input so the plot
#' recolors whenever the user toggles mode.
#'
#' @param mode Character, `"light"` or `"dark"`. Anything other than `"dark"`
#'   is treated as light.
#'
#' @return A list of ggplot2 theme components to add to a plot.
#'
#' @examples
#' library(ggplot2)
#' ggplot(mtcars, aes(wt, mpg)) + geom_point() + mode_theme("dark")
#'
#' @export
mode_theme <- function(mode = "light") {
  # --- Validate input --- [2026-06-20]
  # Coerce defensively; a NULL input (mode not yet initialized) must not error,
  # it should fall back to light — this runs on first flush before input is set.
  if (is.null(mode) || !is.character(mode) || length(mode) != 1) {
    mode <- "light"
  }
  is_dark <- identical(mode, "dark")

  # --- Pick colors for the active mode --- [2026-06-20]
  # Dark mode uses a near-black panel with light text; light mode is the inverse.
  bg   <- if (is_dark) "#1a1d20" else "#ffffff"
  fg   <- if (is_dark) "#e9ecef" else "#212529"
  grid <- if (is_dark) "#343a40" else "#e9ecef"

  list(
    ggplot2::theme_minimal(base_size = 13),
    ggplot2::theme(
      plot.background  = ggplot2::element_rect(fill = bg, color = NA),
      panel.background = ggplot2::element_rect(fill = bg, color = NA),
      legend.background = ggplot2::element_rect(fill = bg, color = NA),
      legend.key       = ggplot2::element_rect(fill = bg, color = NA),
      text             = ggplot2::element_text(color = fg),
      axis.text        = ggplot2::element_text(color = fg),
      panel.grid.major = ggplot2::element_line(color = grid),
      panel.grid.minor = ggplot2::element_line(color = grid, linewidth = 0.25)
    )
  )
}

#' Enrollment-curve ggplot
#'
#' Cumulative enrollment over time, one line per treatment arm, themed for the
#' current light/dark mode.
#'
#' @param enrollment A data frame from `make_enrollment()` with columns
#'   `week` (Date), `cumulative` (numeric), and `ARM` (factor).
#' @param mode Character light/dark mode passed to `mode_theme()`.
#'
#' @return A ggplot object.
#' @export
plot_enrollment <- function(enrollment, mode = "light") {
  # --- Validate inputs --- [2026-06-20]
  if (!is.data.frame(enrollment)) {
    stop("`enrollment` must be a data frame.", call. = FALSE)
  }

  ggplot2::ggplot(
    enrollment,
    ggplot2::aes(x = week, y = cumulative, color = ARM)
  ) +
    ggplot2::geom_line(linewidth = 1.1) +
    ggplot2::geom_point(size = 2) +
    ggplot2::scale_color_manual(values = ARM_COLORS) +
    ggplot2::labs(
      x = "Enrollment week", y = "Cumulative subjects", color = "Arm"
    ) +
    mode_theme(mode)
}

#' AE-count bar chart
#'
#' Grouped bar chart of AE counts by severity within each arm, themed for the
#' current light/dark mode.
#'
#' @param ae_counts A data frame from `make_ae_counts()` with columns
#'   `ARM`, `SEVERITY`, `n_ae`.
#' @param mode Character light/dark mode passed to `mode_theme()`.
#'
#' @return A ggplot object.
#' @export
plot_ae_counts <- function(ae_counts, mode = "light") {
  # --- Validate inputs --- [2026-06-20]
  if (!is.data.frame(ae_counts)) {
    stop("`ae_counts` must be a data frame.", call. = FALSE)
  }

  ggplot2::ggplot(
    ae_counts,
    ggplot2::aes(x = ARM, y = n_ae, fill = SEVERITY)
  ) +
    ggplot2::geom_col(position = ggplot2::position_dodge(width = 0.8)) +
    ggplot2::scale_fill_manual(values = SEV_COLORS) +
    ggplot2::labs(x = NULL, y = "AE count", fill = "Severity") +
    mode_theme(mode)
}

#' Tiny sparkline plot for a value_box showcase
#'
#' A minimal, axis-free line plot used as the full-bleed `showcase` of a
#' `value_box()` with `showcase_layout = "bottom"`. The bslib docs note base-R
#' graphics work here but ggplot is cleaner; we strip all chrome so only the line
#' shows.
#'
#' @param y Numeric vector of values to spark.
#' @param color Line color (hex string).
#'
#' @return A ggplot object with no axes, labels, or background.
#' @export
sparkline_plot <- function(y, color = "#0d6efd") {
  # --- Validate input --- [2026-06-20]
  if (!is.numeric(y) || length(y) < 2) {
    stop("`y` must be a numeric vector of length >= 2.", call. = FALSE)
  }

  df <- data.frame(x = seq_along(y), y = y)

  ggplot2::ggplot(df, ggplot2::aes(x = x, y = y)) +
    ggplot2::geom_line(color = color, linewidth = 1) +
    ggplot2::geom_area(fill = color, alpha = 0.2) +
    # theme_void() + zero margins gives a true full-bleed spark with no chrome.
    ggplot2::theme_void() +
    ggplot2::theme(
      plot.margin = ggplot2::margin(0, 0, 0, 0),
      legend.position = "none"
    )
}
