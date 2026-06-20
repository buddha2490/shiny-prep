# mod_dt_table.R --------------------------------------------------------------
#
# DT (DataTables) showcase: an interactive adverse-event listing.
#
# Features demonstrated:
#   * editable cells (severity / seriousness / relatedness / outcome) read back
#     into a reactiveVal and pushed to the table via a proxy (no full re-render)
#   * dataTableProxy(): replaceData(), selectRows(), clearing selection
#   * row selection driving a live detail panel
#   * Buttons extension (copy / CSV / Excel / PDF / column visibility)
#   * FixedHeader, top column filters, server = FALSE for full-data export
#   * formatStyle() conditional colouring + a colour-bar background on duration
#   * a "serious AE" row highlight via a styled column
#
# See .claude/skills/dt-table/SKILL.md for the house pattern this builds on.

# Columns shown, in display order (0-based indices used below match this order).
.DT_COLS <- c("USUBJID", "ARM", "AEBODSYS", "AEDECOD", "AESEV",
              "AESER", "AEREL", "AESTDY", "AEDUR", "AEOUT")

# Only the clinical-assessment columns are editable; identifiers/timing are not.
.DT_EDITABLE   <- c("AESEV", "AESER", "AEREL", "AEOUT")
.DT_READONLY_I <- which(!.DT_COLS %in% .DT_EDITABLE) - 1L   # 0-based for DT

# --- UI -----------------------------------------------------------------------

mod_dt_table_ui <- function(id) {
  ns <- NS(id)
  layout_sidebar(
    sidebar = sidebar(
      title = "Controls",
      width = 260,
      helpText(
        "Double-click a severity, seriousness, relatedness or outcome cell to ",
        "edit it. Edits flow back into R via a proxy — no full redraw."
      ),
      actionButton(ns("worsen"), "Simulate follow-up",
                   icon = icon("rotate"), class = "btn-outline-primary btn-sm"),
      actionButton(ns("select_serious"), "Select serious AEs",
                   icon = icon("triangle-exclamation"),
                   class = "btn-outline-warning btn-sm"),
      actionButton(ns("clear_sel"), "Clear selection",
                   icon = icon("eraser"), class = "btn-outline-secondary btn-sm"),
      hr(),
      downloadButton(ns("dl_all"), "Download all (CSV)",
                     class = "btn-outline-primary btn-sm"),
      actionButton(ns("reset"), "Reset data", icon = icon("arrow-rotate-left"),
                   class = "btn-outline-danger btn-sm")
    ),
    layout_columns(
      col_widths = c(3, 3, 3, 3),
      value_box("Records", textOutput(ns("n_rec")), showcase = icon("list"),
                theme = "primary"),
      value_box("Subjects with AEs", textOutput(ns("n_subj")),
                showcase = icon("user-injured"), theme = "secondary"),
      value_box("Serious", textOutput(ns("n_serious")),
                showcase = icon("triangle-exclamation"), theme = "warning"),
      value_box("Edits made", textOutput(ns("n_edits")),
                showcase = icon("pen"), theme = "success")
    ),
    card(
      full_screen = TRUE,
      card_header("Adverse Event Listing (editable)"),
      DTOutput(ns("tbl"))
    ),
    uiOutput(ns("detail"))
  )
}

# --- Server -------------------------------------------------------------------

mod_dt_table_server <- function(id, adae) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    initial <- adae[, .DT_COLS]
    rv      <- reactiveVal(initial)
    n_edits <- reactiveVal(0L)

    # Render ONCE from an isolated snapshot; all later updates go through the
    # proxy so pagination, sort and scroll position survive edits.
    output$tbl <- renderDT(
      {
        datatable(
          isolate(rv()),
          rownames   = FALSE,
          filter     = "top",
          selection  = "multiple",
          extensions = c("Buttons", "FixedHeader"),
          editable   = list(
            target  = "cell",
            disable = list(columns = .DT_READONLY_I)
          ),
          colnames = c(
            "Subject" = "USUBJID", "Arm" = "ARM", "SOC" = "AEBODSYS",
            "Preferred Term" = "AEDECOD", "Severity" = "AESEV",
            "Serious" = "AESER", "Relatedness" = "AEREL",
            "Start Day" = "AESTDY", "Duration (d)" = "AEDUR",
            "Outcome" = "AEOUT"
          ),
          options = list(
            pageLength = 15,
            dom        = "Bfrtip",
            fixedHeader = TRUE,
            scrollX    = TRUE,
            buttons    = list(
              "copy",
              list(extend = "csv",   text = "CSV",   filename = "ae_listing"),
              list(extend = "excel", text = "Excel", filename = "ae_listing"),
              list(extend = "pdf",   text = "PDF",   orientation = "landscape"),
              list(extend = "colvis", text = "Columns")
            ),
            columnDefs = list(
              list(className = "dt-center", targets = c(4, 5, 6, 7, 8, 9))
            )
          )
        ) %>%
          # NOTE: after `colnames =` renames columns, formatStyle() must
          # reference the *displayed* names ("Severity"), not the data names
          # ("AESEV") — DT resolves columns against the rendered header.
          # Severity text colour-coded by grade.
          formatStyle(
            "Severity",
            color = styleEqual(names(SEV_COLORS), unname(SEV_COLORS)),
            fontWeight = "bold"
          ) %>%
          # Serious == "Y" gets a red, bold flag.
          formatStyle(
            "Serious",
            backgroundColor = styleEqual("Y", "#fdecea"),
            color = styleEqual("Y", "#c62828"), fontWeight = "bold"
          ) %>%
          # Duration rendered as an in-cell colour bar (DT's styleColorBar).
          formatStyle(
            "Duration (d)",
            background = styleColorBar(range(initial$AEDUR), "#bbdefb"),
            backgroundSize = "98% 60%",
            backgroundRepeat = "no-repeat",
            backgroundPosition = "center"
          )
      },
      # server = TRUE is required for the proxy to work: replaceData() and
      # editData() reload data over Ajax, which only exists in server mode.
      # The Buttons extension therefore exports only the current page — the
      # sidebar "Download all (CSV)" handler covers full-data export.
      server = TRUE
    )

    proxy <- dataTableProxy("tbl")

    # --- Edits: write back to rv() and the table in one call ------------------
    observeEvent(input$tbl_cell_edit, {
      rv(editData(rv(), input$tbl_cell_edit, proxy, rownames = FALSE))
      n_edits(n_edits() + 1L)
    })

    # --- "Simulate follow-up": mutate durations + outcomes via replaceData ----
    observeEvent(input$worsen, {
      d <- rv()
      bump <- sample(seq_len(nrow(d)), ceiling(nrow(d) / 4))
      d$AEDUR[bump] <- d$AEDUR[bump] + sample(1:10, length(bump), replace = TRUE)
      d$AEOUT[d$AEOUT == "RECOVERING"] <- "RECOVERED"
      rv(d)
      replaceData(proxy, d, resetPaging = FALSE, rownames = FALSE)
    })

    # --- Programmatic selection / clearing ------------------------------------
    observeEvent(input$select_serious, {
      selectRows(proxy, which(rv()$AESER == "Y"))
    })
    observeEvent(input$clear_sel, selectRows(proxy, NULL))

    observeEvent(input$reset, {
      rv(initial)
      n_edits(0L)
      replaceData(proxy, initial, resetPaging = TRUE, rownames = FALSE)
      selectRows(proxy, NULL)
    })

    # --- Full-data CSV export (Buttons only export the current page) ----------
    output$dl_all <- downloadHandler(
      filename = function() "ae_listing_full.csv",
      content  = function(file) utils::write.csv(rv(), file, row.names = FALSE)
    )

    # --- Value boxes ----------------------------------------------------------
    output$n_rec     <- renderText(format(nrow(rv()), big.mark = ","))
    output$n_subj    <- renderText(dplyr::n_distinct(rv()$USUBJID))
    output$n_serious <- renderText(sum(rv()$AESER == "Y"))
    output$n_edits   <- renderText(n_edits())

    # --- Selection-driven detail panel ----------------------------------------
    output$detail <- renderUI({
      sel <- input$tbl_rows_selected
      if (length(sel) == 0) {
        return(card(card_body(
          class = "text-muted",
          "Select one or more rows (or use “Select serious AEs”) to see ",
          "a per-subject summary here."
        )))
      }
      d <- rv()[sel, ]
      card(
        card_header(sprintf("Selected: %d event(s)", length(sel))),
        card_body(
          tags$ul(
            tags$li(sprintf("Distinct subjects: %d",
                            dplyr::n_distinct(d$USUBJID))),
            tags$li(sprintf("Serious: %d", sum(d$AESER == "Y"))),
            tags$li(sprintf("Most common term: %s",
                            names(sort(table(d$AEDECOD), decreasing = TRUE))[1]))
          )
        )
      )
    })

    invisible(NULL)
  })
}
