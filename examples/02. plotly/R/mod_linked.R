# --- Module: Linked Views (Crosstalk) ----------------------------------------
# Demonstrates:
#   - highlight_key() / SharedData for client-side linked brushing
#   - subplot() for multi-panel figures with shared axes
#   - highlight() for persistent/transient selection behavior
#   - No server round-trip: all brushing happens in the browser via crosstalk
#
# WHEN TO USE:
#   - When you have 2+ views of the same data and want selection in one
#     to highlight in others
#   - When you want linked brushing WITHOUT reactive overhead
#   - Best for small-to-medium data (<20K points) because crosstalk sends
#     the full dataset to the browser
#
# LIMITATIONS:
#   - crosstalk does NOT work with scattergl — must use scatter (SVG)
#   - All data must fit in browser memory (no server-side filtering)
#   - Only works with plotly, DT, and leaflet (not ggplot2 directly)
#   - highlight_key() wraps a data frame; the key column must uniquely
#     identify what you want to select (rows, groups, etc.)

# --- UI ----------------------------------------------------------------------

mod_linked_ui <- function(id) {
  ns <- NS(id)

  layout_sidebar(
    sidebar = sidebar(
      width = 300,
      title = "Linked View Controls",

      sliderInput(
        ns("linked_n"), "SNPs to include",
        min = 500, max = 20000, value = 5000, step = 500
      ),
      helpText(
        "Crosstalk uses SVG (not WebGL), so keep under ~20K for smooth brushing."
      ),

      hr(),

      radioButtons(
        ns("highlight_mode"), "Selection mode:",
        choices = c(
          "Transient (hover)" = "transient",
          "Persistent (click)" = "persistent"
        ),
        selected = "persistent"
      ),
      helpText(
        "Transient: highlights on hover, clears on mouseout.",
        "Persistent: click to select, double-click to clear."
      ),

      hr(),

      sliderInput(ns("off_opacity"), "Non-selected opacity",
                  min = 0, max = 0.5, value = 0.1, step = 0.05),

      hr(),

      selectInput(
        ns("linked_chr"), "Chromosome subset",
        choices = c("All (1-5)" = "all", setNames(1:5, paste("Chr", 1:5))),
        selected = "all"
      ),
      helpText("Limiting to chromosomes 1-5 for performance with SVG rendering.")
    ),

    # --- Main content --------------------------------------------------------
    layout_columns(
      col_widths = 12,

      card(
        card_header("Linked Brushing: Manhattan + QQ + Histogram"),
        card_body(
          class = "p-1",
          plotlyOutput(ns("linked_subplot"), height = "600px")
        ),
        card_footer(
          class = "small text-muted",
          "Select points in any panel — the other panels highlight the same SNPs.",
          "All brushing happens client-side via crosstalk (no server round-trip)."
        ),
        full_screen = TRUE
      ),

      # --- Explanation card --------------------------------------------------
      card(
        card_header("How Crosstalk Works"),
        card_body(
          tags$ol(
            tags$li(tags$code("highlight_key(df, ~key_col)"),
                    " wraps a data frame in a SharedData object"),
            tags$li("Pass the SharedData object to ", tags$code("plot_ly(data = sd)"),
                    " instead of the raw data frame"),
            tags$li("Multiple plots sharing the same SharedData are automatically linked"),
            tags$li(tags$code("subplot()"), " combines them into a single widget"),
            tags$li(tags$code("highlight()"), " configures selection behavior (persistent/transient, color, opacity)")
          ),
          tags$p(class = "text-warning",
                 tags$strong("Key limitation: "),
                 "crosstalk does NOT work with scattergl. Use type = 'scatter' only.")
        )
      )
    )
  )
}

# --- Server ------------------------------------------------------------------

mod_linked_server <- function(id) {
  moduleServer(id, function(input, output, session) {

    # --- Prepare linked data -------------------------------------------------
    linked_data <- reactive({
      n <- input$linked_n

      # Subset to chrs 1-5 for performance (SVG can't handle full genome)
      chr_subset <- if (input$linked_chr == "all") 1:5 else as.integer(input$linked_chr)

      d <- gwas[chr %in% chr_subset]

      # Stratified sample
      sig <- d[neglog10p >= SUGGESTIVE_SIG]
      nonsig <- d[neglog10p < SUGGESTIVE_SIG]
      n_nonsig <- max(100, n - nrow(sig))
      set.seed(321)
      sampled <- nonsig[sample.int(nrow(nonsig), min(n_nonsig, nrow(nonsig)))]
      result <- rbindlist(list(sig, sampled))
      setorder(result, chr, pos)

      # QQ values
      result <- result[order(pvalue)]
      n_pts <- nrow(result)
      result[, expected := -log10(ppoints(n_pts))]
      result[, observed := neglog10p]

      # Row ID for crosstalk key
      result[, row_id := .I]
      result[, chr_label := paste("Chr", chr)]

      result
    })

    # --- Linked subplot ------------------------------------------------------
    output$linked_subplot <- renderPlotly({
      d <- linked_data()

      # --- Create SharedData object ------------------------------------------
      # highlight_key() wraps the data frame. The ~row_id formula specifies
      # which column is the unique key for selection.
      sd <- highlight_key(d, ~row_id)

      # --- Panel 1: Mini Manhattan -------------------------------------------
      p1 <- plot_ly(
        data = sd,
        x = ~bp_cum, y = ~neglog10p,
        type = "scatter", mode = "markers",
        marker = list(
          size = 3,
          color = ~CHR_COLORS[chr],
          opacity = 0.6
        ),
        text = ~paste0(
          "<b>Chr ", chr, "</b><br>",
          "p = ", formatC(pvalue, format = "e", digits = 2)
        ),
        hoverinfo = "text",
        showlegend = FALSE
      ) %>%
        layout(
          xaxis = list(title = "Genomic Position", showgrid = FALSE),
          yaxis = list(title = "-log10(p)", gridcolor = "#f0f0f0"),
          shapes = list(
            make_hline(GENOME_WIDE_SIG, color = "#E41A1C"),
            make_hline(SUGGESTIVE_SIG, color = "#377EB8", width = 1, dash = "dot")
          )
        )

      # --- Panel 2: QQ Plot --------------------------------------------------
      p2 <- plot_ly(
        data = sd,
        x = ~expected, y = ~observed,
        type = "scatter", mode = "markers",
        marker = list(size = 3, color = ~CHR_COLORS[chr], opacity = 0.6),
        text = ~paste0(
          "<b>Chr ", chr, "</b><br>",
          "Expected: ", round(expected, 2), "<br>",
          "Observed: ", round(observed, 2)
        ),
        hoverinfo = "text",
        showlegend = FALSE
      ) %>%
        layout(
          xaxis = list(title = "Expected -log10(p)", showgrid = FALSE),
          yaxis = list(title = "Observed -log10(p)", gridcolor = "#f0f0f0"),
          shapes = list(
            list(
              type = "line", x0 = 0, x1 = max(d$expected),
              y0 = 0, y1 = max(d$expected),
              line = list(color = "#E41A1C", dash = "dash", width = 1)
            )
          )
        )

      # --- Panel 3: Histogram of -log10(p) -----------------------------------
      p3 <- plot_ly(
        data = sd,
        x = ~neglog10p,
        type = "histogram",
        nbinsx = 50,
        marker = list(color = "#1B9E77", opacity = 0.7),
        showlegend = FALSE
      ) %>%
        layout(
          xaxis = list(title = "-log10(p)", showgrid = FALSE),
          yaxis = list(title = "Count", gridcolor = "#f0f0f0"),
          bargap = 0.05
        )

      # --- Combine with subplot() --------------------------------------------
      # shareX/shareY link axes across panels.
      # nrows controls the grid layout.
      sp <- subplot(p1, p2, p3,
                    nrows = 1,
                    shareX = FALSE,
                    shareY = FALSE,
                    titleX = TRUE, titleY = TRUE,
                    widths = c(0.45, 0.3, 0.25),
                    margin = 0.05) %>%
        layout(
          plot_bgcolor = "white",
          paper_bgcolor = "white",
          margin = list(t = 30, b = 60),
          dragmode = "select"
        )

      # --- Apply highlight behavior ------------------------------------------
      # highlight() controls what happens when points are selected:
      #   - on/off: plotly.js events to trigger selection
      #   - persistent: TRUE = click to add, double-click to clear
      #   - dynamic: TRUE = show a color picker for selection color
      #   - opacityDim: opacity of NON-selected points
      #   - selected: attrs applied to SELECTED points
      if (input$highlight_mode == "persistent") {
        sp <- sp %>%
          highlight(
            on = "plotly_selected",
            off = "plotly_deselect",
            persistent = TRUE,
            opacityDim = input$off_opacity,
            selected = attrs_selected(
              marker = list(opacity = 1, size = 5),
              showlegend = FALSE
            )
          )
      } else {
        sp <- sp %>%
          highlight(
            on = "plotly_hover",
            off = "plotly_unhover",
            persistent = FALSE,
            opacityDim = input$off_opacity,
            selected = attrs_selected(
              marker = list(opacity = 1, size = 6),
              showlegend = FALSE
            )
          )
      }

      sp %>% config(scrollZoom = TRUE)
    })
  })
}
