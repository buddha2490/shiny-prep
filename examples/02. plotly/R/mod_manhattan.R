# --- Module: Manhattan Plot ---------------------------------------------------
# Demonstrates:
#   - scattergl (WebGL) for large datasets
#   - Downsampling strategy (keep significant, thin non-significant)
#   - Custom hover text with HTML formatting
#   - Shapes (horizontal threshold lines)
#   - Annotations with arrows (top hit labels)
#   - plotly_selected event (box/lasso → detail panel)
#   - plotly_click event (click → point info card)
#   - Config customization (mode bar buttons, export settings, scroll zoom)
#   - Range slider for x-axis navigation
#   - Empty data guards
#   - Loading indicator via bslib
#   - Data download of filtered results

# --- UI ----------------------------------------------------------------------

mod_manhattan_ui <- function(id) {
  ns <- NS(id)

  layout_sidebar(
    sidebar = sidebar(
      width = 300,
      title = "Plot Controls",

      # --- Summary stats -----------------------------------------------------
      card(
        card_header("Dataset Summary"),
        card_body(
          class = "py-2",
          tags$dl(
            class = "row mb-0 small",
            tags$dt(class = "col-sm-7", "Total SNPs:"),
            tags$dd(class = "col-sm-5", format(n_total, big.mark = ",")),
            tags$dt(class = "col-sm-7", "Genome-wide sig:"),
            tags$dd(class = "col-sm-5", format(n_significant, big.mark = ",")),
            tags$dt(class = "col-sm-7", "Suggestive:"),
            tags$dd(class = "col-sm-5", format(n_suggestive, big.mark = ",")),
            tags$dt(class = "col-sm-7", "Top hit:"),
            tags$dd(class = "col-sm-5",
                    paste0("Chr", top_hit$chr, " (p=",
                           formatC(top_hit$pvalue, format = "e", digits = 1), ")"))
          )
        )
      ),

      hr(),

      # --- Downsampling ------------------------------------------------------
      sliderInput(
        ns("sample_pct"),
        "Non-significant SNP sampling %",
        min = 0.1, max = 10, value = 1, step = 0.1,
        post = "%"
      ),
      helpText(
        "Lower = faster rendering. All significant SNPs are always shown."
      ),

      hr(),

      # --- Y-axis cap --------------------------------------------------------
      numericInput(
        ns("y_cap"),
        "-log10(p) cap",
        value = 30, min = 10, max = 50, step = 5
      ),

      hr(),

      # --- Chromosome highlight ----------------------------------------------
      selectInput(
        ns("chr_filter"),
        "Highlight chromosome",
        choices = c("All" = "all", setNames(1:23, paste("Chr", 1:23))),
        selected = "all"
      ),

      hr(),

      # --- Threshold lines ---------------------------------------------------
      checkboxInput(ns("show_genome_wide"), "Genome-wide significance line", TRUE),
      checkboxInput(ns("show_suggestive"), "Suggestive significance line", TRUE),

      hr(),

      # --- Annotations -------------------------------------------------------
      checkboxInput(ns("annotate_top"), "Annotate top hits per chr", FALSE),
      conditionalPanel(
        condition = paste0("input['", ns("annotate_top"), "'] == true"),
        numericInput(ns("top_n"), "Top N per chromosome", 1, min = 1, max = 5)
      ),

      hr(),

      # --- Point aesthetics --------------------------------------------------
      sliderInput(ns("point_size"), "Point size", 1, 6, 2, step = 0.5),
      sliderInput(ns("point_opacity"), "Point opacity", 0.1, 1, 0.6, step = 0.05),

      hr(),

      actionButton(ns("render_plot"), "Update Plot", class = "btn-primary w-100"),

      hr(),

      # --- Data export -------------------------------------------------------
      downloadButton(ns("download_data"), "Download Filtered Data",
                     class = "btn-outline-secondary w-100")
    ),

    # --- Main content --------------------------------------------------------
    layout_columns(
      col_widths = 12,

      card(
        card_header(
          class = "d-flex justify-content-between align-items-center",
          "Manhattan Plot",
          span(class = "text-muted small", textOutput(ns("point_count"), inline = TRUE))
        ),
        card_body(
          class = "p-1",
          plotlyOutput(ns("manhattan"), height = "500px") %>%
            withSpinner_safe()
        ),
        full_screen = TRUE
      ),

      layout_columns(
        col_widths = c(4, 4, 4),

        # --- Detail panel from selection -------------------------------------
        card(
          card_header("Selected Region"),
          card_body(
            plotlyOutput(ns("zoom_plot"), height = "300px")
          )
        ),

        # --- Click info panel ------------------------------------------------
        card(
          card_header("Clicked SNP"),
          card_body(
            uiOutput(ns("click_info"))
          )
        ),

        # --- Top hits table --------------------------------------------------
        card(
          card_header("Top Hits (genome-wide significant)"),
          card_body(
            class = "p-0",
            tableOutput(ns("top_hits_table"))
          )
        )
      )
    )
  )
}

# --- Server ------------------------------------------------------------------

mod_manhattan_server <- function(id) {
  moduleServer(id, function(input, output, session) {

    # --- Downsampled data (reactive on button press) -------------------------
    plot_data <- reactive({
      pct <- input$sample_pct / 100

      # Always keep significant SNPs; downsample the rest
      sig_rows <- gwas[neglog10p >= SUGGESTIVE_SIG]
      nonsig_rows <- gwas[neglog10p < SUGGESTIVE_SIG]

      set.seed(123)
      n_sample <- max(1, round(nrow(nonsig_rows) * pct))
      sampled_idx <- sample.int(nrow(nonsig_rows), size = n_sample)
      nonsig_sample <- nonsig_rows[sampled_idx]

      result <- rbindlist(list(sig_rows, nonsig_sample))
      setorder(result, chr, pos)

      y_cap <- input$y_cap
      result[, neglog10p_capped := pmin(neglog10p, y_cap)]

      result
    }) %>%
      bindEvent(input$render_plot, ignoreNULL = FALSE)

    # --- Point count ---------------------------------------------------------
    output$point_count <- renderText({
      paste0("Rendering ", format(nrow(plot_data()), big.mark = ","), " points")
    })

    # --- Main Manhattan plot -------------------------------------------------
    output$manhattan <- renderPlotly({
      d <- plot_data()

      # Guard: empty data
      if (nrow(d) == 0) {
        return(empty_plot("No data matches current filters"))
      }

      # Assign colors and alpha
      d[, color := CHR_COLORS[chr]]

      highlight_chr <- input$chr_filter
      if (highlight_chr != "all") {
        highlight_chr <- as.integer(highlight_chr)
        d[, alpha := fifelse(chr == highlight_chr, input$point_opacity, 0.08)]
      } else {
        d[, alpha := input$point_opacity]
      }

      # Custom hover text
      d[, hover_text := paste0(
        "<b>Chr ", chr, "</b><br>",
        "Position: ", format(pos, big.mark = ","), " bp<br>",
        "p-value: ", formatC(pvalue, format = "e", digits = 2), "<br>",
        "-log<sub>10</sub>(p): ", round(neglog10p, 2)
      )]

      # --- Build plot with scattergl (WebGL) for performance -----------------
      # Each chromosome is a separate trace for proper coloring.
      # Using scattergl instead of scatter enables GPU-accelerated rendering,
      # which is essential for >10K points.
      p <- plot_ly(source = session$ns("manhattan"))

      chr_list <- sort(unique(d$chr))
      for (ch in chr_list) {
        dd <- d[chr == ch]
        p <- p %>%
          add_trace(
            data = dd,
            x = ~bp_cum,
            y = ~neglog10p_capped,
            type = "scattergl",
            mode = "markers",
            marker = list(
              size = input$point_size,
              color = CHR_COLORS[ch],
              opacity = dd$alpha[1]
            ),
            text = ~hover_text,
            hoverinfo = "text",
            # customdata carries the raw row info for click events
            customdata = ~chr,
            name = paste("Chr", ch),
            legendgroup = paste("Chr", ch),
            showlegend = FALSE
          )
      }

      # --- Threshold lines (using helper functions) --------------------------
      shapes <- list()
      annotations <- list()

      if (input$show_genome_wide) {
        shapes <- c(shapes, list(make_hline(GENOME_WIDE_SIG, color = "#E41A1C")))
        annotations <- c(annotations, list(
          make_hline_label(GENOME_WIDE_SIG, "p = 5e-8", color = "#E41A1C")
        ))
      }

      if (input$show_suggestive) {
        shapes <- c(shapes, list(
          make_hline(SUGGESTIVE_SIG, color = "#377EB8", width = 1, dash = "dot")
        ))
        annotations <- c(annotations, list(
          make_hline_label(SUGGESTIVE_SIG, "p = 1e-5", color = "#377EB8")
        ))
      }

      # --- Top hit annotations -----------------------------------------------
      if (input$annotate_top) {
        top_n <- input$top_n
        top_hits <- d[neglog10p >= GENOME_WIDE_SIG,
                      .SD[order(-neglog10p)][seq_len(min(.N, top_n))],
                      by = chr]

        if (nrow(top_hits) > 0) {
          for (i in seq_len(nrow(top_hits))) {
            row <- top_hits[i]
            annotations <- c(annotations, list(
              list(
                x = row$bp_cum,
                y = row$neglog10p_capped,
                text = paste0("Chr", row$chr, "\np=",
                              formatC(row$pvalue, format = "e", digits = 1)),
                showarrow = TRUE,
                arrowhead = 2,
                arrowsize = 0.8,
                arrowcolor = "#333",
                ax = 0, ay = -35,
                font = list(size = 9, color = "#333"),
                bgcolor = "rgba(255,255,255,0.8)",
                bordercolor = "#999",
                borderwidth = 1,
                borderpad = 2
              )
            ))
          }
        }
      }

      # --- Layout ------------------------------------------------------------
      p %>%
        layout(
          xaxis = list(
            title = list(text = "Chromosome", standoff = 15),
            tickvals = chr_ticks$center,
            ticktext = chr_ticks$chr,
            showgrid = FALSE,
            zeroline = FALSE
          ),
          yaxis = list(
            title = "-log<sub>10</sub>(p)",
            rangemode = "tozero",
            range = c(0, input$y_cap + 1),
            gridcolor = "#f0f0f0"
          ),
          shapes = shapes,
          annotations = annotations,
          plot_bgcolor = "white",
          paper_bgcolor = "white",
          margin = list(t = 30, b = 60, l = 60, r = 20),
          dragmode = "select",
          hovermode = "closest"
        ) %>%
        config(
          displayModeBar = TRUE,
          modeBarButtonsToAdd = list("select2d", "lasso2d"),
          modeBarButtonsToRemove = list("autoScale2d", "toggleSpikelines"),
          toImageButtonOptions = list(
            format = "svg",
            filename = "manhattan_plot",
            width = 1600, height = 600, scale = 2
          ),
          scrollZoom = TRUE
        ) %>%
        rangeslider(thickness = 0.05, bgcolor = "#f8f8f8", bordercolor = "#ddd")
    })

    # --- Zoom plot from box/lasso selection ----------------------------------
    output$zoom_plot <- renderPlotly({
      sel <- event_data("plotly_selected", source = session$ns("manhattan"))

      if (is.null(sel) || nrow(sel) == 0) {
        return(empty_plot("Box/lasso select on the\nManhattan plot to zoom"))
      }

      x_range <- range(sel$x)
      y_range <- range(sel$y)

      # Pull FULL resolution data for the selected region
      region <- gwas[bp_cum >= x_range[1] & bp_cum <= x_range[2] &
                     neglog10p >= y_range[1] & neglog10p <= y_range[2]]

      if (nrow(region) == 0) {
        return(empty_plot("No data in selected region"))
      }

      region[, hover_text := paste0(
        "<b>Chr ", chr, "</b><br>",
        "Position: ", format(pos, big.mark = ","), " bp<br>",
        "p-value: ", formatC(pvalue, format = "e", digits = 2), "<br>",
        "-log<sub>10</sub>(p): ", round(neglog10p, 2)
      )]

      plot_ly(
        data = region,
        x = ~bp_cum, y = ~neglog10p,
        type = "scattergl", mode = "markers",
        marker = list(size = 4, color = ~CHR_COLORS[chr], opacity = 0.7),
        text = ~hover_text, hoverinfo = "text"
      ) %>%
        layout(
          title = list(
            text = paste0("Selected Region (", format(nrow(region), big.mark = ","), " SNPs)"),
            font = list(size = 13)
          ),
          xaxis = list(title = "Genomic Position", showgrid = FALSE),
          yaxis = list(title = "-log<sub>10</sub>(p)", gridcolor = "#f0f0f0"),
          plot_bgcolor = "white", paper_bgcolor = "white",
          showlegend = FALSE
        ) %>%
        config(displayModeBar = FALSE)
    })

    # --- Click event: show info for clicked point ----------------------------
    # plotly_click returns a list with x, y, curveNumber, pointNumber, etc.
    output$click_info <- renderUI({
      click <- event_data("plotly_click", source = session$ns("manhattan"))

      if (is.null(click)) {
        return(tags$p(class = "text-muted", "Click a point on the Manhattan plot"))
      }

      # Find the closest SNP in the downsampled data
      d <- plot_data()
      clicked <- d[which.min(abs(bp_cum - click$x) + abs(neglog10p_capped - click$y))]

      tags$div(
        class = "small",
        tags$table(
          class = "table table-sm table-borderless mb-0",
          tags$tr(tags$th("Chromosome"), tags$td(clicked$chr)),
          tags$tr(tags$th("Position"), tags$td(format(clicked$pos, big.mark = ","), " bp")),
          tags$tr(tags$th("p-value"), tags$td(formatC(clicked$pvalue, format = "e", digits = 3))),
          tags$tr(tags$th("-log10(p)"), tags$td(round(clicked$neglog10p, 3))),
          tags$tr(tags$th("Significant?"),
                  tags$td(
                    if (clicked$neglog10p >= GENOME_WIDE_SIG) {
                      tags$span(class = "badge bg-danger", "Genome-wide")
                    } else if (clicked$neglog10p >= SUGGESTIVE_SIG) {
                      tags$span(class = "badge bg-warning", "Suggestive")
                    } else {
                      tags$span(class = "badge bg-secondary", "No")
                    }
                  ))
        )
      )
    })

    # --- Top hits table ------------------------------------------------------
    output$top_hits_table <- renderTable({
      d <- plot_data()
      top <- d[neglog10p >= GENOME_WIDE_SIG][order(-neglog10p)][1:min(.N, 20)]

      if (nrow(top) == 0) {
        return(data.frame(Message = "No genome-wide significant hits"))
      }

      top[, .(
        Chr = chr,
        Position = format(pos, big.mark = ","),
        `p-value` = formatC(pvalue, format = "e", digits = 2),
        `-log10(p)` = round(neglog10p, 2)
      )]
    }, striped = TRUE, hover = TRUE, bordered = TRUE, width = "100%",
    spacing = "s")

    # --- Download handler for filtered data ----------------------------------
    output$download_data <- downloadHandler(
      filename = function() {
        paste0("manhattan_filtered_", Sys.Date(), ".csv")
      },
      content = function(file) {
        fwrite(plot_data()[, .(chr, pos, pvalue, neglog10p)], file)
      }
    )
  })
}

# --- Spinner helper ----------------------------------------------------------
# Wraps a UI element with a loading spinner. Falls back gracefully if
# shinycssloaders is not installed.
withSpinner_safe <- function(ui_element) {
  if (requireNamespace("shinycssloaders", quietly = TRUE)) {
    shinycssloaders::withSpinner(ui_element, type = 6, color = "#1B9E77")
  } else {
    ui_element
  }
}
