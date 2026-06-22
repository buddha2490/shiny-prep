# =============================================================================
# ui.R — Random-walk escape animation
# =============================================================================

ui <- page_sidebar(
  title = "Random-Walk Escape",
  theme = bs_theme(version = 5, bootswatch = "flatly"),

  # --- Controls --------------------------------------------------------------
  sidebar = sidebar(
    width = 300,
    title = "Controls",

    sliderInput("n_points", "Number of points",
                min = 10, max = 500, value = 100, step = 10),
    sliderInput("door_h", "Door height",
                min = 4, max = 80, value = 24, step = 2),
    sliderInput("step_size", "Step size",
                min = 0.5, max = 5, value = 2.5, step = 0.5),
    sliderInput("steps_per_frame", "Simulation speed (steps / frame)",
                min = 1, max = 40, value = 8, step = 1),
    sliderInput("delay", "Frame delay (ms)",
                min = 10, max = 200, value = 30, step = 10),

    div(
      class = "d-grid gap-2 mt-2",
      actionButton("toggle", "Start", icon = icon("play"),
                   class = "btn-success"),
      actionButton("reset", "Reset", icon = icon("rotate-left"),
                   class = "btn-outline-secondary")
    ),

    hr(),
    helpText(
      "100 points random-walk inside the box, bouncing off the walls. ",
      "The teal gap on the right wall is the only exit. As each point ",
      "stumbles into it, it escapes and drifts away. The run ends when ",
      "every point has escaped."
    )
  ),

  # --- Live counters ---------------------------------------------------------
  layout_columns(
    fill = FALSE,
    value_box(
      "Escaped", textOutput("vb_escaped"),
      showcase = bs_icon("door-open-fill"), theme = "success"
    ),
    value_box(
      "Still trapped", textOutput("vb_remaining"),
      showcase = bs_icon("box-fill"), theme = "primary"
    ),
    value_box(
      "Step", textOutput("vb_step"),
      showcase = bs_icon("clock-history"), theme = "secondary"
    )
  ),

  # --- The arena + escape-time analytics ------------------------------------
  layout_columns(
    col_widths = c(8, 4),
    card(
      full_screen = TRUE,
      card_header("The box"),
      plotlyOutput("arena", height = "520px")
    ),
    card(
      card_header("Escape-time stats"),
      uiOutput("stats"),
      plotlyOutput("hist", height = "260px")
    )
  )
)
