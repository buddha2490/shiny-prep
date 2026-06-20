# ui.R ------------------------------------------------------------------------
#
# A bslib page_navbar with one tab per table package, plus a short overview.
# Each tab's UI lives in its module's *_ui() function.

ui <- page_navbar(
  title = APP_TITLE,
  theme = bs_theme(version = 5, preset = "shiny", primary = "#1565c0"),
  fillable = TRUE,
  id = "nav",

  # --- Overview --------------------------------------------------------------
  nav_panel(
    title = "Overview",
    icon  = icon("circle-info"),
    layout_column_wrap(
      width = 1,
      card(
        card_header("R Table Packages — Feature Showcase"),
        card_body(
          markdown(
            "This reference app demonstrates four R table packages, each on its
             own tab, built on the same synthetic CDISC-style clinical data
             (120 subjects, three arms). Every tab turns on as many features as
             is sensible — the goal is to **show capability**, not to be a
             minimal listing.

  | Tab | Package | Best at | Showcased here |
  |-----|---------|---------|----------------|
  | **DT** | `DT` | Interactive listings | Editable cells, proxy updates, export buttons, conditional styling |
  | **reactable** | `reactable` | Rich interactive summaries | Grouping, sparklines, custom cell renderers, expandable details |
  | **gt** | `gt` | Publication / regulatory tables | Spanners, footnotes, summary rows, data colour, nanoplots |
  | **rhandsontable** | `rhandsontable` | Editable spreadsheets | Cell types, validation, save/reset, conditional formatting |

  All data is randomly generated under fixed seeds — **no real patient data**."
          )
        )
      ),
      layout_columns(
        col_widths = c(6, 6),
        value_box("Subjects", "120", showcase = icon("users"),
                  theme = "primary"),
        value_box("Treatment arms", "3", showcase = icon("flask"),
                  theme = "secondary")
      )
    )
  ),

  # --- One tab per package ---------------------------------------------------
  nav_panel("DT", icon = icon("table"),         mod_dt_table_ui("dt")),
  nav_panel("reactable", icon = icon("table-cells"),
            mod_reactable_table_ui("reactable")),
  nav_panel("gt", icon = icon("file-lines"),    mod_gt_table_ui("gt")),
  nav_panel("rhandsontable", icon = icon("table-list"),
            mod_rhandsontable_table_ui("rhot"))
)
