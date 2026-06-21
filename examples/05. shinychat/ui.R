# =============================================================================
# ui.R — shinychat + ellmer Reference App
# Created: 2026-06-19
# Purpose: Defines the application UI. Five-tab page_navbar with bslib flatly
#   theme and custom colour overrides. Tab layout delegates to module UIs.
#   Static assets loaded here via tags$head().
# =============================================================================

# --- Theme definition -------------------------------------------------------
# flatly bootswatch (v5) with custom overrides matching the UX spec:
#   primary  = dark slate (readable navbar)
#   success  = flatly teal (streaming state, accent)
#   info     = flatly blue (AI/assistant accents, confidence box)
#   Inter    = clean sans-serif for the app chrome
#   JetBrains Mono = code font for verbatim outputs
app_theme <- bslib::bs_theme(
  version     = 5,
  bootswatch  = "flatly",
  primary     = "#2C3E50",
  success     = "#18BC9C",
  info        = "#3498DB",
  base_font   = bslib::font_google("Inter"),
  code_font   = bslib::font_google("JetBrains Mono")
)

# --- UI definition ----------------------------------------------------------
ui <- bslib::page_navbar(
  title = tags$span(
    bsicons::bs_icon("chat-dots-fill", class = "me-2 text-info"),
    "shinychat + ellmer"
  ),
  id       = "main_nav",
  theme    = app_theme,
  # Chat tabs and RAG Chat need viewport fill — others are fluid content pages
  fillable = c("Basic Chat", "Module Pattern", "RAG Chat"),
  navbar_options = bslib::navbar_options(class = "bg-primary", theme = "dark"),

  # Load custom CSS and JavaScript
  header = tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "custom.css"),
    tags$script(src = "status_badge.js")
  ),

  # --- Tab 1: Basic Chat ---------------------------------------------------
  mod_basic_chat_ui("basic_chat"),

  # --- Tab 2: Module Pattern -----------------------------------------------
  mod_module_pattern_ui("module_pattern"),

  # --- Tab 3: Markdown Stream ----------------------------------------------
  mod_markdown_stream_ui("markdown_stream"),

  # --- Tab 4: Advanced ellmer ----------------------------------------------
  mod_advanced_ellmer_ui("advanced_ellmer"),

  # --- Tab 5: Control Panel ------------------------------------------------
  mod_control_panel_ui("control_panel"),

  # --- Tab 6: RAG Chat -----------------------------------------------------
  mod_rag_chat_ui("rag_chat"),

  # --- Navbar right: version badge -----------------------------------------
  bslib::nav_spacer(),
  bslib::nav_item(
    tags$span(
      class = "navbar-text text-white-50 small",
      "shinychat 0.4.0 / ellmer 0.4.1"
    )
  )
)
