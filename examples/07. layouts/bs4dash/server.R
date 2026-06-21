# server.R --------------------------------------------------------------------
#
# Server for the bs4Dash showcase. Assigns a single `server` function
# (shiny-app-structure rule). No library()/data-loading here — all of that is
# in global.R.
#
# Responsibilities:
#   * render the dynamic value/info boxes (Overview tab)
#   * render the two charts + DT table (Charts / Data tabs)
#   * drive the imperative bs4Dash widgets: updateBox(), updateBoxSidebar(),
#     updateAccordion(), updateControlbar(), and fire a toast().

server <- function(input, output, session) {

  # =========================================================================
  # OVERVIEW — dynamic value box + info box
  # =========================================================================

  # --- Dynamic value box driven by the controlbar slider --- [2026-06-20]
  # Recomputes enrolled-vs-target whenever input$target_n changes, proving the
  # renderValueBox / valueBoxOutput round-trip. Colour flips to success once the
  # target is met — a small "live" touch.
  output$vbox_target <- renderValueBox({
    target <- input$target_n %||% 80
    enrolled <- nrow(ADSL)
    pct <- round(100 * enrolled / target)
    valueBox(
      value    = paste0(pct, "%"),
      subtitle = paste0("of enrollment target (", target, ")"),
      color    = if (enrolled >= target) "success" else "secondary",
      icon     = icon("bullseye"),
      gradient = TRUE,
      elevation = 4
    )
  })

  # --- Info box: region count --- [2026-06-20]
  # Static-ish, but rendered server-side to demonstrate renderInfoBox wiring.
  output$ibox_regions <- renderInfoBox({
    infoBox(
      title = "Regions",
      value = nlevels(ADSL$REGION),
      icon  = icon("earth-americas"),
      color = "info",
      fill  = TRUE
    )
  })

  # =========================================================================
  # BOXES — imperative widget controls
  # =========================================================================

  # --- Toggle (collapse/expand) the 'Everything box' --- [2026-06-20]
  # updateBox(action="toggle") flips the box's collapsed state from the server.
  observeEvent(input$toggle_box, {
    updateBox("kitchen_sink_box", action = "toggle")
  })

  # --- Maximize the 'Everything box' --- [2026-06-20]
  observeEvent(input$max_box, {
    updateBox("kitchen_sink_box", action = "toggleMaximize")
  })

  # --- Open the in-box sidebar --- [2026-06-20]
  # updateBoxSidebar() toggles the slide-out panel inside the success box.
  observeEvent(input$open_box_sidebar, {
    updateBoxSidebar("box_sidebar")
  })

  # --- Box-dropdown item 'Export' fires a toast --- [2026-06-20]
  # boxDropdownItem(id=) behaves like an actionButton; toast() is bs4Dash's
  # AdminLTE notification. options uses autohide/icon/close (the bs4Dash form).
  observeEvent(input$dd_export, {
    toast(
      title = "Export started",
      body = "Demo export — no file is actually written.",
      options = list(
        autohide = TRUE,
        class = "bg-primary",
        icon = "fas fa-download",
        position = "topRight"
      )
    )
  })

  observeEvent(input$dd_refresh, {
    toast(
      title = "Refreshed",
      body = "Demo refresh complete.",
      options = list(autohide = TRUE, class = "bg-success",
                    icon = "fas fa-rotate", position = "topRight")
    )
  })

  # =========================================================================
  # COMPONENTS — accordion control
  # =========================================================================

  # --- Open an accordion item from the radio buttons --- [2026-06-20]
  # updateAccordion(selected=) opens the item at that index on the client.
  observeEvent(input$acc_control, {
    updateAccordion("demo_accordion", selected = as.integer(input$acc_control))
  })

  # =========================================================================
  # CHARTS — ggplot + plotly, both driven by the arm filter
  # =========================================================================

  # --- Filtered subject set --- [2026-06-20]
  # req() guards the first flush before the checkbox group initialises; without
  # it the charts would briefly try to filter on NULL.
  filtered_adsl <- reactive({
    req(input$arm_filter)
    ADSL %>% dplyr::filter(.data$ARM %in% input$arm_filter)
  })

  # --- Enrollment trend (ggplot) --- [2026-06-20]
  # Recompute the cumulative curve on the filtered subjects so the chart reacts
  # to the arm filter. The controlbar switch toggles points on the line.
  output$enroll_plot <- renderPlot({
    df <- make_enrollment(filtered_adsl())
    validate(need(nrow(df) > 0, "No subjects match the selected arms."))

    p <- ggplot(df, aes(x = MONTH, y = CUM_N)) +
      geom_line(linewidth = 1.1, colour = "#2c7fb8") +
      labs(x = NULL, y = "Cumulative subjects") +
      theme_minimal(base_size = 13)

    # show_points is a prettySwitch in the controlbar; default TRUE if unset.
    if (isTRUE(input$show_points %||% TRUE)) {
      p <- p + geom_point(size = 2.2, colour = "#2c7fb8")
    }
    p
  })

  # --- AE counts by arm & severity (plotly grouped bars) --- [2026-06-20]
  # Filter the AE-count frame to the selected arms, then draw a grouped bar
  # chart. Built with plot_ly directly (small data — no scattergl needed).
  output$ae_plot <- renderPlotly({
    df <- AE_COUNTS %>%
      dplyr::filter(.data$ARM %in% (input$arm_filter %||% ARM_LEVELS))
    validate(need(nrow(df) > 0, "No subjects match the selected arms."))

    plot_ly(
      df, x = ~ARM, y = ~N, color = ~SEVERITY, type = "bar",
      colors = c(Mild = "#41b6c4", Moderate = "#fec44f", Severe = "#de2d26")
    ) %>%
      layout(
        barmode = "group",
        xaxis = list(title = ""),
        yaxis = list(title = "AE count"),
        legend = list(orientation = "h")
      )
  })

  # =========================================================================
  # DATA — DT listing
  # =========================================================================

  # --- ADSL listing --- [2026-06-20]
  # A compact DT with search/paging. Dates formatted for display; no PHI (this
  # is synthetic demo data).
  output$adsl_table <- renderDT({
    datatable(
      ADSL,
      rownames = FALSE,
      filter = "top",
      options = list(pageLength = 10, scrollX = TRUE)
    )
  })

  # =========================================================================
  # STARTUP — dismiss the preloader + reveal the controlbar (one-shot)
  # =========================================================================

  # --- Hide the boot splash + nudge the controlbar open --- [2026-06-20]
  # GOTCHA: bs4Dash's dashboardPage(preloader=) splash does NOT auto-hide — you
  # must call waiter::waiter_hide() yourself or it covers the app forever. (An
  # AppDriver smoke test won't catch this: it reads outputs in the DOM *behind*
  # the overlay, so the app looks "loaded" to the test while a real browser is
  # stuck on the splash.) A one-shot session$onFlushed fires after the first
  # reactive flush — content is rendered, so we drop the splash and, while we're
  # here, open the unique bs4Dash control bar so reviewers notice the right rail.
  session$onFlushed(function() {
    waiter::waiter_hide()
    updateControlbar("controlbar")
  }, once = TRUE)
}
