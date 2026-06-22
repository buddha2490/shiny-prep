# ui_gallery.R ----------------------------------------------------------------
#
# UI-only builders for the three "gallery" tabs whose whole purpose is to *show*
# styling — Theme, Utility classes, and Custom components. They contain no
# server logic (per the testing rule, module/UI functions are covered at the
# AppDriver layer, not unit tested), so they live here as plain tag builders
# rather than full modules.
#
# A small helper to label each example with the exact class string or technique
# it demonstrates, so the running app doubles as a copy-paste reference.

# --- Small helper: a labelled example row ------------------------------------
# Shows a rendered example next to the code/class string that produced it.
gallery_item <- function(code, ..., note = NULL) {
  div(
    class = "gallery-item",
    div(class = "gallery-demo", ...),
    tags$code(class = "gallery-code", code),
    if (!is.null(note)) div(class = "text-muted small mt-1", note)
  )
}

# =============================================================================
# Tab: Theme (Rule 8 — bs_theme / bs_add_rules)
# =============================================================================
ui_theme_panel <- function() {
  layout_column_wrap(
    width = 1,
    card(
      card_header("Theme-level styling lives in bs_theme(), not CSS"),
      card_body(
        p(class = "section-lead",
          "This .section-lead rule is injected via bs_add_rules() — it needs the
           Bootstrap Sass variable $font-size-lg, which no bs_theme() argument
           exposes."),
        markdown(
          "App-wide colour, font, and border-radius are set **once** in
           `global.R`'s `APP_THEME` (Rule 8). Everything below inherits from it —
           change `primary` there and every button, link, and navbar updates
           with no CSS edits.

  | Decision | Where it's set |
  |----------|----------------|
  | Primary / success colour | `bs_theme(primary=, success=)` |
  | Font family | `bs_theme(base_font = font_google(...))` |
  | Border radius (app-wide) | `bs_theme(\"border-radius\" = ...)` |
  | A rule needing a Sass var | `bs_add_rules(\"... $font-size-lg ...\")` |
  | Live theme switching | see `examples/07. layouts/bslib` |"
        )
      )
    ),
    layout_columns(
      col_widths = c(6, 6),
      card(
        card_header("Buttons inherit the theme"),
        card_body(
          div(
            class = "d-flex flex-wrap gap-2",
            tags$button(class = "btn btn-primary", "Primary"),
            tags$button(class = "btn btn-success", "Success"),
            tags$button(class = "btn btn-outline-primary", "Outline"),
            tags$button(class = "btn btn-link", "Link")
          ),
          p(class = "text-muted small mt-3",
            "No custom CSS — these are themed entirely by bs_theme(primary=, success=).")
        )
      ),
      card(
        card_header("Value boxes inherit the theme"),
        card_body(
          layout_columns(
            col_widths = c(6, 6),
            value_box("Primary", "navy", theme = "primary",
                      showcase = bsicons::bs_icon("palette")),
            value_box("Success", "teal", theme = "success",
                      showcase = bsicons::bs_icon("check-circle"))
          )
        )
      )
    )
  )
}

# =============================================================================
# Tab: Utility classes (Rule 3 — Bootstrap utilities before custom CSS)
# =============================================================================
ui_utilities_panel <- function() {
  layout_column_wrap(
    width = 1,
    card(
      card_header("Reach for a Bootstrap utility class before writing CSS"),
      card_body(
        p(class = "section-lead",
          "bslib ships Bootstrap 5. Most spacing, layout, text, colour, and
           border needs are already a utility class — no custom rule required.")
      )
    ),
    layout_columns(
      col_widths = c(6, 6),

      card(
        card_header("Spacing — m-* / p-* / gap-*"),
        card_body(
          gallery_item(
            'class = "p-3 bg-light border rounded"',
            div(class = "p-3 bg-light border rounded", "padding-3 box")
          ),
          gallery_item(
            'class = "d-flex gap-2"',
            div(class = "d-flex gap-2",
                span(class = "badge text-bg-primary", "gap"),
                span(class = "badge text-bg-primary", "between"),
                span(class = "badge text-bg-primary", "items"))
          )
        )
      ),

      card(
        card_header("Flexbox — d-flex / justify-content / align-items"),
        card_body(
          gallery_item(
            'class = "d-flex justify-content-between align-items-center"',
            div(class = "d-flex justify-content-between align-items-center border rounded p-2",
                span("left"), span(class = "badge text-bg-secondary", "right"))
          ),
          gallery_item(
            'class = "d-flex justify-content-center"',
            div(class = "d-flex justify-content-center border rounded p-2",
                span("centered"))
          )
        )
      ),

      card(
        card_header("Text — alignment / size / colour"),
        card_body(
          gallery_item('class = "text-center fs-5"',
                       div(class = "text-center fs-5", "centered, larger")),
          gallery_item('class = "text-muted small"',
                       div(class = "text-muted small", "muted, small")),
          gallery_item('class = "text-primary fw-semibold"',
                       div(class = "text-primary fw-semibold", "primary, semibold"))
        )
      ),

      card(
        card_header("Colour & borders — bg-* / border / rounded / shadow"),
        card_body(
          gallery_item('class = "bg-success text-white p-2 rounded"',
                       div(class = "bg-success text-white p-2 rounded", "success bg")),
          gallery_item('class = "border rounded shadow-sm p-2"',
                       div(class = "border rounded shadow-sm p-2", "border + shadow-sm"))
        )
      )
    )
  )
}

# =============================================================================
# Tab: Custom components (Rules 1, 4, 5, 7 — external CSS, custom properties,
#      file structure, sparing !important). All styles below come from
#      www/custom.css; the R here only applies the classes.
# =============================================================================
ui_components_panel <- function() {
  layout_column_wrap(
    width = 1,
    card(
      card_header("App-specific components — styled in www/custom.css"),
      card_body(
        p(class = "section-lead",
          "When no utility class and no theme setting fits, the component style
           goes in the one external www/custom.css (Rule 1), keyed off the
           :root --app-* custom properties (Rule 4)."),
        markdown(
          "Everything on this tab is styled by `www/custom.css` — the R code only
           attaches classes. Open that file to see the section structure (Rule 5),
           the `--app-*` palette custom properties (Rule 4), and the single
           commented `!important` (Rule 7)."
        )
      )
    ),
    layout_columns(
      col_widths = c(4, 4, 4),
      # Summary cards: accent left-border from a custom property (Rule 4).
      div(class = "summary-card",
          div(class = "summary-card-value", "128"),
          div(class = "summary-card-label", "Enrolled")),
      div(class = "summary-card summary-card-warn",
          div(class = "summary-card-value", "12"),
          div(class = "summary-card-label", "Screen failures")),
      div(class = "summary-card summary-card-ok",
          div(class = "summary-card-value", "116"),
          div(class = "summary-card-label", "Completed"))
    ),
    layout_columns(
      col_widths = c(6, 6),
      card(
        card_header("Status indicators + CSS animation"),
        card_body(
          div(class = "d-flex flex-column gap-2",
              span(class = "status-badge status-live",
                   span(class = "status-dot"), "Live — pulsing dot (keyframes)"),
              span(class = "status-badge status-idle",
                   span(class = "status-dot"), "Idle — static dot"))
        )
      ),
      card(
        # The flush-body class uses the one documented !important (Rule 7).
        class = "flush-card",
        card_header("Flush body — the one documented !important"),
        div(class = "flush-card-body",
            div(class = "p-3",
                "This body's padding is zeroed with `!important` to override the
                 bslib card default — see the commented rule in custom.css. Rule 7:
                 used sparingly, always with a why."))
      )
    )
  )
}
