# --- Reusable Plotly Theme Helper ---------------------------------------------
# Apply a consistent house style to any plot_ly or ggplotly object.
# Usage:
#   plot_ly(...) %>% apply_plotly_theme()
#   ggplotly(p)  %>% apply_plotly_theme()
#
# This centralizes styling so every plot in the app looks cohesive.
# Modify this ONE function to restyle all plots at once.

apply_plotly_theme <- function(p,
                               show_modebar = TRUE,
                               export_filename = "plot",
                               export_format = "svg",
                               scroll_zoom = FALSE) {

  p %>%
    layout(
      # --- Background colors ---
      plot_bgcolor  = "white",
      paper_bgcolor = "white",

      # --- Default axis styling ---
      xaxis = list(
        showgrid   = FALSE,
        zeroline   = FALSE,
        gridcolor  = "#f0f0f0",
        linecolor  = "#cccccc",
        tickfont   = list(size = 11, color = "#555"),
        titlefont  = list(size = 13, color = "#333")
      ),
      yaxis = list(
        gridcolor  = "#f0f0f0",
        zeroline   = FALSE,
        linecolor  = "#cccccc",
        tickfont   = list(size = 11, color = "#555"),
        titlefont  = list(size = 13, color = "#333")
      ),

      # --- Margins ---
      margin = list(t = 40, b = 60, l = 60, r = 20),

      # --- Legend ---
      legend = list(
        bgcolor     = "rgba(255,255,255,0.9)",
        bordercolor = "#ddd",
        borderwidth = 1,
        font        = list(size = 11)
      ),

      # --- Hover ---
      hoverlabel = list(
        bgcolor  = "white",
        bordercolor = "#999",
        font = list(size = 12, color = "#333")
      ),

      hovermode = "closest"
    ) %>%
    config(
      displayModeBar = show_modebar,
      modeBarButtonsToRemove = list("autoScale2d", "toggleSpikelines"),
      toImageButtonOptions = list(
        format   = export_format,
        filename = export_filename,
        width    = 1600,
        height   = 600,
        scale    = 2
      ),
      scrollZoom = scroll_zoom
    )
}

# --- Helper: add a horizontal threshold line ---------------------------------
# Returns a shape list item for use in layout(shapes = ...)
make_hline <- function(y, color = "#E41A1C", width = 1.5,
                       dash = "dash", x0 = 0, x1 = 1,
                       xref = "paper") {
  list(
    type = "line",
    x0 = x0, x1 = x1,
    y0 = y,  y1 = y,
    xref = xref,
    line = list(color = color, width = width, dash = dash)
  )
}

# --- Helper: add a label annotation for a threshold line ---------------------
make_hline_label <- function(y, text, color = "#E41A1C",
                             x = 1, xanchor = "right",
                             xref = "paper") {
  list(
    x = x, y = y,
    xref = xref,
    text = text,
    showarrow = FALSE,
    xanchor = xanchor,
    font = list(color = color, size = 10)
  )
}

# --- Helper: create an empty placeholder plot --------------------------------
# Use when no data is available or no selection has been made.
empty_plot <- function(message = "No data to display") {
  plot_ly() %>%
    layout(
      xaxis = list(visible = FALSE),
      yaxis = list(visible = FALSE),
      annotations = list(
        list(
          text = message,
          xref = "paper", yref = "paper",
          x = 0.5, y = 0.5,
          showarrow = FALSE,
          font = list(size = 14, color = "#999")
        )
      ),
      plot_bgcolor = "white",
      paper_bgcolor = "white"
    ) %>%
    config(displayModeBar = FALSE)
}

# --- Matching ggplot2 theme for ggplotly conversion --------------------------
# Use this as the base theme in ggplot2 before converting with ggplotly()
# so the ggplot and plotly styling are consistent.
theme_plotly_clean <- function(base_size = 12) {
  ggplot2::theme_minimal(base_size = base_size) +
    ggplot2::theme(
      panel.grid.major.x = ggplot2::element_blank(),
      panel.grid.minor   = ggplot2::element_blank(),
      panel.grid.major.y = ggplot2::element_line(color = "#f0f0f0"),
      axis.line          = ggplot2::element_line(color = "#cccccc", linewidth = 0.3),
      axis.ticks         = ggplot2::element_line(color = "#cccccc"),
      plot.title         = ggplot2::element_text(size = 14, face = "bold", color = "#333"),
      plot.subtitle      = ggplot2::element_text(size = 11, color = "#666"),
      axis.title         = ggplot2::element_text(size = 12, color = "#333"),
      axis.text          = ggplot2::element_text(size = 10, color = "#555"),
      legend.position    = "right"
    )
}
