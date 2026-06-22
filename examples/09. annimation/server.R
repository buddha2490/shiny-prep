# =============================================================================
# server.R — drives the random-walk escape simulation
# =============================================================================

server <- function(input, output, session) {

  # --- Reactive state --------------------------------------------------------
  # `swarm` holds the physics state (plain list from sim_engine). The rest are
  # bookkeeping counters that fan out to the counters, stats, and histogram.
  rv <- reactiveValues(
    swarm        = NULL,
    door_lo      = 40,
    door_hi      = 60,
    n            = 100L,
    step         = 0L,
    n_escaped    = 0L,
    running      = FALSE,
    finished     = FALSE,
    escape_tick  = 0L,   # bumps only when someone escapes (drives stats/hist)
    rebuild      = 0L    # bumps on reset (forces a fresh base plot)
  )

  # A single proxy reused for every per-frame restyle.
  proxy <- plotlyProxy("arena", session)

  # --- (Re)initialise the swarm ---------------------------------------------
  init_swarm <- function() {
    door_h <- input$door_h
    rv$n        <- input$n_points
    rv$door_lo  <- BOX_H / 2 - door_h / 2
    rv$door_hi  <- BOX_H / 2 + door_h / 2
    rv$swarm    <- new_swarm(input$n_points, BOX_W, BOX_H)
    rv$step     <- 0L
    rv$n_escaped <- 0L
    rv$running  <- FALSE
    rv$finished <- FALSE
    rv$escape_tick <- rv$escape_tick + 1L
    rv$rebuild  <- rv$rebuild + 1L
    updateActionButton(session, "toggle", label = "Start", icon = icon("play"))
  }

  # Build the first swarm once the session is ready (inputs have their defaults).
  observeEvent(TRUE, init_swarm(), once = TRUE)

  # Reset rebuilds from scratch; changing the swarm size or door while paused
  # re-seeds too, so the controls feel live.
  observeEvent(input$reset, init_swarm())
  observeEvent(c(input$n_points, input$door_h), {
    if (!rv$running) init_swarm()
  }, ignoreInit = TRUE)

  # --- Start / pause toggle --------------------------------------------------
  observeEvent(input$toggle, {
    if (rv$finished) init_swarm()        # a finished run restarts cleanly
    rv$running <- !rv$running
    updateActionButton(
      session, "toggle",
      label = if (rv$running) "Pause" else "Resume",
      icon  = icon(if (rv$running) "pause" else "play")
    )
  })

  # --- The animation loop ----------------------------------------------------
  # Re-arms itself via invalidateLater while running. Reading rv$running outside
  # isolate() makes the loop start/stop when the toggle flips; everything else
  # is isolated so the only triggers are the timer and that flag.
  observe({
    if (!rv$running) return()
    invalidateLater(input$delay)

    isolate({
      step_size <- input$step_size
      door_lo   <- rv$door_lo
      door_hi   <- rv$door_hi
      swarm     <- rv$swarm
      escaped_this_frame <- FALSE

      # Advance several physics steps per rendered frame so the sim can run fast
      # without flooding the browser with restyles.
      for (k in seq_len(input$steps_per_frame)) {
        res   <- advance(swarm, step_size, door_lo, door_hi, BOX_W, BOX_H)
        swarm <- res$swarm
        rv$step <- rv$step + 1L
        if (length(res$newly_escaped)) {
          swarm$escape_step[res$newly_escaped] <- rv$step
          escaped_this_frame <- TRUE
        }
      }

      rv$swarm     <- swarm
      rv$n_escaped <- sum(!swarm$active)
      if (escaped_this_frame) rv$escape_tick <- rv$escape_tick + 1L

      # Push new positions to the two traces in one restyle.
      act <- swarm$active
      plotlyProxyInvoke(
        proxy, "restyle",
        list(x = list(swarm$x[act], swarm$x[!act]),
             y = list(swarm$y[act], swarm$y[!act])),
        list(0, 1)
      )

      # Stop when the box is empty.
      if (rv$n_escaped >= rv$n) {
        rv$running  <- FALSE
        rv$finished <- TRUE
        updateActionButton(session, "toggle",
                           label = "Run again", icon = icon("rotate-right"))
      }
    })
  })

  # --- Base plot (rebuilt only on reset) ------------------------------------
  output$arena <- renderPlotly({
    rv$rebuild
    isolate(arena_base(rv$swarm, rv$door_lo, rv$door_hi))
  })

  # --- Live counters ---------------------------------------------------------
  output$vb_escaped   <- renderText(rv$n_escaped)
  output$vb_remaining <- renderText(rv$n - rv$n_escaped)
  output$vb_step      <- renderText(format(rv$step, big.mark = ","))

  # --- Escape-time stats (update only when someone escapes) ------------------
  output$stats <- renderUI({
    rv$escape_tick
    isolate({
      s <- escape_summary(rv$swarm$escape_step)
      if (s$n == 0) {
        return(div(class = "text-muted",
                   "No escapes yet — press Start."))
      }
      stat <- function(label, value) {
        div(
          class = "d-flex justify-content-between border-bottom py-1",
          span(class = "text-muted", label),
          span(class = "fw-bold", value)
        )
      }
      tagList(
        stat("Escaped", sprintf("%d of %d", s$n, rv$n)),
        stat("Fastest (min)",  sprintf("%d steps", s$min)),
        stat("Average (mean)", sprintf("%.0f steps", s$mean)),
        stat("Slowest (max)",  sprintf("%d steps", s$max))
      )
    })
  })

  # --- Escape-time distribution ---------------------------------------------
  output$hist <- renderPlotly({
    rv$escape_tick
    isolate({
      ts <- rv$swarm$escape_step[!is.na(rv$swarm$escape_step)]
      if (length(ts) == 0) {
        return(
          plot_ly(type = "histogram") %>%
            layout(
              xaxis = list(title = "Steps to escape"),
              yaxis = list(title = "Count"),
              margin = list(l = 40, r = 10, t = 10, b = 40)
            ) %>%
            config(displayModeBar = FALSE)
        )
      }
      plot_ly(x = ts, type = "histogram",
              marker = list(color = COL_ESCAPED,
                            line = list(color = "white", width = 1))) %>%
        layout(
          xaxis = list(title = "Steps to escape"),
          yaxis = list(title = "Count"),
          bargap = 0.05,
          margin = list(l = 40, r = 10, t = 10, b = 40)
        ) %>%
        config(displayModeBar = FALSE)
    })
  })
}
