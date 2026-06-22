# =============================================================================
# plot_arena.R — plotly rendering helpers for the box arena
# =============================================================================

# --- box_shapes -------------------------------------------------------------
# Layout shapes drawing the four walls. The right wall is split into two
# segments so the door gap (door_lo..door_hi) is left genuinely open; the gap
# itself is marked with a teal line so the exit reads clearly.
box_shapes <- function(door_lo, door_hi, box_w = 100, box_h = 100) {
  wall <- function(x0, y0, x1, y1, color = COL_WALL, width = 3, dash = "solid") {
    list(type = "line", x0 = x0, y0 = y0, x1 = x1, y1 = y1,
         line = list(color = color, width = width, dash = dash), layer = "below")
  }
  list(
    wall(0, 0, 0, box_h),                       # left wall
    wall(0, box_h, box_w, box_h),               # top wall
    wall(0, 0, box_w, 0),                        # bottom wall
    wall(box_w, 0, box_w, door_lo),              # right wall, below the door
    wall(box_w, door_hi, box_w, box_h),          # right wall, above the door
    # The open door, marked (not blocked) with a dashed teal line:
    wall(box_w, door_lo, box_w, door_hi,
         color = COL_ESCAPED, width = 4, dash = "dot")
  )
}

# --- arena_base -------------------------------------------------------------
# Build the base figure once: a "trapped" trace (index 0) and an "escaped"
# trace (index 1), the walls, and an EXIT label. The animation then updates
# only the two traces' x/y via plotlyProxy — no full redraws.
arena_base <- function(swarm, door_lo, door_hi) {
  act <- swarm$active
  plot_ly() %>%
    add_trace(
      x = swarm$x[act], y = swarm$y[act],
      type = "scattergl", mode = "markers", name = "Trapped",
      marker = list(color = COL_TRAPPED, size = 7, line = list(width = 0)),
      hoverinfo = "none"
    ) %>%
    add_trace(
      x = swarm$x[!act], y = swarm$y[!act],
      type = "scattergl", mode = "markers", name = "Escaped",
      marker = list(color = COL_ESCAPED, size = 7, opacity = 0.7),
      hoverinfo = "none"
    ) %>%
    layout(
      # NOTE: do NOT set scaleanchor here. Combined with two fixed ranges it
      # makes plotly zoom into a tiny sub-window (only the EXIT region showed,
      # the box and trapped points fell off-screen). Honour the explicit ranges
      # instead; VIEW_X/VIEW_Y are proportioned so the box reads roughly square.
      xaxis = list(range = VIEW_X, zeroline = FALSE, showgrid = FALSE,
                   showticklabels = FALSE, title = "", fixedrange = TRUE),
      yaxis = list(range = VIEW_Y, zeroline = FALSE, showgrid = FALSE,
                   showticklabels = FALSE, title = "", fixedrange = TRUE),
      shapes = box_shapes(door_lo, door_hi),
      annotations = list(list(
        x = BOX_W + 12, y = (door_lo + door_hi) / 2,
        text = "EXIT", showarrow = FALSE,
        font = list(color = COL_ESCAPED, size = 14)
      )),
      showlegend = TRUE,
      legend = list(orientation = "h", x = 0, y = 1.05),
      margin = list(l = 10, r = 10, t = 10, b = 10)
    ) %>%
    config(displayModeBar = FALSE)
}
