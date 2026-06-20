# mod_reactable_table.R -------------------------------------------------------
#
# reactable showcase: a laboratory results summary, one row per parameter x arm.
#
# Features demonstrated:
#   * groupBy a parameter with aggregated parent rows (sum / weighted display)
#   * custom cell renderers: colour-coded change with ▲/▼, an in-cell percent
#     bar built from htmltools tags, severity-style coloured text
#   * inline {sparkline} line charts embedded in cells from a list-column
#   * expandable row details — a nested reactable of the per-subject values
#   * column groups (colGroup), a sticky column, column footers (overall means)
#   * conditional rowStyle, a custom reactableTheme, JS row-select callback
#   * single-select wired back to Shiny via getReactableState()
#
# See .claude/skills/reactable-table/SKILL.md for the house pattern.

# --- Small htmltools cell-renderer helpers ------------------------------------

# A horizontal percent bar (0..1) rendered with nested divs.
.pct_bar <- function(p, fill = "#ef5350") {
  pct <- max(0, min(1, p))
  htmltools::div(
    style = "display:flex;align-items:center;gap:6px;",
    htmltools::div(
      style = "flex:1;background:#eceff1;border-radius:4px;height:14px;",
      htmltools::div(style = sprintf(
        "width:%.0f%%;background:%s;height:14px;border-radius:4px;",
        100 * pct, fill
      ))
    ),
    htmltools::span(style = "font-variant-numeric:tabular-nums;",
                    sprintf("%.0f%%", 100 * pct))
  )
}

# Mean change with direction arrow + colour (red = increase, green = decrease).
.chg_cell <- function(x) {
  if (is.na(x)) return("--")
  up   <- x > 0
  col  <- if (abs(x) < 0.05) "#607d8b" else if (up) "#c62828" else "#2e7d32"
  arr  <- if (abs(x) < 0.05) "■" else if (up) "▲" else "▼"
  htmltools::span(style = paste0("color:", col, ";font-weight:600;"),
                  sprintf("%s %+.1f", arr, x))
}

# --- UI -----------------------------------------------------------------------

mod_reactable_table_ui <- function(id) {
  ns <- NS(id)
  layout_sidebar(
    sidebar = sidebar(
      title = "Controls",
      width = 260,
      helpText(
        "Rows are grouped by lab parameter. Expand a row (▸) for the per-subject ",
        "detail table. Click a row to select it; the panel below reacts."
      ),
      input_switch(ns("group"), "Group by parameter", value = TRUE),
      actionButton(ns("expand"), "Expand all", icon = icon("angles-down"),
                   class = "btn-outline-secondary btn-sm"),
      actionButton(ns("collapse"), "Collapse all", icon = icon("angles-up"),
                   class = "btn-outline-secondary btn-sm")
    ),
    card(
      full_screen = TRUE,
      card_header("Laboratory Summary — mean by parameter and arm"),
      reactableOutput(ns("tbl"))
    ),
    uiOutput(ns("selected"))
  )
}

# --- Server -------------------------------------------------------------------

mod_reactable_table_server <- function(id, adlb) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    summary_df <- summarise_labs(adlb)

    output$tbl <- renderReactable({
      reactable(
        summary_df,
        groupBy     = if (isTRUE(input$group)) "PARAM" else NULL,
        searchable  = TRUE,
        filterable  = TRUE,
        striped     = TRUE,
        highlight   = TRUE,
        compact     = TRUE,
        bordered    = TRUE,
        defaultPageSize = 12,
        selection   = "single",
        onClick     = "select",
        # Row-select callback (JS) — purely cosmetic emphasis on the chosen row.
        rowStyle    = JS("function(rowInfo) {
          if (rowInfo && rowInfo.selected) {
            return { background: '#e3f2fd', fontWeight: 600 }
          }
        }"),
        columnGroups = list(
          colGroup(name = "On-treatment summary",
                   columns = c("base_mean", "end_mean", "chg_mean")),
          colGroup(name = "Abnormalities",
                   columns = c("pct_high", "trend"))
        ),
        columns = list(
          PARAMCD = colDef(show = FALSE),
          UNIT    = colDef(show = FALSE),
          ULN     = colDef(show = FALSE),
          PARAM   = colDef(name = "Parameter", minWidth = 160, sticky = "left"),
          ARM     = colDef(name = "Arm", minWidth = 110),
          n_subj  = colDef(
            name = "N", align = "center", maxWidth = 70,
            aggregate = "max",
            footer = function(values) sprintf("max %d", max(values))
          ),
          base_mean = colDef(
            name = "Baseline", align = "right", aggregate = "mean",
            format = colFormat(digits = 1),
            footer = function(values) sprintf("%.1f", mean(values))
          ),
          end_mean = colDef(
            name = "Week 12", align = "right", aggregate = "mean",
            format = colFormat(digits = 1),
            footer = function(values) sprintf("%.1f", mean(values))
          ),
          chg_mean = colDef(
            name = "Mean change", align = "right", html = TRUE,
            aggregate = JS("function(values) {
              var s = 0; values.forEach(function(v){ s += v });
              return s / values.length
            }"),
            cell = function(value) .chg_cell(value),
            # Aggregated parent cell also routed through the colourer.
            aggregated = JS("function(cellInfo) { return cellInfo.value.toFixed(1) }")
          ),
          pct_high = colDef(
            name = "% abnormal", minWidth = 140, html = TRUE,
            aggregate = "mean",
            cell = function(value) .pct_bar(value),
            aggregated = JS("function(cellInfo) {
              return (cellInfo.value * 100).toFixed(0) + '%'
            }")
          ),
          trend = colDef(
            name = "Trend (Baseline→Wk12)", minWidth = 160,
            # Inline sparkline from the numeric list-column.
            cell = function(value) {
              sparkline::sparkline(value, type = "line", width = 130,
                                   height = 28, lineColor = "#1565c0",
                                   fillColor = "#e3f2fd")
            }
          )
        ),
        details = function(index) {
          row  <- summary_df[index, ]
          subj <- adlb %>%
            dplyr::filter(PARAMCD == row$PARAMCD, ARM == row$ARM) %>%
            dplyr::select(USUBJID, AVISIT, BASE, AVAL, CHG, ANRIND) %>%
            dplyr::arrange(USUBJID, AVISIT)
          htmltools::div(
            style = "padding:12px;background:#fafafa;",
            htmltools::tags$b(sprintf("%s — %s: per-subject values",
                                      row$PARAM, row$ARM)),
            reactable(
              subj, compact = TRUE, bordered = TRUE, striped = TRUE,
              defaultPageSize = 5, outlined = TRUE,
              columns = list(
                ANRIND = colDef(
                  name = "Range", cell = function(v) {
                    col <- if (v == "NORMAL") "#2e7d32" else "#c62828"
                    htmltools::span(style = paste0("color:", col), v)
                  }
                )
              )
            )
          )
        },
        theme = reactableTheme(
          borderColor = "#dfe2e5",
          highlightColor = "#fff8e1",
          headerStyle = list(background = "#f5f5f5", fontWeight = 700),
          cellPadding = "8px 10px"
        )
      )
    })

    # --- Sidebar controls -> programmatic updates -----------------------------
    observeEvent(input$expand,   updateReactable("tbl", expanded = TRUE))
    observeEvent(input$collapse, updateReactable("tbl", expanded = FALSE))

    # --- Selection wired back into Shiny --------------------------------------
    output$selected <- renderUI({
      sel <- getReactableState("tbl", "selected")
      if (is.null(sel)) {
        return(card(card_body(class = "text-muted",
                              "Click a row to inspect it here.")))
      }
      row <- summary_df[sel, ]
      card(
        card_header(sprintf("%s — %s", row$PARAM, row$ARM)),
        card_body(
          sprintf(
            "N = %d · Baseline mean %.1f %s · Week 12 mean %.1f %s · change %+.1f · %.0f%% abnormal",
            row$n_subj, row$base_mean, row$UNIT, row$end_mean, row$UNIT,
            row$chg_mean, 100 * row$pct_high
          )
        )
      )
    })

    invisible(NULL)
  })
}
