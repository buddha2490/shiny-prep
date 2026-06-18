# --- UI Definition -----------------------------------------------------------
# Tabbed navbar app: each tab demonstrates a different plotly pattern.

ui <- page_navbar(
  title = "Plotly Reference App",
  id = "main_nav",
  theme = bs_theme(
    version = 5,
    bootswatch = "flatly",
    base_font = font_google("Inter")
  ),

  # --- Tab 1: Manhattan Plot -------------------------------------------------
  # Core patterns: scattergl, downsampling, shapes, annotations, events,
  # click/select handlers, range slider, data download
  nav_panel(
    title = "Manhattan",
    icon = icon("chart-scatter-3d"),
    mod_manhattan_ui("manhattan")
  ),

  # --- Tab 2: Proxy Updates --------------------------------------------------
  # Core patterns: plotlyProxy, restyle, relayout, addTraces/deleteTraces,
  # updatemenus (client-side buttons), secondary y-axis
  nav_panel(
    title = "Proxy Updates",
    icon = icon("sliders"),
    mod_proxy_ui("proxy")
  ),

  # --- Tab 3: ggplotly -------------------------------------------------------
  # Core patterns: ggplot2→plotly conversion, tooltip cleanup, legend fix,
  # geom_ribbon→add_ribbons, continuous color scale, raw vs cleaned comparison
  nav_panel(
    title = "ggplotly",
    icon = icon("arrows-rotate"),
    mod_ggplotly_ui("ggplotly")
  ),

  # --- Tab 4: Linked Views ---------------------------------------------------
  # Core patterns: highlight_key/SharedData, subplot, crosstalk brushing,
  # persistent vs transient selection, attrs_selected
  nav_panel(
    title = "Linked Views",
    icon = icon("link"),
    mod_linked_ui("linked")
  ),

  # --- Tab 5: Semantic Zoom --------------------------------------------------
  # Core patterns: plotly_relayout event, level-of-detail rendering,
  # adaptive downsampling, binned aggregation, proxy-based data swap
  nav_panel(
    title = "Semantic Zoom",
    icon = icon("magnifying-glass-plus"),
    mod_semantic_zoom_ui("semantic_zoom")
  ),

  # --- About / Reference nav -------------------------------------------------
  nav_spacer(),
  nav_item(
    tags$a(
      href = "https://plotly.com/r/reference/",
      target = "_blank",
      icon("book"), "Plotly R Docs"
    )
  )
)
