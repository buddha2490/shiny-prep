# server.R --------------------------------------------------------------------
#
# Wires real outputs to every tab so nothing is a placeholder:
#   * Overview : a dynamic valueBox + infoBox that recompute from a selectInput.
#   * Charts   : a ggplot and a plotly chart, both filtered by box controls.
#   * Data     : a DT table of ADSL.
#   * Widgets  : updateTabItems() tab-jump, a click counter, and a dynamic
#                sidebar menu (renderMenu) that grows on a button click.
#   * Header   : a dynamic dropdownMenu (renderMenu) tied to the search box.
#
# Shiny discovers this by the variable name `server`.

server <- function(input, output, session) {

  # --- Overview: dynamic value/info boxes --- [2026-06-20]
  # Filter ADSL by the selected arm, then surface the count in a valueBox and an
  # infoBox via renderValueBox / renderInfoBox. req() is not needed — selectInput
  # always has a value — but we guard the "All arms" sentinel explicitly.
  ov_subset <- reactive({
    if (identical(input$ov_arm, "All arms")) {
      ADSL
    } else {
      dplyr::filter(ADSL, .data$ARM == input$ov_arm)
    }
  })

  output$ov_dynamic_box <- renderValueBox({
    valueBox(
      value    = nrow(ov_subset()),
      subtitle = paste("Subjects:", input$ov_arm),
      icon     = icon("user-check"),
      color    = "purple"
    )
  })

  output$ov_dynamic_info <- renderInfoBox({
    infoBox(
      title = "Mean age (filtered)",
      value = round(mean(ov_subset()$AGE), 1),
      icon  = icon("cake-candles"),
      color = "olive",
      fill  = TRUE
    )
  })

  # --- Charts: shared filtered data --- [2026-06-20]
  # One reactive feeds both charts so the region + age controls drive them in
  # lockstep. Rebuilds the derived frames from the filtered ADSL each time.
  chart_data <- reactive({
    df <- ADSL
    if (!identical(input$chart_region, "All regions")) {
      df <- dplyr::filter(df, .data$REGION == input$chart_region)
    }
    df <- dplyr::filter(
      df,
      .data$AGE >= input$chart_age[1],
      .data$AGE <= input$chart_age[2]
    )
    df
  })

  # ggplot enrollment curve — guard the empty-filter case so the plot helper
  # never receives a zero-row frame (req() blanks the output cleanly instead).
  output$chart_enroll <- renderPlot({
    df <- chart_data()
    req(nrow(df) > 0)
    plot_enrollment(make_enrollment(df))
  })

  # plotly AE-by-arm bar chart from the same filtered frame.
  output$chart_ae <- renderPlotly({
    df <- chart_data()
    req(nrow(df) > 0)
    plot_ae_by_arm(make_ae_by_arm(df))
  })

  # --- Data: DT listing --- [2026-06-20]
  # A straightforward DT of ADSL inside the box. Server-side processing on so the
  # demo shows the paginated/searchable default DataTables behaviour.
  output$data_table <- renderDT(
    {
      ADSL
    },
    options  = list(pageLength = 10, scrollX = TRUE),
    rownames = FALSE,
    filter   = "top"
  )

  # --- Widgets: programmatic tab switch --- [2026-06-20]
  # updateTabItems() targets the sidebarMenu id ("sidebar_tabs") and selects the
  # "overview" tab — the canonical shinydashboard tab-jump pattern.
  observeEvent(input$go_overview, {
    updateTabItems(session, "sidebar_tabs", selected = "overview")
  })

  # --- Widgets: click counter for a background box --- [2026-06-20]
  # Tiny reactiveVal counting "add sidebar item" presses, shown in the purple
  # background box, so that tile renders real (non-placeholder) content.
  click_count <- reactiveVal(0L)
  observeEvent(input$add_menu_item, {
    click_count(click_count() + 1L)
  })
  output$widget_clicks <- renderText({
    paste("Sidebar items added:", click_count())
  })

  # --- Widgets: dynamic sidebar menu (renderMenu) --- [2026-06-20]
  # renderMenu rebuilds a sidebarMenu reactively. It starts with one item and
  # grows by one menuItem per "add sidebar item" click — demonstrating
  # sidebarMenuOutput / renderMenu and reactive menu construction.
  output$dynamic_menu <- renderMenu({
    n_extra <- click_count()
    extra_items <- lapply(seq_len(n_extra), function(i) {
      menuItem(
        paste("Saved view", i),
        icon = icon("bookmark"),
        href = "#"
      )
    })
    # .list lets us pass programmatically-built items into sidebarMenu.
    sidebarMenu(
      .list = c(
        list(menuItem("Dynamic section", icon = icon("layer-group"),
                      href = "#")),
        extra_items
      )
    )
  })

  # --- Header: dynamic message dropdown (renderMenu) --- [2026-06-20]
  # Rebuilds the header's 4th dropdown from the sidebar search term, so typing a
  # query and pressing search updates the dropdown — the header renderMenu
  # pattern. No PHI logged; search text is user-entered demo input only.
  output$dynamic_msgs <- renderMenu({
    q <- input$search_text
    note <- if (is.null(q) || !nzchar(q)) {
      "No active search"
    } else {
      paste0("Searching: '", q, "'")
    }
    dropdownMenu(
      type = "messages", badgeStatus = "info",
      messageItem(
        from = "Search",
        message = note,
        icon = icon("magnifying-glass")
      )
    )
  })
}
