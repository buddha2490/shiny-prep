# utils_style_helpers.R -------------------------------------------------------
#
# Pure data-frame/value-in, htmltools-out helpers that build the *computed*
# styles for the computed-styles tab. These are the canonical Rule 2 case from
# the css-styling rule: a style that depends on R data (a bar width, a cell
# colour) and therefore cannot live in the static www/custom.css — it must be
# generated inline.
#
# They are deliberately plain functions (no Shiny, no reactivity) so they are
# unit-tested directly. Keeping the style logic out of the render function is
# what makes it testable — the module just calls these.

# --- Conditional colour (Rule 2 — data-driven colour) ------------------------

#' Map a CTCAE-style toxicity grade (0-4) to a semantic fill colour.
#'
#' Returns a CSS colour string. Grade 0 is the muted "no event" grey; 1-4 ramp
#' from success-green through to danger-red. The colours reference the app
#' palette CSS custom properties (defined on :root in www/custom.css, Rule 4)
#' rather than raw hex, so a palette change is still a one-file edit.
#'
#' @param grade integer-ish vector, each value in 0:4.
#' @return character vector of CSS colour values, same length as `grade`.
grade_fill <- function(grade) {
  # --- Validate inputs ---
  if (!is.numeric(grade)) {
    stop("`grade` must be numeric.", call. = FALSE)
  }
  if (any(!is.na(grade) & (grade < 0 | grade > 4))) {
    stop("`grade` values must be in the range 0-4.", call. = FALSE)
  }

  palette <- c(
    "0" = "var(--app-grade-0)",
    "1" = "var(--app-grade-1)",
    "2" = "var(--app-grade-2)",
    "3" = "var(--app-grade-3)",
    "4" = "var(--app-grade-4)"
  )
  unname(palette[as.character(grade)])
}

# --- Computed bar width (Rule 2 — data-driven dimension) ---------------------

#' Build an inline data-bound percent bar.
#'
#' The bar's WIDTH is computed from `pct` and the FILL from the data, so it is
#' generated inline (Rule 2) — there is no static class that could express a
#' per-row width. Everything else (track colour, height, rounding) is a reusable
#' treatment and lives as the `.pct-bar*` classes in www/custom.css (Rule 1):
#' inline carries only what genuinely varies with the data.
#'
#' @param pct   numeric 0-100; clamped into range.
#' @param fill  CSS colour for the filled portion.
#' @param label optional text overlaid on the bar (defaults to "NN%").
#' @return an htmltools `<div>` tag.
pct_bar <- function(pct, fill = "var(--app-accent)", label = NULL) {
  # --- Validate inputs ---
  if (!is.numeric(pct) || length(pct) != 1L) {
    stop("`pct` must be a single number.", call. = FALSE)
  }

  pct <- max(0, min(100, pct))                 # clamp to [0, 100]
  label <- label %||% sprintf("%.0f%%", pct)

  div(
    class = "pct-bar-track",
    # Only the two values that depend on data go inline; the rest is in CSS.
    div(
      class = "pct-bar-fill",
      style = css(width = paste0(pct, "%"), `background-color` = fill),
      span(class = "pct-bar-label", label)
    )
  )
}

`%||%` <- function(a, b) if (is.null(a)) b else a   # base since R 4.4; defined for safety
