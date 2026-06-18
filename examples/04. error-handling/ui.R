# =============================================================================
# ui.R — Error Handling & Logging Reference App
# =============================================================================
ui <- bslib::page_navbar(
  title = "Error Handling & Logging",
  theme = bslib::bs_theme(version = 5),

  bslib::nav_panel(
    "1. Logging",
    mod_log_demo_ui("log_demo")
  ),
  bslib::nav_panel(
    "2. Safe load",
    mod_safe_load_ui("safe_load")
  ),
  bslib::nav_panel(
    "3. Validation",
    mod_validation_ui("validation")
  ),
  bslib::nav_panel(
    "4. Async",
    mod_async_task_ui("async_task")
  )
)
