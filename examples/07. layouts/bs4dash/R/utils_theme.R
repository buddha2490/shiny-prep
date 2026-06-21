# utils_theme.R ---------------------------------------------------------------
#
# Builds the `fresh` theme object that re-skins bs4Dash (AdminLTE3). This is the
# bs4Dash-sanctioned way to theme: pass a `fresh::create_theme()` object to
# `dashboardPage(freshTheme = ...)`. The `skin`/`status` args of dashboardPage
# are deprecated in favour of this, so we drive all colour from here.
#
# WHY a separate helper: keeping the (verbose) theme construction out of
# global.R keeps that file scannable, and a named function is easy to unit-test
# / reuse. Returns a single object; no reactivity (theme is static at startup).

#' Build the fresh theme for the bs4Dash showcase
#'
#' Wires three `fresh` "bs4dash_*" variable setters into one theme object:
#' `bs4dash_status()` (the Bootstrap-4 status palette used by boxes / value
#' boxes / badges), `bs4dash_layout()` (sidebar width and main background), and
#' `bs4dash_sidebar_light()` (light-sidebar colours). Pass the result to
#' `dashboardPage(freshTheme = build_dashboard_theme())`.
#'
#' @return A `fresh` theme object (an htmltools dependency bundle) suitable for
#'   the `freshTheme` slot of [bs4Dash::dashboardPage()].
#'
#' @examples
#' \dontrun{
#' dashboardPage(freshTheme = build_dashboard_theme(), ...)
#' }
#'
#' @export
build_dashboard_theme <- function() {
  # --- Status palette --- [2026-06-20]
  # bs4Dash statuses are BOOTSTRAP 4 names (primary/secondary/info/success/
  # warning/danger) — there is no shinydashboard "aqua"/"light-blue" here.
  # Overriding `primary` etc. recolours every box(status=), valueBox(color=),
  # badge and ribbon that uses that status, giving the whole app a clinical
  # teal/indigo identity from one place.
  fresh::create_theme(
    fresh::bs4dash_status(
      primary   = "#2c7fb8",  # clinical blue — headers, primary boxes
      secondary = "#6c757d",
      info      = "#41b6c4",  # teal accent
      success   = "#31a354",
      warning   = "#fec44f",
      danger    = "#de2d26"
    ),
    # --- Layout --- [2026-06-20]
    # Slightly wider sidebar than default + a soft off-white body so the white
    # cards (boxes) lift off the page. main_bg is the body background.
    fresh::bs4dash_layout(
      main_bg     = "#f4f6f9",
      sidebar_width = "260px"
    ),
    # --- Light sidebar colours --- [2026-06-20]
    # The app starts in light mode (dashboardPage(dark = NULL)); these set the
    # light-sidebar background and the hover/active colours of menu items so the
    # active tab reads clearly against the clinical-blue brand.
    fresh::bs4dash_sidebar_light(
      bg            = "#ffffff",
      color         = "#2f3640",
      hover_color   = "#2c7fb8",
      active_color  = "#2c7fb8",
      submenu_bg    = "#ffffff",
      submenu_color = "#2f3640"
    )
  )
}
