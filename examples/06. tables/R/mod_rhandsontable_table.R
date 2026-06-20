# mod_rhandsontable_table.R ---------------------------------------------------
#
# rhandsontable showcase: an editable data-management query grid — the classic
# "spreadsheet in Shiny" use case (data entry / query resolution).
#
# Features demonstrated:
#   * mixed column types: read-only text, dropdown, checkbox, date, numeric
#   * numeric validation (age in days must be 0–365; invalid entries blocked)
#   * a custom JS renderer that flags aging open queries in red
#   * save / reset against a reactiveValues store (edits persist or revert)
#   * a live (unsaved) edit preview + change counter via hot_to_r()
#   * download of the current edited grid as CSV
#
# See .claude/skills/rhandsontable-table/SKILL.md for the house pattern.

# Columns the reviewer may NOT change (identifiers + system-generated query text).
.HOT_READONLY <- c("QUERYID", "USUBJID", "DOMAIN", "FIELD", "QUERYTXT")

# JS renderer: red background once an open query is older than 30 days.
.HOT_AGE_RENDERER <- "
  function(instance, td, row, col, prop, value, cellProperties) {
    Handsontable.renderers.NumericRenderer.apply(this, arguments);
    if (value > 30) {
      td.style.background = '#fdecea';
      td.style.color = '#c62828';
      td.style.fontWeight = '600';
    } else if (value > 14) {
      td.style.background = '#fff8e1';
    }
    return td;
  }
"

# --- UI -----------------------------------------------------------------------

mod_rhandsontable_table_ui <- function(id) {
  ns <- NS(id)
  layout_sidebar(
    sidebar = sidebar(
      title = "Edit & save",
      width = 260,
      helpText(
        "Edit Status, Priority, the confirm box, the due date or the age. ",
        "Aging open queries flag red. Save commits edits; Reset reverts."
      ),
      actionButton(ns("save"), "Save changes", icon = icon("floppy-disk"),
                   class = "btn-primary btn-sm"),
      actionButton(ns("reset"), "Reset", icon = icon("arrow-rotate-left"),
                   class = "btn-outline-secondary btn-sm"),
      hr(),
      downloadButton(ns("dl"), "Download CSV", class = "btn-outline-primary btn-sm"),
      hr(),
      uiOutput(ns("status"))
    ),
    card(
      full_screen = TRUE,
      card_header("Data-Management Queries (editable)"),
      rHandsontableOutput(ns("tbl"))
    )
  )
}

# --- Server -------------------------------------------------------------------

mod_rhandsontable_table_server <- function(id, queries) {
  moduleServer(id, function(input, output, session) {

    # Add a deterministic due-date column to demonstrate the date cell type.
    initial <- queries %>%
      dplyr::mutate(DUEDATE = as.Date("2026-01-01") + AGE_DAYS) %>%
      dplyr::select(QUERYID, USUBJID, DOMAIN, FIELD, QUERYTXT,
                    PRIORITY, STATUS, DUEDATE, AGE_DAYS, CONFIRM)

    rv <- reactiveValues(data = initial)

    output$tbl <- renderRHandsontable({
      # rhandsontable's internal Date handling calls the deprecated
      # `as.character(<Date>, format=)` form, which warns under R >= 4.5. The
      # warning is upstream and harmless — muffle just that one message so it
      # does not clutter the console/tests, without hiding other warnings.
      withCallingHandlers(
        rhandsontable(
        rv$data,
        rowHeaders  = NULL,
        stretchH    = "all",
        contextMenu = TRUE,
        height      = 460
      ) %>%
        hot_table(highlightCol = TRUE, highlightRow = TRUE) %>%
        # Identifier columns are locked.
        hot_col(.HOT_READONLY, readOnly = TRUE) %>%
        hot_col("QUERYTXT", width = 240) %>%
        # Dropdowns constrain to controlled values.
        hot_col("STATUS",   type = "dropdown",
                source = c("Open", "Answered", "Closed")) %>%
        hot_col("PRIORITY", type = "dropdown",
                source = c("Low", "Medium", "High")) %>%
        hot_col("CONFIRM",  type = "checkbox") %>%
        hot_col("DUEDATE",  type = "date", dateFormat = "YYYY-MM-DD") %>%
        # Numeric with a hard validator + the aging-flag renderer.
        hot_col(
          "AGE_DAYS", type = "numeric", format = "0",
          validator = "function(value, callback){
            callback(value >= 0 && value <= 365);
          }",
          allowInvalid = FALSE,
          renderer = .HOT_AGE_RENDERER
        ) %>%
        hot_cols(columnSorting = TRUE),
        warning = function(w) {
          if (grepl("no longer obeys a 'format'", conditionMessage(w))) {
            invokeRestart("muffleWarning")
          }
        }
      )
    })

    # Live (unsaved) view of the grid as an R data frame.
    edited <- reactive({
      if (is.null(input$tbl)) rv$data else hot_to_r(input$tbl)
    })

    observeEvent(input$save,  rv$data <- hot_to_r(input$tbl))
    observeEvent(input$reset, rv$data <- initial)

    # --- Sidebar status block -------------------------------------------------
    output$status <- renderUI({
      d <- edited()
      n_open    <- sum(d$STATUS == "Open")
      n_overdue <- sum(d$STATUS == "Open" & d$AGE_DAYS > 30)
      n_conf    <- sum(d$CONFIRM)
      # Count cells differing from the last saved state.
      changed <- if (nrow(d) == nrow(rv$data)) {
        sum(vapply(seq_along(d), function(j) {
          sum(as.character(d[[j]]) != as.character(rv$data[[j]]), na.rm = TRUE)
        }, integer(1)))
      } else {
        NA_integer_
      }
      tagList(
        tags$p(tags$b("Open: "), n_open,
               tags$span(class = "text-danger",
                         sprintf(" (%d aging > 30d)", n_overdue))),
        tags$p(tags$b("Confirmed: "), n_conf),
        tags$p(tags$b("Unsaved cell edits: "),
               tags$span(class = if (isTRUE(changed > 0)) "text-warning" else "",
                         ifelse(is.na(changed), "—", changed)))
      )
    })

    output$dl <- downloadHandler(
      filename = function() "queries_edited.csv",
      content  = function(file) utils::write.csv(edited(), file, row.names = FALSE)
    )

    invisible(NULL)
  })
}
