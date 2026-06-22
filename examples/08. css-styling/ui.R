# ui.R ------------------------------------------------------------------------
#
# A bslib page_navbar. One tab per area of the css-styling rule. The single
# external stylesheet is linked in `header` (Rule 1 — external file by default,
# loaded with tags$link, never includeCSS()).

ui <- page_navbar(
  title = APP_TITLE,
  theme = APP_THEME,                 # built in global.R (Rule 8)
  id    = "nav",

  # Rule 1 — the ONE external stylesheet, linked (not inlined). Served from www/.
  header = tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "custom.css")
  ),

  # --- Overview --------------------------------------------------------------
  nav_panel(
    title = "Overview",
    icon  = bsicons::bs_icon("info-circle"),
    layout_column_wrap(
      width = 1,
      card(
        card_header("CSS Styling — Reference Showcase"),
        card_body(
          markdown(
            "Each tab is a worked example of one or more clauses of the
             **`css-styling`** project rule. This is a reference, not a usable
             app — the point is to show every place styling can live and which
             rule governs it.

  | Tab | Rule(s) | Demonstrates |
  |-----|---------|--------------|
  | **Theme** | 8 | App-wide colour/font/radius via `bs_theme()`; a Sass-var rule via `bs_add_rules()` |
  | **Utility classes** | 3 | Bootstrap 5 utilities (spacing, flex, text, colour, border) — reach here before writing CSS |
  | **Custom components** | 1, 4, 5, 7 | External `www/custom.css`, `:root` `--app-*` properties, section structure, one documented `!important` |
  | **Computed styles** | 2 | Data-driven inline styles — bar width + cell colour that *cannot* be static |
  | **Modules & namespacing** | 6 | CSS ID selectors must use the **fully-namespaced** id from the rendered HTML |

  See `.claude/rules/css-styling.md` for the rule itself, and this app's
  `www/custom.css` for the worked stylesheet."
          )
        )
      )
    )
  ),

  nav_panel("Theme", icon = bsicons::bs_icon("palette"), ui_theme_panel()),
  nav_panel("Utility classes", icon = bsicons::bs_icon("grid-3x3-gap"),
            ui_utilities_panel()),
  nav_panel("Custom components", icon = bsicons::bs_icon("box"),
            ui_components_panel()),
  nav_panel("Computed styles", icon = bsicons::bs_icon("bar-chart"),
            mod_computed_styles_ui("computed")),

  # --- Modules & namespacing (Rule 6) ----------------------------------------
  # Two instances of the SAME module; each headline number is targeted by a
  # fully-namespaced CSS rule in custom.css (#metric_enrolled-value, etc.).
  nav_panel(
    "Modules & namespacing",
    icon = bsicons::bs_icon("diagram-3"),
    layout_column_wrap(
      width = 1,
      card(
        card_header("CSS ID selectors must use the namespaced id"),
        card_body(
          p(class = "section-lead",
            "The two panels below are the same module instantiated twice. Each
             headline number is coloured by a CSS rule keyed to its
             fully-namespaced id — the bare R id would match nothing (Rule 6).")
        )
      ),
      layout_columns(
        col_widths = c(6, 6),
        mod_metric_panel_ui("metric_enrolled", "Enrolled", "people"),
        mod_metric_panel_ui("metric_completed", "Completed", "check2-circle")
      )
    )
  )
)
