# --- Module: Proxy Updates ----------------------------------------------------
# Demonstrates:
#   - plotlyProxy() + plotlyProxyInvoke() to update plots WITHOUT full re-render
#   - Restyle: change marker size, opacity, color on existing traces
#   - Relayout: change axis ranges, titles, background
#   - Add/remove shapes (threshold lines) via proxy
#   - Add annotations on click via proxy
#   - updatemenus: built-in dropdown/toggle buttons (no server round-trip)
#   - Secondary y-axis overlay
#
# WHY THIS MATTERS:
#   renderPlotly() destroys and rebuilds the entire plot widget on every call.
#   For large datasets, this is the primary source of lag. plotlyProxy() sends
#   only the DIFF to the browser, keeping the WebGL context alive. Use it for
#   any change that doesn't add/remove data points.

# --- UI ----------------------------------------------------------------------

mod_proxy_ui <- function(id) {
  ns <- NS(id)

  layout_sidebar(
    sidebar = sidebar(
      width = 300,
      title = "Proxy Controls",

      helpText(
        "These controls update the plot through plotlyProxy —",
        "no full re-render, just a lightweight message to the browser."
      ),

      hr(),

      # --- Restyle controls --------------------------------------------------
      tags$h6("Restyle (trace properties)"),
      sliderInput(ns("proxy_size"), "Marker size", 1, 8, 3, step = 0.5),
      sliderInput(ns("proxy_opacity"), "Marker opacity", 0.1, 1, 0.5, step = 0.05),
      selectInput(
        ns("proxy_colorscale"), "Color scheme",
        choices = c(
          "Default (alternating)" = "default",
          "Viridis" = "viridis",
          "Blues" = "blues",
          "Reds" = "reds"
        )
      ),
      actionButton(ns("apply_restyle"), "Apply Restyle", class = "btn-outline-primary btn-sm w-100"),

      hr(),

      # --- Relayout controls -------------------------------------------------
      tags$h6("Relayout (axis / layout)"),
      selectInput(
        ns("proxy_chr_zoom"), "Zoom to chromosome",
        choices = c("Full genome" = "all", setNames(1:23, paste("Chr", 1:23)))
      ),
      actionButton(ns("apply_zoom"), "Apply Zoom", class = "btn-outline-primary btn-sm w-100"),

      hr(),

      # --- Shapes via proxy --------------------------------------------------
      tags$h6("Shapes via proxy"),
      checkboxInput(ns("proxy_gw_line"), "Genome-wide line", TRUE),
      checkboxInput(ns("proxy_sg_line"), "Suggestive line", TRUE),
      actionButton(ns("apply_shapes"), "Apply Shapes", class = "btn-outline-primary btn-sm w-100"),

      hr(),

      # --- Annotations via click ---------------------------------------------
      tags$h6("Click to annotate"),
      checkboxInput(ns("click_annotate"), "Add annotation on click", FALSE),
      actionButton(ns("clear_annotations"), "Clear all annotations",
                   class = "btn-outline-secondary btn-sm w-100"),

      hr(),

      # --- Secondary y-axis demo --------------------------------------------
      tags$h6("Secondary Y-axis"),
      checkboxInput(ns("show_cumulative"), "Overlay cumulative distribution", FALSE),
      helpText("Adds a second trace on a right-side y-axis.")
    ),

    # --- Main content --------------------------------------------------------
    layout_columns(
      col_widths = 12,

      card(
        card_header("Proxy-Controlled Manhattan Plot"),
        card_body(
          class = "p-1",
          plotlyOutput(ns("proxy_plot"), height = "550px")
        ),
        card_footer(
          class = "small text-muted",
          "All sidebar controls use plotlyProxy — check the Network tab in DevTools",
          "to confirm no full plot payloads are sent."
        ),
        full_screen = TRUE
      )
    )
  )
}

# --- Server ------------------------------------------------------------------

mod_proxy_server <- function(id) {
  moduleServer(id, function(input, output, session) {

    # --- Prepare a fixed downsampled dataset for this tab --------------------
    # We render once and then only modify via proxy
    proxy_data <- {
      sig_rows <- gwas[neglog10p >= SUGGESTIVE_SIG]
      nonsig_rows <- gwas[neglog10p < SUGGESTIVE_SIG]
      set.seed(456)
      n_sample <- round(nrow(nonsig_rows) * 0.01)
      nonsig_sample <- nonsig_rows[sample.int(nrow(nonsig_rows), n_sample)]
      result <- rbindlist(list(sig_rows, nonsig_sample))
      setorder(result, chr, pos)
      result[, neglog10p_capped := pmin(neglog10p, 30)]
      result
    }

    # Track dynamic annotations added by click
    click_annotations <- reactiveVal(list())

    # --- Initial render (done ONCE) ------------------------------------------
    output$proxy_plot <- renderPlotly({
      p <- plot_ly(source = session$ns("proxy"))

      for (ch in 1:23) {
        dd <- proxy_data[chr == ch]
        p <- p %>%
          add_trace(
            data = dd,
            x = ~bp_cum, y = ~neglog10p_capped,
            type = "scattergl", mode = "markers",
            marker = list(size = 3, color = CHR_COLORS[ch], opacity = 0.5),
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

      # --- updatemenus: built-in buttons (no server round-trip!) -------------
      # These are toggle buttons rendered INTO the plot by plotly.js.
      # They call plotly.js restyle/relayout directly in the browser.
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
            range = c(0, 31),
            gridcolor = "#f0f0f0"
          ),
          shapes = list(
            make_hline(GENOME_WIDE_SIG, color = "#E41A1C"),
            make_hline(SUGGESTIVE_SIG, color = "#377EB8", width = 1, dash = "dot")
          ),
          plot_bgcolor = "white", paper_bgcolor = "white",
          margin = list(t = 50, b = 60, l = 60, r = 80),
          hovermode = "closest",

          # --- updatemenus: client-side toggle buttons -----------------------
          # These buttons live in the plot chrome and call restyle/relayout
          # directly in the browser — zero server involvement.
          updatemenus = list(
            list(
              type = "buttons",
              direction = "right",
              x = 0, y = 1.12,
              xanchor = "left",
              buttons = list(
                list(
                  label = "Log scale",
                  method = "relayout",
                  args = list(list(
                    `yaxis.type` = "log",
                    `yaxis.title` = "log scale -log<sub>10</sub>(p)"
                  ))
                ),
                list(
                  label = "Linear scale",
                  method = "relayout",
                  args = list(list(
                    `yaxis.type` = "linear",
                    `yaxis.title` = "-log<sub>10</sub>(p)"
                  ))
                )
              )
            )
          )
        ) %>%
        config(scrollZoom = TRUE) %>%
        apply_plotly_theme(show_modebar = TRUE, export_filename = "proxy_manhattan")
    })

    # --- Proxy reference -----------------------------------------------------
    proxy <- plotlyProxy("proxy_plot", session)

    # --- RESTYLE: update marker properties on existing traces ----------------
    # plotlyProxyInvoke("restyle", update_object, trace_indices)
    # trace_indices is 0-based in plotly.js
    observeEvent(input$apply_restyle, {
      color_map <- switch(input$proxy_colorscale,
        "viridis" = viridisLite::viridis(23),
        "blues"   = colorRampPalette(c("#deebf7", "#08519c"))(23),
        "reds"    = colorRampPalette(c("#fee0d2", "#a50f15"))(23),
        CHR_COLORS  # default
      )

      # Restyle each trace individually (one per chromosome)
      for (i in 0:22) {
        plotlyProxyInvoke(
          proxy, "restyle",
          list(
            `marker.size`    = input$proxy_size,
            `marker.opacity` = input$proxy_opacity,
            `marker.color`   = color_map[i + 1]
          ),
          list(i)  # 0-based trace index
        )
      }
    })

    # --- RELAYOUT: zoom to chromosome ----------------------------------------
    # plotlyProxyInvoke("relayout", update_object)
    observeEvent(input$apply_zoom, {
      if (input$proxy_chr_zoom == "all") {
        # Reset to full view
        plotlyProxyInvoke(proxy, "relayout", list(
          `xaxis.range` = list(
            min(proxy_data$bp_cum),
            max(proxy_data$bp_cum)
          ),
          `xaxis.title` = "Chromosome"
        ))
      } else {
        ch <- as.integer(input$proxy_chr_zoom)
        chr_d <- proxy_data[chr == ch]
        padding <- (max(chr_d$bp_cum) - min(chr_d$bp_cum)) * 0.05
        plotlyProxyInvoke(proxy, "relayout", list(
          `xaxis.range` = list(
            min(chr_d$bp_cum) - padding,
            max(chr_d$bp_cum) + padding
          ),
          `xaxis.title` = paste("Chromosome", ch, "position")
        ))
      }
    })

    # --- RELAYOUT: update shapes (threshold lines) ---------------------------
    observeEvent(input$apply_shapes, {
      shapes <- list()
      if (input$proxy_gw_line) {
        shapes <- c(shapes, list(make_hline(GENOME_WIDE_SIG, color = "#E41A1C")))
      }
      if (input$proxy_sg_line) {
        shapes <- c(shapes, list(
          make_hline(SUGGESTIVE_SIG, color = "#377EB8", width = 1, dash = "dot")
        ))
      }
      # Merge current click annotations back in
      all_annotations <- click_annotations()

      plotlyProxyInvoke(proxy, "relayout", list(
        shapes = shapes,
        annotations = all_annotations
      ))
    })

    # --- RELAYOUT: add annotation on click -----------------------------------
    observeEvent(event_data("plotly_click", source = session$ns("proxy")), {
      if (!input$click_annotate) return()

      click <- event_data("plotly_click", source = session$ns("proxy"))

      # Find the SNP
      d <- proxy_data
      clicked <- d[which.min(abs(bp_cum - click$x) + abs(neglog10p_capped - click$y))]

      new_ann <- list(
        x = clicked$bp_cum,
        y = clicked$neglog10p_capped,
        text = paste0("Chr", clicked$chr,
                      "\np=", formatC(clicked$pvalue, format = "e", digits = 1)),
        showarrow = TRUE,
        arrowhead = 2, arrowsize = 0.8, arrowcolor = "#333",
        ax = 0, ay = -30,
        font = list(size = 9, color = "#333"),
        bgcolor = "rgba(255,255,255,0.85)",
        bordercolor = "#666", borderwidth = 1, borderpad = 2
      )

      # Accumulate annotations
      current <- click_annotations()
      click_annotations(c(current, list(new_ann)))

      plotlyProxyInvoke(proxy, "relayout", list(
        annotations = click_annotations()
      ))
    })

    # --- Clear annotations ---------------------------------------------------
    observeEvent(input$clear_annotations, {
      click_annotations(list())
      plotlyProxyInvoke(proxy, "relayout", list(annotations = list()))
    })

    # --- SECONDARY Y-AXIS: overlay cumulative distribution -------------------
    # Demonstrates addTraces / deleteTraces via proxy.
    # ignoreInit = TRUE: at startup the box is unchecked, and running the else
    # branch would call deleteTraces() on a trace index that does not exist yet
    # (only the 23 base traces are present), throwing in the browser console.
    observeEvent(input$show_cumulative, ignoreInit = TRUE, {
      if (input$show_cumulative) {
        # Compute cumulative fraction of significant SNPs along the genome
        sig_data <- proxy_data[neglog10p >= GENOME_WIDE_SIG][order(bp_cum)]
        if (nrow(sig_data) > 0) {
          sig_data[, cum_frac := seq_len(.N) / .N]

          plotlyProxyInvoke(
            proxy, "addTraces",
            list(
              x = sig_data$bp_cum,
              y = sig_data$cum_frac,
              type = "scattergl",
              mode = "lines",
              line = list(color = "#FF6B35", width = 2),
              yaxis = "y2",
              name = "Cumulative sig. fraction",
              showlegend = TRUE
            )
          )

          # Add the secondary y-axis
          plotlyProxyInvoke(proxy, "relayout", list(
            yaxis2 = list(
              title = "Cumulative fraction",
              overlaying = "y",
              side = "right",
              range = c(0, 1.05),
              showgrid = FALSE,
              tickfont = list(color = "#FF6B35"),
              titlefont = list(color = "#FF6B35")
            )
          ))
        }
      } else {
        # Remove the last trace (the cumulative line)
        n_traces <- 23  # base traces (one per chr)
        plotlyProxyInvoke(proxy, "deleteTraces", list(n_traces))

        # Remove secondary axis
        plotlyProxyInvoke(proxy, "relayout", list(
          yaxis2 = list(visible = FALSE)
        ))
      }
    })
  })
}
