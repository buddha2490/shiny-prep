# server.R --------------------------------------------------------------------
#
# Wires the two modules. The three gallery tabs (Theme, Utility classes, Custom
# components) are pure UI — they have no server side. SUBJECTS is built once in
# global.R and passed in.

server <- function(input, output, session) {

  # Computed-styles tab (Rule 2 — data-driven inline styles).
  mod_computed_styles_server("computed", subjects = SUBJECTS)

  # Two instances of the same metric module (Rule 6 — namespaced CSS selectors).
  mod_metric_panel_server("metric_enrolled", value = 128L)
  mod_metric_panel_server("metric_completed", value = 116L)
}
