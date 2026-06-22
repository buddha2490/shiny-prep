# =============================================================================
# sim_engine.R — pure random-walk-escape simulation
# -----------------------------------------------------------------------------
# Kept free of Shiny so the physics can be unit-tested in isolation. The server
# owns the reactive state; these functions just transform a plain state list.
# =============================================================================

# --- new_swarm --------------------------------------------------------------
# Build a fresh swarm of `n` particles placed uniformly inside the box (away
# from the walls so none start mid-escape). Returns a plain list — the unit of
# state the server stores in reactiveValues and feeds back into `advance()`.
new_swarm <- function(n, box_w = 100, box_h = 100, margin = 5) {
  if (n < 1) stop("`n` must be at least 1.", call. = FALSE)
  list(
    x      = runif(n, margin, box_w - margin),
    y      = runif(n, margin, box_h - margin),
    active = rep(TRUE, n),                 # TRUE = still trapped in the box
    escape_step = rep(NA_real_, n)         # step index at which each escaped
  )
}

# --- advance ----------------------------------------------------------------
# Move every particle one random-walk step and return the updated swarm plus the
# indices that escaped on this step.
#
#   * Trapped particles take a step of fixed length in a uniformly random
#     direction, then reflect off any wall they cross — except the door gap on
#     the right wall (door_lo..door_hi), through which they escape.
#   * Escaped particles keep walking with a slight rightward drift and ignore
#     the walls, so they visibly stream out of the box and off-screen.
advance <- function(swarm, step_size, door_lo, door_hi,
                    box_w = 100, box_h = 100) {
  n   <- length(swarm$x)
  ang <- runif(n, 0, 2 * pi)
  nx  <- swarm$x + cos(ang) * step_size
  ny  <- swarm$y + sin(ang) * step_size

  active <- swarm$active

  # --- Escaped particles: free drift, no walls -------------------------------
  nx[!active] <- nx[!active] + step_size * 0.6   # gentle nudge toward the exit

  # --- Trapped particles: reflect off the four walls -------------------------
  hit <- active & nx < 0;     nx[hit] <- -nx[hit]                 # left
  hit <- active & ny < 0;     ny[hit] <- -ny[hit]                 # bottom
  hit <- active & ny > box_h; ny[hit] <- 2 * box_h - ny[hit]      # top

  # Right wall is special: a particle crossing it through the door gap escapes;
  # otherwise it reflects like any other wall.
  cross_right  <- active & nx > box_w
  through_door <- cross_right & ny >= door_lo & ny <= door_hi
  reflect_r    <- cross_right & !through_door
  nx[reflect_r] <- 2 * box_w - nx[reflect_r]

  newly_escaped <- which(through_door)

  swarm$x <- nx
  swarm$y <- ny
  swarm$active[newly_escaped] <- FALSE

  list(swarm = swarm, newly_escaped = newly_escaped)
}

# --- escape_summary ---------------------------------------------------------
# Min / mean / max escape time (in steps) over the particles that have escaped.
# Returns NA fields when nobody has escaped yet so callers can branch cleanly.
escape_summary <- function(escape_step) {
  ts <- escape_step[!is.na(escape_step)]
  if (length(ts) == 0) {
    return(list(n = 0L, min = NA_real_, mean = NA_real_, max = NA_real_))
  }
  list(
    n    = length(ts),
    min  = min(ts),
    mean = mean(ts),
    max  = max(ts)
  )
}
