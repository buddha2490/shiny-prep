# =============================================================================
# server.R — wires real outputs into every showcase tab (assigned to `server`)
# =============================================================================
# Every tab renders REAL content (plotly / DT / ggplot) so the showcase isn't
# placeholders. The reactive surface is deliberately small — this is a layout
# demo — so we use plain reactives/reactiveVal (no R6 needed for self-contained
# local state, per the reactivity guidance).
# =============================================================================

server <- function(input, output, session) {

  # --- Shared filtered ADSL --- [2026-06-20]
  # The page-level sidebar (arm_filter + age_filter) scopes the data used across
  # tabs. req() is not needed — selectInput/sliderInput have defaults, so this is
  # always satisfiable; we just branch on the "All arms" sentinel.
  filtered_adsl <- reactive({
    out <- adsl %>% dplyr::filter(AGE <= input$age_filter)
    if (!identical(input$arm_filter, "All arms")) {
      out <- out %>% dplyr::filter(ARM == input$arm_filter)
    }
    out
  })

  # --- Current light/dark mode --- [2026-06-20]
  # input$dark_mode reports "light"/"dark" from the navbar toggle. Defaults to
  # "light" until the input initializes so first-flush renders don't error.
  current_mode <- reactive({
    input$dark_mode %||% "light"
  })

  # =========================================================================
  # TAB 1 — Layouts
  # =========================================================================

  # --- Enrollment curve (plotly) --- [2026-06-20]
  # ggplotly() converts the themed ggplot so the card gets an interactive chart.
  output$layout_plot <- renderPlotly({
    g <- plot_enrollment(enrollment, current_mode())
    ggplotly(g) %>%
      layout(legend = list(orientation = "h", y = -0.2))
  })

  # --- ADSL table (DT) in a card --- [2026-06-20]
  # formatStyle + formatRound show DT formatting; the table reacts to the sidebar
  # filter so the page-level controls visibly do something.
  output$layout_table <- renderDT({
    datatable(
      filtered_adsl() %>%
        dplyr::select(USUBJID, ARM, AGE, SEX, REGION),
      rownames = FALSE,
      options = list(pageLength = 5, dom = "tp"),
      class = "compact stripe"
    ) %>%
      formatStyle(
        "ARM",
        backgroundColor = styleEqual(
          names(ARM_COLORS), unname(scales::alpha(ARM_COLORS, 0.25))
        )
      )
  })

  # --- Card-scoped sidebar plot --- [2026-06-20]
  # Driven by the radioButtons INSIDE the card's layout_sidebar, independent of
  # the page sidebar — demonstrates card-level vs page-level scoping.
  output$layout_card_plot <- renderPlot({
    if (identical(input$layout_metric, "ae")) {
      plot_ae_counts(ae_counts, current_mode())
    } else {
      plot_enrollment(enrollment, current_mode())
    }
  })

  # =========================================================================
  # TAB 2 — Value boxes & components
  # =========================================================================

  # --- Value-box dynamic values --- [2026-06-20]
  # textOutput(inline = TRUE) feeds live numbers into value_box() values.
  output$vb_subjects <- renderText({
    nrow(filtered_adsl())
  })

  output$vb_aes <- renderText({
    sum(ae_counts$n_ae)
  })

  output$vb_trend <- renderText({
    # Latest cumulative enrollment across all arms — a headline KPI.
    paste0("+", sum(enrollment$n_enrolled[enrollment$week == max(enrollment$week)]),
           " this week")
  })

  # --- Full-bleed sparkline showcase --- [2026-06-20]
  # The "bottom" showcase_layout renders this plot edge-to-edge under the value.
  output$vb_sparkline <- renderPlot(
    {
      weekly <- enrollment %>%
        dplyr::group_by(week) %>%
        dplyr::summarise(n = sum(n_enrolled), .groups = "drop") %>%
        dplyr::arrange(week)
      sparkline_plot(weekly$n, color = "#ffffff")
    },
    # Transparent so the value_box theme color shows through behind the spark.
    bg = "transparent"
  )

  # --- input_switch state --- [2026-06-20]
  output$switch_state <- renderText({
    if (isTRUE(input$show_severe)) {
      "Severe-only highlight is ON."
    } else {
      "Showing all severities."
    }
  })

  # --- Action button via observeEvent / bindEvent --- [2026-06-20]
  # A reactiveVal counter is the simplest self-contained local state — exactly
  # the case where reactiveVal beats an R6 object. bindEvent on the render keeps
  # the text in sync only when the button fires.
  click_n <- reactiveVal(0L)
  observeEvent(input$count_btn, {
    click_n(click_n() + 1L)
  })
  output$click_count <- renderText({
    paste("Button clicked", click_n(), "times.")
  })

  # =========================================================================
  # TAB 3 — Navsets
  # =========================================================================

  # --- Navset card plot --- [2026-06-20]
  # Color-by control lives in the navset_card_tab's shared sidebar.
  output$nav_plot <- renderPlot({
    color_var <- input$nav_demo_col %||% "ARM"
    ggplot2::ggplot(
      filtered_adsl(),
      ggplot2::aes(x = AGE, fill = .data[[color_var]])
    ) +
      ggplot2::geom_histogram(bins = 15, position = "stack", color = "white") +
      mode_theme(current_mode()) +
      ggplot2::labs(x = "Age", y = "Count", fill = color_var)
  })

  output$nav_table <- renderDT({
    datatable(
      filtered_adsl() %>% dplyr::count(ARM, SEX, name = "n"),
      rownames = FALSE,
      options = list(dom = "t")
    )
  })

  # --- Server-side nav_select() --- [2026-06-20]
  # The button jumps the navset_card_tab (id = "inner_tabs") to its Table panel.
  observeEvent(input$goto_table, {
    nav_select("inner_tabs", selected = "Table")
  })

  # =========================================================================
  # TAB 4 — Theming
  # =========================================================================

  # --- Live bootswatch theme switch --- [2026-06-20]
  # session$setCurrentTheme() swaps the ENTIRE app theme at runtime. "default"
  # means plain Bootstrap 5 with our brand primary; any other value applies that
  # bootswatch preset. We keep the custom primary + font so brand survives.
  observeEvent(input$bootswatch, {
    new_theme <- if (identical(input$bootswatch, "default")) {
      bs_theme(version = 5, primary = "#0d6efd",
               base_font = font_google("Inter"))
    } else {
      bs_theme(version = 5, bootswatch = input$bootswatch,
               base_font = font_google("Inter"))
    }
    session$setCurrentTheme(new_theme)
  })

  # --- Theme-aware ggplot --- [2026-06-20]
  # Recolors with light/dark mode via mode_theme() — the hand-rolled stand-in for
  # thematic_shiny() (not in the locked library). Depends on current_mode() so it
  # re-renders whenever the navbar toggle flips.
  output$theme_plot <- renderPlot({
    plot_ae_counts(ae_counts, current_mode())
  })
}
