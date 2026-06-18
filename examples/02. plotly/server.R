# --- Server Logic ------------------------------------------------------------
# Each tab is a self-contained module. The server file just calls them.

server <- function(input, output, session) {

  # --- Module servers --------------------------------------------------------
  mod_manhattan_server("manhattan")
  mod_proxy_server("proxy")
  mod_ggplotly_server("ggplotly")
  mod_linked_server("linked")
  mod_semantic_zoom_server("semantic_zoom")
}
