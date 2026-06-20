# mod_gt_table.R --------------------------------------------------------------
#
# gt showcase: two static, publication-quality clinical tables.
#
# Demo A — "Table 1" baseline characteristics:
#   row groups (groupname_col), a stub (rowname_col), a column spanner over the
#   treatment arms, per-row-group footnotes, a source note, targeted tab_style.
# Demo B — AE incidence by System Organ Class:
#   fmt_number / fmt_percent, data_color heat-scale on the rates, cols_merge to
#   "n (%)", a nanoplot column, a spanner, a highlighted maximum, footnotes.
#
# gt is static (no sort/filter/paginate) — exactly right for a regulatory table.
# See .claude/skills/gt-table/SKILL.md for the house pattern.

# --- UI -----------------------------------------------------------------------

mod_gt_table_ui <- function(id) {
  ns <- NS(id)
  layout_sidebar(
    sidebar = sidebar(
      title = "Table",
      width = 260,
      radioButtons(
        ns("which"), NULL,
        choices = c("Baseline characteristics (Table 1)" = "t1",
                    "AE incidence by SOC"                 = "ae"),
        selected = "t1"
      ),
      helpText("gt renders a fixed HTML table — the regulatory-deliverable look. ",
               "Use the download button to export it as standalone HTML."),
      downloadButton(ns("dl"), "Download HTML", class = "btn-outline-primary btn-sm")
    ),
    card(
      full_screen = TRUE,
      card_header(textOutput(ns("hdr"))),
      gt_output(ns("tbl"))
    )
  )
}

# --- Table builders (return gt objects; kept separate so they are testable) ---

.gt_table1 <- function(adsl) {
  build_table1(adsl) %>%
    gt::gt(groupname_col = "group", rowname_col = "label") %>%
    gt::tab_header(
      title    = gt::md("**Table 1.** Baseline Demographic & Clinical Characteristics"),
      subtitle = gt::md("Safety Analysis Set — synthetic study *ABC-101*")
    ) %>%
    gt::tab_spanner(
      label   = "Treatment Arm",
      columns = c("Placebo", "Low Dose", "High Dose")
    ) %>%
    gt::cols_align("center",
                   columns = c("Placebo", "Low Dose", "High Dose", "Total")) %>%
    gt::cols_align("left", columns = gt::everything()) %>%
    gt::tab_style(
      style    = gt::cell_text(weight = "bold"),
      locations = gt::cells_row_groups()
    ) %>%
    gt::tab_style(
      style    = list(gt::cell_fill(color = "#eef2f7")),
      locations = gt::cells_body(columns = "Total")
    ) %>%
    gt::tab_footnote(
      footnote  = "Continuous variables: mean (standard deviation).",
      locations = gt::cells_row_groups(
        groups = c("Age (years)", "Baseline BMI (kg/m²)", "Baseline weight (kg)")
      )
    ) %>%
    gt::tab_footnote(
      footnote  = "Counts of subjects; percentages use the arm N as denominator.",
      locations = gt::cells_column_spanners(spanners = "Treatment Arm")
    ) %>%
    gt::tab_source_note(
      gt::md("_Synthetic data generated for demonstration — not real patients._")
    ) %>%
    gt::sub_missing(columns = gt::everything(), missing_text = "—") %>%
    gt::opt_stylize(style = 5, color = "blue") %>%
    gt::tab_options(
      table.font.size = gt::px(13),
      heading.align   = "left",
      row_group.font.weight = "bold"
    )
}

.gt_ae <- function(adae, adsl) {
  build_ae_summary(adae, adsl) %>%
    gt::gt(rowname_col = "AEBODSYS") %>%
    gt::tab_header(
      title    = gt::md("**Table 14.3.1.** Adverse Events by System Organ Class"),
      subtitle = gt::md("Subjects with ≥ 1 event — Safety Analysis Set")
    ) %>%
    # Bar nanoplot of the three arm counts, built before the columns are merged.
    gt::cols_nanoplot(
      columns      = c("n_PBO", "n_LD", "n_HD"),
      plot_type    = "bar",
      new_col_name = "incidence_plot",
      new_col_label = "Profile"
    ) %>%
    gt::fmt_number(columns = c("n_PBO", "n_LD", "n_HD"), decimals = 0) %>%
    gt::fmt_percent(columns = c("pct_PBO", "pct_LD", "pct_HD"), decimals = 1) %>%
    # Heat-scale the incidence rates BEFORE merging them away.
    gt::data_color(
      columns = c("pct_PBO", "pct_LD", "pct_HD"),
      palette = c("#ffffff", "#ffcdd2", "#c62828"),
      domain  = c(0, 0.5)
    ) %>%
    gt::cols_merge(columns = c("n_PBO", "pct_PBO"), pattern = "{1} ({2})") %>%
    gt::cols_merge(columns = c("n_LD",  "pct_LD"),  pattern = "{1} ({2})") %>%
    gt::cols_merge(columns = c("n_HD",  "pct_HD"),  pattern = "{1} ({2})") %>%
    gt::cols_label(
      n_PBO = "Placebo", n_LD = "Low Dose", n_HD = "High Dose"
    ) %>%
    gt::tab_spanner(
      label   = "n (%) of subjects",
      columns = c("n_PBO", "n_LD", "n_HD")
    ) %>%
    gt::tab_style(
      style    = gt::cell_text(weight = "bold", color = "#c62828"),
      locations = gt::cells_body(
        columns = "n_HD",
        rows    = pct_HD == max(pct_HD)
      )
    ) %>%
    gt::tab_footnote(
      footnote  = "Highest-incidence System Organ Class in the High Dose arm.",
      locations = gt::cells_stub(rows = pct_HD == max(pct_HD))
    ) %>%
    gt::tab_source_note(gt::md(
      "_A subject contributing >1 event within a class is counted once._"
    )) %>%
    gt::opt_stylize(style = 2, color = "gray") %>%
    gt::tab_options(table.font.size = gt::px(13), heading.align = "left")
}

# --- Server -------------------------------------------------------------------

mod_gt_table_server <- function(id, adae, adsl) {
  moduleServer(id, function(input, output, session) {

    current_gt <- reactive({
      if (identical(input$which, "ae")) .gt_ae(adae, adsl) else .gt_table1(adsl)
    })

    output$hdr <- renderText({
      if (identical(input$which, "ae")) {
        "AE Incidence by System Organ Class"
      } else {
        "Baseline Characteristics"
      }
    })

    output$tbl <- render_gt(current_gt())

    output$dl <- downloadHandler(
      filename = function() {
        paste0(if (identical(input$which, "ae")) "ae_summary" else "table1",
               ".html")
      },
      content = function(file) gt::gtsave(current_gt(), file)
    )

    invisible(NULL)
  })
}
