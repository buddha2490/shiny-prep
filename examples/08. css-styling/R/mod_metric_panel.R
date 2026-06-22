# mod_metric_panel.R ----------------------------------------------------------
#
# Tab: "Modules & namespacing" — demonstrates css-styling Rule 6 (namespace-aware
# selectors) and Rule 7 (sparing, commented `!important`).
#
# The SAME module is instantiated twice on the tab ("enrolled" and "completed").
# Each instance's headline number is targeted by a CSS rule that uses the
# FULLY-NAMESPACED id — the one that appears in the rendered HTML — not the bare
# `value` id from this R code. With module id "metric_enrolled", ns("value")
# renders as id="metric_enrolled-value", so the CSS selector must be
# `#metric_enrolled-value`. See www/custom.css for the two matching rules.
#
# This is the whole point of Rule 6: a CSS ID selector written against the bare
# R id (`#value`) silently matches nothing once the module is namespaced.

mod_metric_panel_ui <- function(id, label, icon_name) {
  ns <- NS(id)
  card(
    class = "metric-panel",                 # shared treatment — a reusable class
    card_body(
      div(
        class = "d-flex align-items-center gap-3",
        bsicons::bs_icon(icon_name, class = "metric-icon"),
        div(
          # The element each instance's namespaced CSS rule targets by id.
          div(id = ns("value"), class = "metric-value", textOutput(ns("count"), inline = TRUE)),
          div(class = "metric-label text-muted small text-uppercase", label)
        )
      )
    )
  )
}

mod_metric_panel_server <- function(id, value) {
  moduleServer(id, function(input, output, session) {
    output$count <- renderText(format(value, big.mark = ","))
  })
}
