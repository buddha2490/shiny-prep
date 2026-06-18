# --- Module: ggplotly Conversion ---------------------------------------------
# Demonstrates:
#   - Building a plot in ggplot2 and converting with ggplotly()
#   - Common ggplotly() pitfalls and cleanup steps
#   - QQ plot (a natural companion to Manhattan plots)
#   - Continuous color scale (colorbar)
#   - add_ribbons() for confidence intervals
#   - Tooltip customization in ggplotly (the `text` aesthetic + tooltip arg)
#   - Side-by-side comparison: raw ggplotly vs cleaned-up ggplotly
#
# WHEN TO USE ggplotly() vs plot_ly():
#   - ggplotly(): When you already know ggplot2, need facets, or want static
#     export compatibility. Good for <50K points.
#   - plot_ly(): When you need scattergl (WebGL), fine-grained control over
#     traces, or advanced interactivity. Better for large data.
#
# COMMON PITFALLS:
#   1. ggplotly inherits ALL ggplot aesthetics as hover text — use
#      tooltip = c("text") to control this
#   2. Legend titles render as "<br>variable" — fix with
#      layout(legend = list(title = list(text = "...")))
#   3. Axis labels may duplicate — ggplotly keeps both ggplot and plotly labels
#   4. Facets become subplots — mostly works but annotation positions shift
#   5. Performance: ggplotly always produces SVG traces (no scattergl),
#      so it's slower than native plot_ly for large N

# --- UI ----------------------------------------------------------------------

mod_ggplotly_ui <- function(id) {
  ns <- NS(id)

  layout_sidebar(
    sidebar = sidebar(
      width = 300,
      title = "ggplotly Controls",

      # --- Sample size for QQ plot -------------------------------------------
      sliderInput(
        ns("qq_sample_n"), "SNPs to include in QQ plot",
        min = 1000, max = 50000, value = 10000, step = 1000,
        pre = "", post = ""
      ),
      helpText(
        "ggplotly uses SVG, not WebGL — keep under ~50K for smooth rendering."
      ),

      hr(),

      # --- Color by chromosome or -log10(p) ----------------------------------
      radioButtons(
        ns("qq_color"), "Color points by:",
        choices = c("Chromosome" = "chr", "-log10(p) value" = "neglog10p"),
        selected = "chr"
      ),

      hr(),

      # --- Show confidence band ----------------------------------------------
      checkboxInput(ns("show_ci"), "Show 95% confidence band", TRUE),

      hr(),

      # --- Show side-by-side comparison --------------------------------------
      checkboxInput(ns("show_raw"), "Show raw vs cleaned comparison", FALSE),
      helpText("Toggle to see the difference between raw ggplotly() and cleaned-up.")
    ),

    # --- Main content --------------------------------------------------------
    layout_columns(
      col_widths = 12,

      # --- Primary QQ plot ---------------------------------------------------
      card(
        card_header("QQ Plot (ggplotly)"),
        card_body(
          class = "p-1",
          plotlyOutput(ns("qq_plot"), height = "500px")
        ),
        full_screen = TRUE
      ),

      # --- Side-by-side: raw vs cleaned (conditional) ------------------------
      conditionalPanel(
        condition = paste0("input['", ns("show_raw"), "'] == true"),
        layout_columns(
          col_widths = c(6, 6),
          card(
            card_header("Raw ggplotly() (before cleanup)"),
            card_body(plotlyOutput(ns("qq_raw"), height = "350px"))
          ),
          card(
            card_header("Cleaned ggplotly() (after cleanup)"),
            card_body(plotlyOutput(ns("qq_cleaned"), height = "350px"))
          )
        )
      ),

      # --- Code reference card -----------------------------------------------
      card(
        card_header("ggplotly Cleanup Checklist"),
        card_body(
          tags$ol(
            tags$li(tags$code("tooltip = c('text')"), " — control which aesthetics appear in hover"),
            tags$li(tags$code('layout(legend = list(title = list(text = "...")))'), " — fix legend title"),
            tags$li("Remove redundant axis labels if ggplotly duplicates them"),
            tags$li(tags$code("style(hoverinfo = 'text')"), " — override default hoverinfo per trace"),
            tags$li("Use ", tags$code("theme_plotly_clean()"), " in ggplot2 so styles match plotly output"),
            tags$li("For confidence bands, use ", tags$code("geom_ribbon()"), " which becomes ",
                    tags$code("add_ribbons()"), " in plotly")
          )
        )
      )
    )
  )
}

# --- Server ------------------------------------------------------------------

mod_ggplotly_server <- function(id) {
  moduleServer(id, function(input, output, session) {

    # --- Sampled data for QQ plot --------------------------------------------
    qq_data <- reactive({
      n <- input$qq_sample_n

      # Stratified sample: keep more significant SNPs, fewer non-significant
      sig <- gwas[neglog10p >= SUGGESTIVE_SIG]
      nonsig <- gwas[neglog10p < SUGGESTIVE_SIG]

      # Take all significant + random non-significant to fill quota
      n_nonsig <- max(100, n - nrow(sig))
      set.seed(789)
      sampled <- nonsig[sample.int(nrow(nonsig), min(n_nonsig, nrow(nonsig)))]
      result <- rbindlist(list(sig, sampled))

      # Compute expected vs observed for QQ
      result <- result[order(pvalue)]
      n_pts <- nrow(result)
      result[, expected := -log10(ppoints(n_pts))]
      result[, observed := neglog10p]
      result[, chr_factor := factor(chr)]

      result
    })

    # --- Confidence band data ------------------------------------------------
    ci_data <- reactive({
      n_pts <- nrow(qq_data())
      expected <- -log10(ppoints(n_pts))

      # 95% CI for uniform order statistics
      ci_upper <- -log10(qbeta(0.025, seq_len(n_pts), n_pts - seq_len(n_pts) + 1))
      ci_lower <- -log10(qbeta(0.975, seq_len(n_pts), n_pts - seq_len(n_pts) + 1))

      data.table(
        expected = expected,
        ci_lower = ci_lower,
        ci_upper = ci_upper
      )
    })

    # --- Primary QQ plot (cleaned ggplotly) ----------------------------------
    output$qq_plot <- renderPlotly({
      d <- qq_data()
      ci <- ci_data()

      # --- Build ggplot2 first -----------------------------------------------
      # Use the `text` aesthetic to control hover content in ggplotly
      p <- ggplot(d, aes(
        x = expected, y = observed,
        text = paste0(
          "<b>Chr ", chr, "</b><br>",
          "p-value: ", formatC(pvalue, format = "e", digits = 2), "<br>",
          "Observed: ", round(observed, 2), "<br>",
          "Expected: ", round(expected, 2)
        )
      ))

      # --- Confidence band (geom_ribbon → add_ribbons in plotly) -------------
      if (input$show_ci) {
        p <- p +
          geom_ribbon(
            data = ci,
            aes(x = expected, ymin = ci_lower, ymax = ci_upper, text = NULL),
            fill = "#1B9E77", alpha = 0.15,
            inherit.aes = FALSE
          )
      }

      # --- Points: colored by chromosome or continuous -log10(p) -------------
      if (input$qq_color == "chr") {
        # Discrete color by chromosome
        p <- p +
          geom_point(aes(color = chr_factor), size = 1.5, alpha = 0.6) +
          scale_color_manual(
            values = rep(c("#1B9E77", "#7570B3"), length.out = 23),
            guide = "none"  # hide legend — too many levels
          )
      } else {
        # Continuous color scale (demonstrates colorbar in plotly)
        p <- p +
          geom_point(aes(color = observed), size = 1.5, alpha = 0.7) +
          scale_color_viridis_c(
            option = "plasma",
            name = "-log10(p)",
            guide = guide_colorbar(barwidth = 1, barheight = 10)
          )
      }

      # --- Reference line (y = x) -------------------------------------------
      p <- p +
        geom_abline(intercept = 0, slope = 1, color = "#E41A1C",
                    linetype = "dashed", linewidth = 0.5) +
        labs(
          x = expression(Expected ~ -log[10](p)),
          y = expression(Observed ~ -log[10](p)),
          title = "Quantile-Quantile Plot"
        ) +
        theme_plotly_clean()

      # --- Convert to plotly with cleanup ------------------------------------
      gg <- ggplotly(p, tooltip = "text")

      # Fix: when the CI band is shown it is the first layer, so it becomes
      # trace 1. ggplotly gives the ribbon a "text" hover too, so skip hover on
      # JUST that trace. Guard the call — style(traces = NULL) applies the
      # attribute to EVERY trace (per ?style), which would kill hover on the
      # points when the band is hidden.
      if (input$show_ci) {
        gg <- style(gg, hoverinfo = "skip", traces = 1)
      }

      gg %>%
        layout(
          # Fix: ggplotly legend title renders with <br> prefix
          legend = list(
            title = list(text = if (input$qq_color == "neglog10p") "-log10(p)" else "")
          )
        ) %>%
        apply_plotly_theme(export_filename = "qq_plot")
    })

    # --- Side-by-side: raw vs cleaned ----------------------------------------
    # Shows what ggplotly() produces by default vs after cleanup
    output$qq_raw <- renderPlotly({
      d <- qq_data()

      # Intentionally NO cleanup — show the warts
      p <- ggplot(d, aes(x = expected, y = observed, color = chr_factor)) +
        geom_point(size = 1.5) +
        geom_abline(intercept = 0, slope = 1, color = "red", linetype = "dashed") +
        labs(x = "Expected", y = "Observed", title = "Raw ggplotly",
             color = "Chromosome") +
        theme_minimal()

      # Raw conversion — no tooltip control, no legend fix, no theme alignment
      ggplotly(p)
    })

    output$qq_cleaned <- renderPlotly({
      d <- qq_data()

      p <- ggplot(d, aes(
        x = expected, y = observed, color = chr_factor,
        text = paste0("Chr ", chr, " | p=", formatC(pvalue, format = "e", digits = 2))
      )) +
        geom_point(size = 1.5, alpha = 0.6) +
        geom_abline(intercept = 0, slope = 1, color = "#E41A1C",
                    linetype = "dashed", linewidth = 0.5) +
        scale_color_manual(
          values = rep(c("#1B9E77", "#7570B3"), length.out = 23),
          guide = "none"
        ) +
        labs(x = "Expected -log10(p)", y = "Observed -log10(p)",
             title = "Cleaned ggplotly") +
        theme_plotly_clean()

      ggplotly(p, tooltip = "text") %>%
        layout(
          legend = list(title = list(text = ""))
        ) %>%
        apply_plotly_theme(export_filename = "qq_cleaned")
    })
  })
}
