# mod_computed_styles.R -------------------------------------------------------
#
# Tab: "Computed styles" — demonstrates css-styling Rule 2 (when inline styles
# are acceptable: styles whose values depend on R data and cannot be expressed
# in a static file).
#
# A slider sets a completion threshold; the module renders a per-subject panel
# where each row has:
#   * a percent bar whose WIDTH is computed from the data (pct_bar())
#   * a grade chip whose COLOUR is computed from the data (grade_fill())
#   * a conditional "below threshold" highlight driven by the live slider
# All three are genuine Rule 2 inline styles — there is no static class that
# could carry a per-row width or a data-driven colour. The reusable parts of the
# treatment (track, chip shape) still live in www/custom.css (Rule 1).

mod_computed_styles_ui <- function(id) {
  ns <- NS(id)
  layout_sidebar(
    sidebar = sidebar(
      title = "Threshold",
      # A plain Bootstrap utility class on the helptext (Rule 3) — no custom CSS.
      p(class = "text-muted small",
        "Rows at or below the threshold are highlighted. The bar width and the
         grade-chip colour are computed from each subject's data — they are the
         Rule 2 inline-style case."),
      sliderInput(ns("threshold"), "Completion threshold (%)",
                  min = 0, max = 100, value = 50, step = 5)
    ),
    card(
      card_header("Subject completion & lab grade"),
      card_body(uiOutput(ns("rows")))
    )
  )
}

mod_computed_styles_server <- function(id, subjects) {
  moduleServer(id, function(input, output, session) {

    output$rows <- renderUI({
      thr <- input$threshold

      rows <- lapply(seq_len(nrow(subjects)), function(i) {
        s <- subjects[i, ]
        below <- s$completion <= thr

        # Conditional row highlight: a computed class toggle (Rule 2/3 boundary).
        # The highlight *treatment* is a static class in custom.css; whether the
        # row gets it is data-driven, so the decision happens here in R.
        div(
          class = paste("subject-row d-flex align-items-center gap-3 p-2",
                        if (below) "subject-row-flagged" else ""),
          div(class = "subject-id fw-semibold", s$subject),
          span(class = "badge text-bg-light", s$arm),
          # Computed bar width + fill — the canonical Rule 2 inline style.
          div(
            class = "flex-grow-1",
            pct_bar(s$completion,
                    fill = if (below) "var(--app-grade-3)" else "var(--app-accent)")
          ),
          # Computed chip colour — data-driven, so inline.
          span(
            class = "grade-chip",
            style = htmltools::css(`background-color` = grade_fill(s$lab_grade)),
            paste0("G", s$lab_grade)
          )
        )
      })

      tagList(rows)
    })

    # Expose the count of flagged rows so a testServer() test has a reactive to
    # assert on (the UI itself is covered at the AppDriver layer).
    flagged_count <- reactive({
      sum(subjects$completion <= input$threshold)
    })
    list(flagged_count = flagged_count)
  })
}
