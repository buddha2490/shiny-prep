# ui.R ------------------------------------------------------------------------
#
# The bs4Dash dashboard shell + five demo tabs. Assigns a single `ui` object
# (shiny-app-structure rule: Shiny discovers it by name). No server logic here.
#
# Shell anatomy (the four bs4Dash slots + theme):
#   dashboardPage(header, sidebar, body, controlbar, footer, freshTheme, ...)
# The controlbar (right rail) and the dark-mode toggle are UNIQUE to bs4Dash —
# this app shows both off.
#
# COLOUR NOTE (verified gotcha): bs4Dash uses BOOTSTRAP 4 statuses
# ("primary","secondary","info","success","warning","danger") plus an extended
# palette ("lightblue" ONE word, "indigo","navy","purple","teal","olive",...).
# There is NO "aqua"/"light-blue" here — those are shinydashboard names and
# silently break. Every status/color below is from the bs4 set.

ui <- dashboardPage(
  title = APP_TITLE,

  # fullscreen: show the navbar fullscreen toggle (bs4Dash feature).
  # dark = NULL: start light AND show the light/dark toggle in the header.
  # help = TRUE: globally enable tooltips/popovers (the "?" toggle in header).
  fullscreen = TRUE,
  dark       = NULL,
  help       = TRUE,
  scrollToTop = TRUE,

  # --- Theme --- [2026-06-20]
  # fresh theme object built in global.R. This is the supported way to recolour
  # bs4Dash; the deprecated skin= arg is intentionally not used.
  freshTheme = DASH_THEME,

  # --- Preloader --- [2026-06-20]
  # bs4Dash uses waiter for the splash shown while the app boots. Demonstrates
  # the preloader slot; keep it short so tests aren't slowed.
  preloader = list(
    html = tagList(waiter::spin_fading_circles(), br(), "Loading showcase ..."),
    color = "#2c7fb8"
  ),

  # =========================================================================
  # HEADER (dashboardHeader / bs4DashNavbar)
  # =========================================================================
  header = dashboardHeader(
    # dashboardBrand: a richer title than a plain string — title + image + link.
    title = dashboardBrand(
      title = "bs4Dash",
      color = "primary",
      href  = "https://bs4dash.rinterface.com",
      # A tiny inline data-URI logo so the example has zero external/file deps.
      image = "https://rinterface.com/inst/images/bs4Dash.svg"
    ),
    skin   = "light",
    status = "white",
    border = TRUE,
    fixed  = FALSE,

    # leftUi: a dropdownMenu of message items, sitting just right of the brand.
    leftUi = tagList(
      dropdownMenu(
        type = "messages",
        badgeStatus = "primary",
        headerText = "2 data managers online",
        messageItem(
          from = "Data Manager",
          message = "DM snapshot refreshed",
          time = "09:14",
          color = "primary"
        ),
        messageItem(
          from = "Biostatistician",
          message = "AE tables re-run",
          time = "yesterday",
          color = "success"
        )
      )
    ),

    # rightUi: a notifications dropdown on the far right of the navbar.
    rightUi = tagList(
      dropdownMenu(
        type = "notifications",
        badgeStatus = "danger",
        headerText = "2 alerts",
        notificationItem(
          text = "1 subject past visit window",
          icon = icon("triangle-exclamation"),
          status = "warning"
        ),
        notificationItem(
          text = "New severe AE recorded",
          icon = icon("circle-exclamation"),
          status = "danger"
        )
      )
    )
  ),

  # =========================================================================
  # SIDEBAR (dashboardSidebar) — the navigation lives here in bs4Dash.
  # The sidebarMenu(id=) is how we switch / read the active tab.
  # =========================================================================
  sidebar = dashboardSidebar(
    skin     = "light",
    status   = "primary",
    elevation = 3,
    minified = TRUE,        # collapse to icons-only when minimised
    collapsed = FALSE,

    # A small header + user panel above the menu (sidebar furniture).
    sidebarUserPanel(
      name  = "Clinical Reviewer",
      image = "https://rinterface.com/inst/images/bs4Dash.svg"
    ),
    sidebarHeader("Showcase"),

    # The navigation contract: each menuItem(tabName=) MUST match a
    # tabItem(tabName=) in the body, or clicking does nothing.
    sidebarMenu(
      id = "sidebar_menu",
      menuItem("Overview",   tabName = "overview",   icon = icon("gauge-high")),
      menuItem("Boxes",      tabName = "boxes",       icon = icon("box")),
      menuItem("Components", tabName = "components",  icon = icon("puzzle-piece")),
      menuItem("Charts",     tabName = "charts",      icon = icon("chart-line")),
      menuItem("Data",       tabName = "data",        icon = icon("table"))
    )
  ),

  # =========================================================================
  # CONTROLBAR (dashboardControlbar) — the right rail, UNIQUE to bs4Dash.
  # Holds the live skinSelector plus a couple of global inputs.
  # =========================================================================
  controlbar = dashboardControlbar(
    id = "controlbar",
    collapsed = TRUE,
    overlay   = TRUE,
    skin      = "light",
    pinned    = FALSE,

    controlbarMenu(
      id = "controlbar_menu",
      controlbarItem(
        title = "Skin",
        icon  = icon("palette"),
        # skinSelector: live theme switcher, a bs4Dash-only control.
        skinSelector()
      ),
      controlbarItem(
        title = "Settings",
        icon  = icon("sliders"),
        h6("Global demo settings"),
        # A real input read on the server (drives the dynamic value box).
        sliderInput(
          "target_n", "Enrollment target",
          min = 40, max = 120, value = 80, step = 5
        ),
        # Base checkbox (no shinyWidgets dependency) — drives the trend points.
        checkboxInput(
          "show_points", "Show points on trend",
          value = TRUE
        )
      )
    )
  ),

  # =========================================================================
  # FOOTER (dashboardFooter) — left/right content.
  # =========================================================================
  footer = dashboardFooter(
    left = a(
      href = "https://bs4dash.rinterface.com",
      target = "_blank", "bs4Dash"
    ),
    right = "Reference / demo app — synthetic data, no PHI"
  ),

  # =========================================================================
  # BODY (dashboardBody) — one tabItem per menuItem.
  # =========================================================================
  body = dashboardBody(
    tabItems(

      # ---------------------------------------------------------------------
      # TAB 1 — OVERVIEW: valueBox + infoBox (static + one dynamic).
      # ---------------------------------------------------------------------
      tabItem(
        tabName = "overview",
        # Static value boxes: gradient + elevation affordances.
        fluidRow(
          valueBox(
            value    = nrow(ADSL),
            subtitle = "Subjects enrolled",
            color    = "primary",
            icon     = icon("users"),
            gradient = TRUE,
            elevation = 4,
            width    = 3
          ),
          valueBox(
            value    = length(ARM_LEVELS),
            subtitle = "Treatment arms",
            color    = "info",
            icon     = icon("flask"),
            gradient = TRUE,
            elevation = 4,
            width    = 3
          ),
          # The dynamic value box — rendered server-side from the controlbar
          # slider, proving renderValueBox / valueBoxOutput wiring.
          valueBoxOutput("vbox_target", width = 3),
          valueBox(
            value    = sum(AE_COUNTS$N),
            subtitle = "Adverse events (synthetic)",
            color    = "warning",
            icon     = icon("notes-medical"),
            gradient = TRUE,
            elevation = 4,
            width    = 3
          )
        ),
        # Info boxes: fill + gradient variants.
        fluidRow(
          infoBox(
            title = "Median age",
            value = paste0(stats::median(ADSL$AGE), " yrs"),
            icon  = icon("cake-candles"),
            color = "success",
            fill  = TRUE,
            width = 4
          ),
          infoBox(
            title = "Female subjects",
            value = sum(ADSL$SEX == "F"),
            icon  = icon("venus"),
            color = "danger",
            gradient = TRUE,
            fill  = TRUE,
            width = 4
          ),
          infoBoxOutput("ibox_regions", width = 4)
        ),
        fluidRow(
          box(
            title = "About this showcase",
            status = "primary",
            solidHeader = TRUE,
            width = 12,
            collapsible = TRUE,
            "This reference app demonstrates the bs4Dash feature set: a header ",
            "with brand + dropdown menus, a navigation sidebar, a right-hand ",
            tags$b("controlbar"), " with a live skin selector, boxes with every ",
            "affordance (collapse / close / maximize / ribbon / label / sidebar ",
            "/ dropdown), value & info boxes, an accordion, callouts, a ",
            "drag-and-drop sortable section, charts, and a DT table. Open the ",
            "right control bar (top-right icon) to switch skins and drive the ",
            "dynamic value box."
          )
        )
      ),

      # ---------------------------------------------------------------------
      # TAB 2 — BOXES: the full box() affordance set.
      # ---------------------------------------------------------------------
      tabItem(
        tabName = "boxes",
        fluidRow(
          # A box wearing nearly every tool: status, solidHeader, gradient,
          # collapsible, closable, maximizable, elevation + a header label.
          box(
            id = "kitchen_sink_box",
            title = "Everything box",
            status = "primary",
            solidHeader = TRUE,
            gradient = FALSE,
            collapsible = TRUE,
            closable = TRUE,
            maximizable = TRUE,
            elevation = 4,
            width = 6,
            label = boxLabel(text = "demo", status = "info", tooltip = "Header label"),
            "This box is collapsible, closable, and maximizable, has an ",
            "elevation shadow and a header ", tags$b("label"), ". Use the buttons ",
            "below to drive it from the server with updateBox()."
          ),
          # A box with a ribbon corner banner.
          box(
            title = "Ribbon box",
            status = "info",
            width = 6,
            height = "220px",
            ribbon(text = "NEW", color = "danger"),
            "A ribbon() corner banner — handy for flagging a new or interim ",
            "analysis. Ribbon colours use the bs4 status palette."
          )
        ),
        fluidRow(
          # A box with a boxSidebar (slide-out settings panel inside the box).
          box(
            id = "sidebar_box",
            title = "Box with a sidebar",
            status = "success",
            solidHeader = TRUE,
            width = 6,
            height = "260px",
            sidebar = boxSidebar(
              id = "box_sidebar",
              width = 40,
              startOpen = FALSE,
              icon = icon("gears"),
              h6("In-box settings"),
              "Slide-out panel anchored to this box. Toggle it with the gear ",
              "icon in the header, or from the server via updateBoxSidebar()."
            ),
            "Click the gear icon (top-right of this box) to reveal its sidebar."
          ),
          # A box with a header dropdown menu (boxDropdown + items).
          box(
            title = "Box with a dropdown",
            status = "warning",
            width = 6,
            height = "260px",
            dropdownMenu = boxDropdown(
              icon = icon("ellipsis-vertical"),
              boxDropdownItem("Export (demo)", id = "dd_export", icon = icon("download")),
              boxDropdownItem("Refresh (demo)", id = "dd_refresh", icon = icon("rotate")),
              dropdownDivider(),
              boxDropdownItem("Docs", href = "https://bs4dash.rinterface.com", icon = icon("book"))
            ),
            "The header ", tags$b("..."), " menu is a boxDropdown(). Its items ",
            "with an id behave like action buttons — clicking 'Export' fires a ",
            "toast."
          )
        ),
        # Server-driven controls for the 'Everything box'.
        fluidRow(
          box(
            title = "Drive the boxes from the server",
            status = "secondary",
            width = 12,
            actionButton("toggle_box", "Collapse / expand 'Everything box'",
                        icon = icon("chevron-down"), status = "primary"),
            actionButton("max_box", "Maximize 'Everything box'",
                        icon = icon("expand"), status = "info"),
            actionButton("open_box_sidebar", "Open box sidebar",
                        icon = icon("gears"), status = "success")
          )
        )
      ),

      # ---------------------------------------------------------------------
      # TAB 3 — COMPONENTS: accordion + callouts + sortable.
      # ---------------------------------------------------------------------
      tabItem(
        tabName = "components",
        fluidRow(
          box(
            title = "Accordion (server-controlled)",
            status = "primary",
            solidHeader = TRUE,
            width = 6,
            radioButtons("acc_control", "Open which item?",
                        choices = c("Item 1" = 1, "Item 2" = 2, "Item 3" = 3),
                        inline = TRUE),
            accordion(
              id = "demo_accordion",
              accordionItem(
                title = "Study design", status = "primary", collapsed = FALSE,
                "Randomised, three-arm, parallel-group synthetic study."
              ),
              accordionItem(
                title = "Populations", status = "info", collapsed = TRUE,
                "Safety and ITT populations (illustrative only)."
              ),
              accordionItem(
                title = "Endpoints", status = "success", collapsed = TRUE,
                "Primary and key secondary endpoints (demo text)."
              )
            )
          ),
          box(
            title = "Callouts",
            status = "info",
            solidHeader = TRUE,
            width = 6,
            # callout statuses are a RESTRICTED set: info/success/warning/danger.
            callout(
              title = "Info callout", status = "info",
              "Callouts highlight a contextual message. Status is one of ",
              "info / success / warning / danger."
            ),
            callout(
              title = "Warning callout", status = "warning", elevation = 2,
              "Use warning callouts for recoverable issues."
            ),
            callout(
              title = "Danger callout", status = "danger",
              "Use danger callouts for blocking problems."
            )
          )
        ),
        # sortable: drag-and-drop columns of boxes (bs4Dash-only layout aid).
        h4("Drag-and-drop sortable columns (grab a box header and drag)"),
        fluidRow(
          sortable(
            width = 4,
            p(class = "text-center text-bold", "Column A"),
            box(title = "Card A1", width = 12, status = "primary",
                "Drag me between columns."),
            box(title = "Card A2", width = 12, status = "info",
                "Me too.")
          ),
          sortable(
            width = 4,
            p(class = "text-center text-bold", "Column B"),
            box(title = "Card B1", width = 12, status = "success",
                "I'm sortable as well.")
          ),
          sortable(
            width = 4,
            p(class = "text-center text-bold", "Column C"),
            box(title = "Card C1", width = 12, status = "warning",
                "And so am I.")
          )
        )
      ),

      # ---------------------------------------------------------------------
      # TAB 4 — CHARTS: ggplot box + plotly box + a filter input.
      # ---------------------------------------------------------------------
      tabItem(
        tabName = "charts",
        fluidRow(
          box(
            title = "Filter",
            status = "secondary",
            width = 12,
            collapsible = TRUE,
            # The filter that drives both charts. Multiple arms selectable.
            checkboxGroupInput(
              "arm_filter", "Treatment arms",
              choices = ARM_LEVELS, selected = ARM_LEVELS, inline = TRUE
            )
          )
        ),
        fluidRow(
          box(
            title = "Enrollment over time (ggplot)",
            status = "primary",
            solidHeader = TRUE,
            width = 6,
            maximizable = TRUE,
            plotOutput("enroll_plot", height = "320px")
          ),
          box(
            title = "AE counts by arm & severity (plotly)",
            status = "info",
            solidHeader = TRUE,
            width = 6,
            maximizable = TRUE,
            plotlyOutput("ae_plot", height = "320px")
          )
        )
      ),

      # ---------------------------------------------------------------------
      # TAB 5 — DATA: a box wrapping a DT table.
      # ---------------------------------------------------------------------
      tabItem(
        tabName = "data",
        fluidRow(
          box(
            title = "Subject-level listing (ADSL, synthetic)",
            status = "primary",
            solidHeader = TRUE,
            width = 12,
            maximizable = TRUE,
            DTOutput("adsl_table")
          )
        )
      )
    )
  )
)
