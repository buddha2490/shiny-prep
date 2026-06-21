# =============================================================================
# ui.R — the bslib layout showcase UI (assigned to `ui`, found by name)
# =============================================================================
# This is a DEMO / REFERENCE app: the goal is to pack in as many bslib features
# as possible, with teaching comments explaining WHY each pattern is used. The
# shell is a page_navbar(); each nav_panel() showcases a family of components.
#
# Navbar input id = "nav" (set via id=) so the server can drive nav_select() and
# the smoke test can switch tabs with set_inputs(nav = ...).
# =============================================================================

# --- External links reused in the navbar dropdown / items --- [2026-06-20]
# nav_item() can hold arbitrary UI, including plain anchor tags — the idiom for
# linking out of the app from the navbar.
link_bslib <- tags$a(
  bsicons::bs_icon("book"), "bslib docs",
  href = "https://rstudio.github.io/bslib/", target = "_blank"
)
link_posit <- tags$a(
  bsicons::bs_icon("github"), "Posit GitHub",
  href = "https://github.com/rstudio/bslib", target = "_blank"
)

ui <- page_navbar(
  # --- Page shell ----------------------------------------------------------
  # page_navbar() turns each nav_panel() into a full "page". title + theme set
  # the brand; a PAGE-LEVEL sidebar() persists across every tab (great for
  # global filters); navbar_options() tunes the bar's appearance.
  title  = tags$span(bsicons::bs_icon("layout-wtf"), "bslib Layout Showcase"),
  id     = "nav",
  theme  = app_theme,
  window_title = "bslib Layout Showcase",
  fillable = TRUE,

  # navbar_options() (bslib >= 0.9.0) replaces the old position/bg/inverse args.
  navbar_options = navbar_options(
    position = "static-top",
    underline = TRUE
  ),

  # --- Page-level sidebar (shared across all tabs) -------------------------
  # A `sidebar = sidebar(...)` on page_navbar() shows the SAME sidebar on every
  # tab — the canonical place for global controls. open = "desktop" keeps it
  # open on wide screens, collapsed on mobile.
  sidebar = sidebar(
    title = "Global controls",
    open  = "desktop",
    # A real control that the Theming tab's plots could read; here it scopes the
    # demo to a treatment arm to show the sidebar is wired, not decorative.
    selectInput(
      "arm_filter", "Treatment arm",
      choices  = c("All arms", levels(adsl$ARM)),
      selected = "All arms"
    ),
    sliderInput(
      "age_filter", "Max age",
      min = 20, max = 90, value = 90, step = 1
    ),
    hr(),
    # popover() on a helper icon — a persistent, click-to-open info container.
    popover(
      tags$span(bsicons::bs_icon("info-circle"), "About this app"),
      title = "About",
      # Explicit placement: "auto" is only valid in bslib >= 0.6; pin a concrete
      # side so the app also runs under older bslib (avoids a match.arg error).
      placement = "right",
      "A reference app demonstrating bslib layout primitives on synthetic, ",
      "PHI-free CDISC-flavored data."
    )
  ),

  # =========================================================================
  # TAB 1 — Layouts
  # =========================================================================
  # Demonstrates the layout PRIMITIVES: layout_columns() with explicit
  # col_widths incl. a negative spacer and a breakpoints() object;
  # layout_column_wrap(); a card() with a CARD-LEVEL layout_sidebar(); and the
  # full card anatomy (header/body/footer, full_screen, fill).
  nav_panel(
    title = "Layouts",
    icon  = bsicons::bs_icon("grid-1x2"),

    # layout_columns with a breakpoints() object: 1 col on small, 3 on large.
    layout_columns(
      col_widths = breakpoints(sm = 12, md = 6, lg = 4),
      card(
        card_header("layout_columns()"),
        card_body(
          "Responsive 12-column grid. This row uses a ",
          tags$code("breakpoints()"),
          " object: 1 column on phones, 2 on tablets, 3 on desktop."
        )
      ),
      card(
        card_header("breakpoints()"),
        card_body("Different col_widths per screen size — try resizing.")
      ),
      card(
        card_header("Negative spacers"),
        card_body("Negative col_widths insert empty columns (see next row).")
      )
    ),

    # Explicit numeric col_widths WITH a negative spacer: 7 cols, a 1-col gap,
    # then 4 cols (7 + (-1) + 4 = 12). full_screen lets either card expand.
    layout_columns(
      col_widths = c(7, -1, 4),
      card(
        full_screen = TRUE,
        card_header(
          # tooltip() on a header icon — hover-to-reveal helper text.
          tooltip(
            tags$span(
              "Enrollment curve ", bsicons::bs_icon("question-circle-fill")
            ),
            "Cumulative enrollment by arm. Hover the full-screen icon to expand."
          )
        ),
        # plotlyOutput gives this card real, interactive content.
        card_body(plotlyOutput("layout_plot", height = "320px")),
        card_footer(
          class = "text-muted",
          "card_header / card_body / card_footer + full_screen = TRUE"
        )
      ),
      card(
        full_screen = TRUE,
        card_header("DT in a card"),
        # fill = TRUE (the default) lets the table grow to the card height.
        card_body(DTOutput("layout_table"))
      )
    ),

    # layout_column_wrap(): auto-equal-width columns. width = 1/2 => 2 per row.
    h5("layout_column_wrap()", class = "mt-2"),
    layout_column_wrap(
      width = 1 / 2,
      card(card_header("Wrap card A"), card_body("Equal-width, auto-wrapping.")),
      card(card_header("Wrap card B"), card_body("width = 1/2 -> 2 per row.")),
      card(card_header("Wrap card C"), card_body("Wraps to a new row.")),
      card(card_header("Wrap card D"), card_body("No col_widths math needed."))
    ),

    # A card containing a CARD-LEVEL layout_sidebar() — a sidebar scoped to ONE
    # card, distinct from the page-level sidebar above.
    h5("card() with layout_sidebar()", class = "mt-2"),
    card(
      full_screen = TRUE,
      card_header("Card-scoped sidebar"),
      layout_sidebar(
        sidebar = sidebar(
          title = "Card filter",
          "This sidebar lives INSIDE the card — independent of the page sidebar.",
          radioButtons(
            "layout_metric", "Show",
            choices = c("Enrollment" = "enroll", "AE counts" = "ae")
          )
        ),
        plotOutput("layout_card_plot", height = "300px")
      )
    )
  ),

  # =========================================================================
  # TAB 2 — Value boxes & components
  # =========================================================================
  # value_box() in every showcase layout + theme; accordion(); input_switch();
  # an action button wired via observeEvent/bindEvent on the server.
  nav_panel(
    title = "Value boxes",
    icon  = bsicons::bs_icon("123"),

    # Four value boxes, each a different showcase_layout + theme, in a wrap.
    layout_column_wrap(
      width = 1 / 2,
      # "left center" (default) with a bsicons showcase + solid theme.
      value_box(
        title = "Subjects enrolled",
        value = textOutput("vb_subjects", inline = TRUE),
        showcase = bsicons::bs_icon("people-fill"),
        theme = "primary"
      ),
      # "top right" showcase layout, gradient theme.
      value_box(
        title = "Sites active",
        value = "12",
        showcase = bsicons::bs_icon("hospital"),
        showcase_layout = "top right",
        theme = "bg-gradient-indigo-blue"
      ),
      # A different theme + tooltip in the title for context.
      value_box(
        title = tooltip(
          tags$span("Total AEs ", bsicons::bs_icon("question-circle-fill")),
          "Sum across all severities and arms."
        ),
        value = textOutput("vb_aes", inline = TRUE),
        showcase = bsicons::bs_icon("clipboard2-pulse"),
        theme = "danger"
      ),
      # "bottom" showcase = a FULL-BLEED live sparkline plotOutput. We give the
      # box a min_height and the plot a fixed pixel height: a "100%" height in a
      # short, non-full-screen showcase can collapse to ~0px on first render and
      # trip ggplot's "figure margins too large" — the smoke gate caught exactly
      # that, so we size it explicitly.
      value_box(
        title = "Weekly enrollment trend",
        value = textOutput("vb_trend", inline = TRUE),
        showcase = plotOutput("vb_sparkline", height = "80px"),
        showcase_layout = "bottom",
        theme = "success",
        min_height = "200px",
        full_screen = TRUE
      )
    ),

    # layout_columns putting an accordion next to a "components" card.
    layout_columns(
      col_widths = c(6, 6),

      # accordion() with multiple = TRUE so several panels can be open at once.
      card(
        card_header("accordion() (multiple = TRUE)"),
        accordion(
          id = "demo_accordion",
          multiple = TRUE,
          open = c("What is bslib?"),
          accordion_panel(
            "What is bslib?",
            icon = bsicons::bs_icon("question-circle"),
            "bslib brings Bootstrap 5 layout components to Shiny."
          ),
          accordion_panel(
            "Why accordions?",
            icon = bsicons::bs_icon("list-task"),
            "They keep dense reference content collapsed until needed."
          ),
          accordion_panel(
            "Multiple open",
            icon = bsicons::bs_icon("layers"),
            "multiple = TRUE lets more than one panel stay open together."
          )
        )
      ),

      # input_switch + popover + an action button (wired on the server).
      card(
        card_header("Inputs & overlays"),
        card_body(
          # input_switch() — a bslib toggle that reports TRUE/FALSE.
          input_switch("show_severe", "Highlight severe AEs only", value = FALSE),
          textOutput("switch_state"),
          hr(),
          # popover anchored on a button.
          popover(
            actionButton("pop_btn", "Open popover", icon = icon("comment")),
            title = "Popover",
            placement = "top",  # explicit side — see sidebar popover note above
            "Popovers are click-to-open and persist until dismissed."
          ),
          hr(),
          # Action button wired with observeEvent + bindEvent on the server.
          actionButton(
            "count_btn", "Count a click", icon = icon("plus"),
            class = "btn-primary"
          ),
          textOutput("click_count")
        )
      )
    )
  ),

  # =========================================================================
  # TAB 3 — Navsets
  # =========================================================================
  # navset_card_tab / _pill / _underline, one with its own sidebar=, plus a
  # server-driven nav_select() jump button.
  nav_panel(
    title = "Navsets",
    icon  = bsicons::bs_icon("segmented-nav"),

    layout_columns(
      col_widths = c(6, 6),

      # navset_card_tab with a SHARED sidebar across its inner tabs + nav_select
      # target (id = "inner_tabs") driven by the button below.
      navset_card_tab(
        id = "inner_tabs",
        title = "navset_card_tab() + sidebar",
        sidebar = sidebar(
          "Shared by every tab in this card.",
          selectInput("nav_demo_col", "Color by",
                      choices = c("Arm" = "ARM", "Sex" = "SEX"))
        ),
        nav_panel("Plot", plotOutput("nav_plot", height = "280px")),
        nav_panel("Table", DTOutput("nav_table")),
        nav_panel("Notes", p("Switch tabs without losing the shared sidebar."))
      ),

      # navset_card_pill — pill-shaped toggles, placement above the body.
      navset_card_pill(
        title = "navset_card_pill()",
        placement = "above",
        nav_panel("One", p("Pill tab one.")),
        nav_panel("Two", p("Pill tab two.")),
        nav_panel("Three", p("Pill tab three.")),
        nav_spacer(),
        nav_menu(
          title = "More",
          nav_item(link_bslib)
        )
      )
    ),

    layout_columns(
      col_widths = c(8, 4),

      # navset_card_underline — underline-styled active tab.
      navset_card_underline(
        title = "navset_card_underline()",
        nav_panel("Summary", p("Underline navset variant.")),
        nav_panel("Detail", p("Active tab is marked with an underline."))
      ),

      # Button that programmatically selects a tab in the navset_card_tab above.
      card(
        card_header("Server-side nav_select()"),
        card_body(
          "Jump the left navset to its Table tab from here:",
          actionButton("goto_table", "Go to Table", class = "btn-secondary mt-2")
        )
      )
    )
  ),

  # =========================================================================
  # TAB 4 — Theming
  # =========================================================================
  # Live bootswatch switching via session$setCurrentTheme(); a ggplot that
  # recolors to match light/dark mode; a value_box that recolors.
  nav_panel(
    title = "Theming",
    icon  = bsicons::bs_icon("palette"),

    layout_columns(
      col_widths = c(4, 8),

      card(
        card_header("Live theme controls"),
        card_body(
          # Feeds session$setCurrentTheme(bs_theme(bootswatch = ...)) live.
          selectInput(
            "bootswatch", "Bootswatch preset",
            choices = BOOTSWATCH_PRESETS, selected = "default"
          ),
          helpText(
            "Switching this re-themes the WHOLE app at runtime via ",
            tags$code("session$setCurrentTheme()"), "."
          ),
          hr(),
          helpText(
            "Toggle dark mode in the navbar (top-right). The ggplot below ",
            "recolors to match — a hand-rolled stand-in for thematic."
          )
        )
      ),

      card(
        full_screen = TRUE,
        card_header("Theme-aware ggplot"),
        card_body(plotOutput("theme_plot", height = "340px"))
      )
    ),

    # A value_box that recolors with the theme to show the effect on components.
    layout_column_wrap(
      width = 1 / 3,
      value_box(
        title = "Primary-themed box",
        value = "Recolors with theme",
        showcase = bsicons::bs_icon("droplet-half"),
        theme = "primary"
      ),
      value_box(
        title = "Info-themed box",
        value = "Bootswatch-aware",
        showcase = bsicons::bs_icon("info-square"),
        theme = "info"
      ),
      value_box(
        title = "Warning-themed box",
        value = "Try each preset",
        showcase = bsicons::bs_icon("exclamation-triangle"),
        theme = "warning"
      )
    )
  ),

  # --- Navbar tail: dropdown menu, spacer, external link, dark-mode toggle --
  # nav_spacer() pushes everything after it to the right edge of the navbar.
  nav_spacer(),

  # nav_menu() groups extra panels/items into a navbar dropdown.
  nav_menu(
    title = "More",
    icon  = bsicons::bs_icon("three-dots"),
    align = "right",
    nav_panel(
      "About",
      icon = bsicons::bs_icon("info-circle"),
      card(
        card_header("About this showcase"),
        card_body(
          p("A reference app demonstrating bslib layout primitives:"),
          tags$ul(
            tags$li("page_navbar shell with a page-level sidebar"),
            tags$li("layout_columns / layout_column_wrap / layout_sidebar"),
            tags$li("cards, value boxes, accordions, tooltips, popovers"),
            tags$li("navset_card_tab / _pill / _underline"),
            tags$li("live bs_theme() / bootswatch / dark-mode theming")
          ),
          p(class = "text-muted", "All data is synthetic and PHI-free.")
        )
      )
    ),
    "----",
    nav_item(link_bslib),
    nav_item(link_posit)
  ),

  # nav_item() holding the dark-mode toggle, pinned in the navbar (right side).
  nav_item(input_dark_mode(id = "dark_mode"))
)
