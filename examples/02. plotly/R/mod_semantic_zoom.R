# --- Module: Semantic Zoom (Level of Detail) ---------------------------------
# Demonstrates:
#   - plotly_relayout event: react to zoom/pan to get current viewport
#   - Dynamic level-of-detail (LOD): show fewer points when zoomed out,
#     more points (or full resolution) when zoomed in
#   - plotlyProxy for efficient data updates on zoom
#   - Binned aggregation: when too many points, show bin summaries instead
#   - Adaptive downsampling based on viewport width
#
# WHY THIS MATTERS:
#   This is the most advanced performance pattern. Instead of downsampling
#   globally (losing data everywhere), you show full detail ONLY where the
#   user is looking. Zoom out → aggregated overview. Zoom in → full resolution.
#   This makes 10M-point datasets interactive without lag.
#
# HOW IT WORKS:
#   1. Start with a coarse overview (1% sample)
#   2. User zooms in via plotly's built-in zoom
#   3. plotly_relayout fires with the new x-axis range
#   4. Server queries the FULL dataset for that range
#   5. If the region has <50K points, show all; otherwise downsample to 50K
#   6. Update the plot via plotlyProxy (no full re-render)

# --- UI ----------------------------------------------------------------------

mod_semantic_zoom_ui <- function(id) {
  ns <- NS(id)

  layout_sidebar(
    sidebar = sidebar(
      width = 300,
      title = "Semantic Zoom",

      helpText(
        tags$strong("How to use:"),
        "Zoom into the plot using the plotly zoom tool or scroll wheel.",
        "As you zoom in, the server loads higher-resolution data for",
        "the visible region."
      ),

      hr(),

      # --- LOD settings ------------------------------------------------------
      numericInput(
        ns("max_points"), "Max points per viewport",
        value = 50000, min = 5000, max = 200000, step = 5000
      ),
      helpText("When a region has more points than this, it downsamples to this target."),

      hr(),

      # --- Status display ----------------------------------------------------
      tags$h6("Current View Status"),
      tags$div(
        class = "small",
        tags$table(
          class = "table table-sm table-borderless",
          tags$tr(
            tags$th("Viewport:"),
            tags$td(textOutput(ns("viewport_info"), inline = TRUE))
          ),
          tags$tr(
            tags$th("Points in range:"),
            tags$td(textOutput(ns("points_in_range"), inline = TRUE))
          ),
          tags$tr(
            tags$th("Points rendered:"),
            tags$td(textOutput(ns("points_rendered"), inline = TRUE))
          ),
          tags$tr(
            tags$th("Resolution:"),
            tags$td(textOutput(ns("resolution_pct"), inline = TRUE))
          )
        )
      ),

      hr(),

      actionButton(ns("reset_zoom"), "Reset to Full Genome",
                   class = "btn-outline-secondary w-100"),

      hr(),

      # --- Aggregation mode --------------------------------------------------
      radioButtons(
        ns("zoom_mode"), "Zoom-out strategy:",
        choices = c(
          "Downsample (random thin)" = "downsample",
          "Bin + summarize (max per bin)" = "binned"
        ),
        selected = "downsample"
      ),
      helpText(
        "Downsample: random subset. Fast but can miss peaks.",
        "Binned: divide x-axis into bins, keep the most significant SNP per bin.",
        "Binned is slower but never drops important signals."
      )
    ),

    # --- Main content --------------------------------------------------------
    layout_columns(
      col_widths = 12,

      card(
        card_header(
          class = "d-flex justify-content-between align-items-center",
          "Semantic Zoom Manhattan",
          span(class = "badge bg-info", textOutput(ns("lod_label"), inline = TRUE))
        ),
        card_body(
          class = "p-1",
          plotlyOutput(ns("zoom_manhattan"), height = "550px")
        ),
        card_footer(
          class = "small text-muted",
          "Zoom in with the plotly zoom tool or scroll wheel. The server",
          "automatically loads full-resolution data for the visible region."
        ),
        full_screen = TRUE
      ),

      card(
        card_header("How Semantic Zoom Works"),
        card_body(
          tags$ol(
            tags$li(tags$code("plotly_relayout"), " fires whenever the user zooms or pans"),
            tags$li("The event contains ", tags$code("xaxis.range[0]"), " and ",
                    tags$code("xaxis.range[1]"), " — the current viewport boundaries"),
            tags$li("The server queries the full 10M-row dataset for points in that range"),
            tags$li("If the count exceeds the max, it downsamples or bins to the target"),
            tags$li(tags$code("plotlyProxy"), " updates the traces without re-rendering the layout")
          )
        )
      )
    )
  )
}

# --- Server ------------------------------------------------------------------

mod_semantic_zoom_server <- function(id) {
  moduleServer(id, function(input, output, session) {

    # --- Track current viewport ----------------------------------------------
    current_range <- reactiveValues(
      x_min = min(gwas$bp_cum),
      x_max = max(gwas$bp_cum),
      full_in_range = nrow(gwas),
      rendered = 0
    )

    # --- Initial coarse render -----------------------------------------------
    initial_data <- {
      # Start with 1% sample + all significant
      sig <- gwas[neglog10p >= SUGGESTIVE_SIG]
      nonsig <- gwas[neglog10p < SUGGESTIVE_SIG]
      set.seed(999)
      n_sample <- round(nrow(nonsig) * 0.01)
      sampled <- nonsig[sample.int(nrow(nonsig), n_sample)]
      result <- rbindlist(list(sig, sampled))
      setorder(result, chr, pos)
      result[, neglog10p_capped := pmin(neglog10p, 30)]
      result
    }

    output$zoom_manhattan <- renderPlotly({
      current_range$rendered <- nrow(initial_data)

      p <- plot_ly(source = session$ns("semantic"))

      for (ch in 1:23) {
        dd <- initial_data[chr == ch]
        p <- p %>%
          add_trace(
            data = dd,
            x = ~bp_cum, y = ~neglog10p_capped,
            type = "scattergl", mode = "markers",
            marker = list(size = 2, color = CHR_COLORS[ch], opacity = 0.5),
            text = ~paste0(
              "<b>Chr ", chr, "</b><br>",
              "Position: ", format(pos, big.mark = ","), " bp<br>",
              "p-value: ", formatC(pvalue, format = "e", digits = 2)
            ),
            hoverinfo = "text",
            name = paste("Chr", ch),
            showlegend = FALSE
          )
      }

      p %>%
        layout(
          xaxis = list(
            title = "Chromosome",
            tickvals = chr_ticks$center,
            ticktext = chr_ticks$chr,
            showgrid = FALSE, zeroline = FALSE
          ),
          yaxis = list(
            title = "-log<sub>10</sub>(p)",
            range = c(0, 31), gridcolor = "#f0f0f0"
          ),
          shapes = list(
            make_hline(GENOME_WIDE_SIG, color = "#E41A1C"),
            make_hline(SUGGESTIVE_SIG, color = "#377EB8", width = 1, dash = "dot")
          ),
          plot_bgcolor = "white", paper_bgcolor = "white",
          margin = list(t = 40, b = 60, l = 60, r = 20),
          hovermode = "closest"
        ) %>%
        config(scrollZoom = TRUE)
    })

    proxy <- plotlyProxy("zoom_manhattan", session)

    # --- Listen for zoom/pan events ------------------------------------------
    # plotly_relayout returns the new axis ranges after zoom/pan.
    # The key fields are:
    #   xaxis.range[0], xaxis.range[1] — x-axis bounds
    #   yaxis.range[0], yaxis.range[1] — y-axis bounds
    # On autorange or reset, it returns xaxis.autorange = TRUE instead.
    observeEvent(event_data("plotly_relayout", source = session$ns("semantic")), {
      ev <- event_data("plotly_relayout", source = session$ns("semantic"))

      # Check if this is a zoom event (has x-axis range)
      x_min <- ev[["xaxis.range[0]"]]
      x_max <- ev[["xaxis.range[1]"]]

      # If autorange was triggered, reset to full genome
      if (!is.null(ev[["xaxis.autorange"]])) {
        x_min <- min(gwas$bp_cum)
        x_max <- max(gwas$bp_cum)
      }

      if (is.null(x_min) || is.null(x_max)) return()

      current_range$x_min <- x_min
      current_range$x_max <- x_max

      # --- Query full dataset for this viewport -----------------------------
      region <- gwas[bp_cum >= x_min & bp_cum <= x_max]
      current_range$full_in_range <- nrow(region)

      max_pts <- input$max_points

      if (nrow(region) <= max_pts) {
        # Full resolution — show everything
        display <- region
      } else if (input$zoom_mode == "binned") {
        # --- Binned aggregation ----------------------------------------------
        # Divide the x-range into bins, keep the SNP with the highest
        # -log10(p) in each bin. This preserves peaks.
        n_bins <- max_pts
        region[, bin := cut(bp_cum, breaks = n_bins, labels = FALSE)]
        display <- region[, .SD[which.max(neglog10p)], by = bin]
        display[, bin := NULL]
      } else {
        # --- Random downsample -----------------------------------------------
        # Always keep significant SNPs
        sig <- region[neglog10p >= SUGGESTIVE_SIG]
        nonsig <- region[neglog10p < SUGGESTIVE_SIG]
        n_take <- max(1, max_pts - nrow(sig))
        if (nrow(nonsig) > n_take) {
          nonsig <- nonsig[sample.int(nrow(nonsig), n_take)]
        }
        display <- rbindlist(list(sig, nonsig))
      }

      setorder(display, chr, pos)
      display[, neglog10p_capped := pmin(neglog10p, 30)]
      current_range$rendered <- nrow(display)

      # --- Update via proxy (one trace per chromosome) ----------------------
      # First, delete all existing traces, then add new ones
      # This is cleaner than trying to match trace indices
      n_existing <- length(unique(initial_data$chr))
      # Delete traces from last to first (indices shift as you delete)
      for (i in rev(seq_len(n_existing)) - 1) {
        plotlyProxyInvoke(proxy, "deleteTraces", list(i))
      }

      # Add new traces for chromosomes present in the viewport
      chr_list <- sort(unique(display$chr))
      for (ch in chr_list) {
        dd <- display[chr == ch]
        plotlyProxyInvoke(
          proxy, "addTraces",
          list(
            x = dd$bp_cum,
            y = dd$neglog10p_capped,
            type = "scattergl",
            mode = "markers",
            marker = list(size = 2.5, color = CHR_COLORS[ch], opacity = 0.6),
            text = paste0(
              "<b>Chr ", dd$chr, "</b><br>",
              "Position: ", format(dd$pos, big.mark = ","), " bp<br>",
              "p-value: ", formatC(dd$pvalue, format = "e", digits = 2)
            ),
            hoverinfo = "text",
            name = paste("Chr", ch),
            showlegend = FALSE
          )
        )
      }
    })

    # --- Reset zoom ----------------------------------------------------------
    observeEvent(input$reset_zoom, {
      plotlyProxyInvoke(proxy, "relayout", list(
        `xaxis.range` = list(min(gwas$bp_cum), max(gwas$bp_cum)),
        `xaxis.autorange` = TRUE
      ))
    })

    # --- Status outputs ------------------------------------------------------
    output$viewport_info <- renderText({
      # Try to identify which chromosomes are in view
      chrs_in_view <- unique(gwas[bp_cum >= current_range$x_min &
                                  bp_cum <= current_range$x_max, chr])
      if (length(chrs_in_view) > 5) {
        paste0("Chr ", min(chrs_in_view), "-", max(chrs_in_view))
      } else {
        paste0("Chr ", paste(chrs_in_view, collapse = ", "))
      }
    })

    output$points_in_range <- renderText({
      format(current_range$full_in_range, big.mark = ",")
    })

    output$points_rendered <- renderText({
      format(current_range$rendered, big.mark = ",")
    })

    output$resolution_pct <- renderText({
      if (current_range$full_in_range == 0) return("N/A")
      pct <- current_range$rendered / current_range$full_in_range * 100
      if (pct >= 100) "Full resolution" else paste0(round(pct, 1), "%")
    })

    output$lod_label <- renderText({
      if (current_range$full_in_range == 0) return("N/A")
      pct <- current_range$rendered / current_range$full_in_range * 100
      if (pct >= 100) "FULL RES" else paste0("LOD: ", round(pct, 1), "%")
    })
  })
}
