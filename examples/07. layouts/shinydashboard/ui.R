# ui.R ------------------------------------------------------------------------
#
# The UI is the star of this reference app. It assembles a full dashboardPage
# and crams in as many shinydashboard layout features as is reasonable:
#
#   HEADER  : three dropdownMenus (messages / notifications / tasks) plus a
#             dynamic dropdownMenuOutput.
#   SIDEBAR : a user panel, a search form, a sidebarMenu with badges, a
#             menuItem containing menuSubItems (startExpanded), and a dynamic
#             sidebarMenuOutput appended at the bottom.
#   BODY    : one tabItem per menu tabName — Overview, Boxes, Charts, Data,
#             Widgets — each wired to real outputs.
#
# Shiny discovers this by the variable name `ui`.

# --- Header ------------------------------------------------------------------
# A dashboardHeader holds dropdownMenu()s on the right. We show all three static
# types (messages / notifications / tasks) plus a 4th dynamic one rendered in
# the server via dropdownMenuOutput, to demonstrate renderMenu for the header.
header <- dashboardHeader(
  title      = APP_TITLE,
  titleWidth = 260,

  # Messages dropdown — messageItem(from, message, time). badgeStatus colours
  # the little count badge (a Bootstrap status, not an AdminLTE color).
  dropdownMenu(
    type = "messages", badgeStatus = "primary",
    messageItem(
      from = "Data Management",
      message = "ADSL refresh completed.",
      icon = icon("database"), time = "5 mins"
    ),
    messageItem(
      from = "Biostatistics",
      message = "TLF shells ready for review.",
      icon = icon("chart-column"), time = "1 hour"
    ),
    messageItem(
      from = "Medical Monitor",
      message = "Query on subject DEMO-01-014.",
      icon = icon("user-doctor"), time = "today"
    )
  ),

  # Notifications dropdown — notificationItem(text, icon, status). status is a
  # Bootstrap status driving the item background.
  dropdownMenu(
    type = "notifications", badgeStatus = "warning",
    notificationItem(
      text = "3 new subjects enrolled",
      icon = icon("user-plus"), status = "success"
    ),
    notificationItem(
      text = "Lab data load near limit",
      icon = icon("triangle-exclamation"), status = "warning"
    ),
    notificationItem(
      text = "Reconciliation job failed",
      icon = icon("circle-xmark"), status = "danger"
    )
  ),

  # Tasks dropdown — taskItem(text, value, color). value drives the progress
  # bar width; color is an AdminLTE color name.
  dropdownMenu(
    type = "tasks", badgeStatus = "danger",
    taskItem(value = 90, color = "green",  "Database lock prep"),
    taskItem(value = 55, color = "aqua",   "AE coding"),
    taskItem(value = 30, color = "yellow", "SDTM mapping"),
    taskItem(value = 15, color = "red",    "Define.xml")
  ),

  # Dynamic header dropdown rendered server-side (renderMenu) — shows the
  # menuOutput-for-the-header pattern.
  dropdownMenuOutput("dynamic_msgs")
)

# --- Sidebar -----------------------------------------------------------------
# Demonstrates the full sidebar vocabulary: a user panel, a search form, and a
# sidebarMenu whose id ("sidebar_tabs") reports the active tab as input value
# (also the target of updateTabItems for programmatic tab switching).
sidebar <- dashboardSidebar(
  width = 260,

  # sidebarUserPanel — a small identity card at the top of the sidebar.
  sidebarUserPanel(
    name     = "Study DEMO-01",
    subtitle = "Phase II • Active",
    image    = "https://www.r-project.org/logo/Rlogo.png"
  ),

  # sidebarSearchForm — text input + search button; both report as inputs
  # (input$search_text / input$search_btn) for the server to react to.
  sidebarSearchForm(
    textId   = "search_text",
    buttonId = "search_btn",
    label    = "Search subjects..."
  ),

  # sidebarMenu — id makes input$sidebar_tabs report the active tabName, and is
  # the inputId updateTabItems() targets. Each menuItem.tabName pairs with a
  # tabItem in the body.
  sidebarMenu(
    id = "sidebar_tabs",

    menuItem(
      "Overview", tabName = "overview", icon = icon("gauge-high"),
      badgeLabel = "live", badgeColor = "green"
    ),
    menuItem(
      "Boxes", tabName = "boxes", icon = icon("box"),
      badgeLabel = "demo", badgeColor = "light-blue"
    ),
    menuItem(
      "Charts", tabName = "charts", icon = icon("chart-line")
    ),
    menuItem(
      "Data", tabName = "data", icon = icon("table"),
      badgeLabel = "60", badgeColor = "purple"
    ),

    # A parent menuItem with menuSubItems — startExpanded so the demo shows the
    # expanded state on load. The sub-items each map to their own tabItem.
    menuItem(
      "Widgets & More", icon = icon("toolbox"), startExpanded = TRUE,
      menuSubItem("Widgets", tabName = "widgets", icon = icon("sliders")),
      menuSubItem("About",   tabName = "about",   icon = icon("circle-info"))
    )
  ),

  # Dynamic sidebar menu appended below the static one (renderMenu pattern).
  sidebarMenuOutput("dynamic_menu")
)

# --- Body: Overview tab ------------------------------------------------------
# valueBoxes across several AdminLTE colors, a row of infoBoxes (fill TRUE/FALSE),
# and one dynamic valueBoxOutput driven by a selectInput.
tab_overview <- tabItem(
  tabName = "overview",
  h2("Study Overview"),

  # Row of static valueBoxes — each a different AdminLTE color to show the range.
  fluidRow(
    valueBox(
      value = nrow(ADSL), subtitle = "Subjects enrolled",
      icon = icon("users"), color = "aqua", width = 3
    ),
    valueBox(
      value = sum(AE_BY_ARM$N_AE), subtitle = "Adverse events",
      icon = icon("triangle-exclamation"), color = "yellow", width = 3
    ),
    valueBox(
      value = length(levels(ADSL$ARM)), subtitle = "Treatment arms",
      icon = icon("vials"), color = "light-blue", width = 3
    ),
    valueBox(
      value = sum(ADSL$SAFFL == "Y"), subtitle = "Safety population",
      icon = icon("shield-halved"), color = "green", width = 3
    )
  ),

  # Row of infoBoxes — fill = FALSE (white body, colored icon) and fill = TRUE
  # (whole body colored) to contrast the two infoBox styles.
  fluidRow(
    infoBox(
      title = "Median age", value = stats::median(ADSL$AGE),
      icon = icon("cake-candles"), color = "navy", fill = FALSE, width = 4
    ),
    infoBox(
      title = "Female", value = sum(ADSL$SEX == "F"),
      icon = icon("venus"), color = "maroon", fill = TRUE, width = 4
    ),
    infoBox(
      title = "Regions", value = length(levels(ADSL$REGION)),
      icon = icon("earth-americas"), color = "teal", fill = TRUE, width = 4
    )
  ),

  # Dynamic valueBox — recomputed server-side from a selectInput, demonstrating
  # valueBoxOutput / renderValueBox.
  fluidRow(
    box(
      title = "Dynamic value box", status = "primary", solidHeader = TRUE,
      width = 4, collapsible = TRUE,
      selectInput(
        "ov_arm", "Filter subjects by arm:",
        choices  = c("All arms", levels(ADSL$ARM)),
        selected = "All arms"
      ),
      helpText("The box on the right recomputes from this selection.")
    ),
    valueBoxOutput("ov_dynamic_box", width = 4),
    infoBoxOutput("ov_dynamic_info", width = 4)
  )
)

# --- Body: Boxes tab ---------------------------------------------------------
# Every box flavour: status colors, solidHeader, collapsible/collapsed,
# background, width, height, a footer, and a tabBox of tabPanels.
tab_boxes <- tabItem(
  tabName = "boxes",
  h2("Box gallery"),

  # Row 1 — status + solidHeader variants.
  fluidRow(
    box(
      title = "status = primary, solidHeader", status = "primary",
      solidHeader = TRUE, width = 4,
      "A solid-header box uses the status color as a full header band."
    ),
    box(
      title = "status = success", status = "success", width = 4,
      "Without solidHeader the status shows as a colored top border only."
    ),
    box(
      title = "status = danger, height = 160", status = "danger",
      width = 4, height = 160,
      "Fixed-height box (160px) — content clips/scrolls inside."
    )
  ),

  # Row 2 — collapsible, collapsed, and a footer.
  fluidRow(
    box(
      title = "Collapsible (open)", status = "info", width = 4,
      collapsible = TRUE,
      "Click the minus icon in the header to collapse this box."
    ),
    box(
      title = "Collapsible (starts collapsed)", status = "warning", width = 4,
      collapsible = TRUE, collapsed = TRUE,
      "This box started collapsed — expand it with the plus icon."
    ),
    box(
      title = "Box with a footer", status = "primary", width = 4,
      footer = "This text lives in the box footer region.",
      "Boxes can carry a footer below their body content."
    )
  ),

  # Row 3 — background-colored boxes (AdminLTE color names).
  fluidRow(
    box(title = "background = aqua",  background = "aqua",  width = 4,
        "A solid-background box (AdminLTE 'aqua')."),
    box(title = "background = olive", background = "olive", width = 4,
        "Background 'olive' tints the entire box body."),
    box(title = "background = maroon", background = "maroon", width = 4,
        "Background 'maroon'.")
  ),

  # Row 4 — a tabBox with multiple tabPanels (a tabset inside a box).
  fluidRow(
    tabBox(
      title = "tabBox", id = "boxes_tabbox", width = 6, height = "240px",
      tabPanel("Demographics",
               "A tabBox holds several tabPanels in one box.",
               tags$ul(
                 tags$li(sprintf("N = %d subjects", nrow(ADSL))),
                 tags$li(sprintf("%d female", sum(ADSL$SEX == "F"))),
                 # median() can interpolate to a half-integer for an even N, so
                 # format with %g (not %d) to avoid an "invalid format" error.
                 tags$li(sprintf("Median age %g", stats::median(ADSL$AGE)))
               )),
      tabPanel("Safety", "Safety population summary tab."),
      tabPanel("Notes", "Free-text notes tab.")
    ),
    tabBox(
      title = "tabBox (side = right)", side = "right", width = 6,
      height = "240px", selected = "Two",
      tabPanel("One",   "When side = 'right', tab order is reversed."),
      tabPanel("Two",   "This tab is selected by default via `selected`."),
      tabPanel("Three", "Third tab.")
    )
  )
)

# --- Body: Charts tab --------------------------------------------------------
# Boxes wrapping a ggplot and a plotly chart, plus an input inside a box that
# filters the data feeding both charts.
tab_charts <- tabItem(
  tabName = "charts",
  h2("Charts"),

  fluidRow(
    box(
      title = "Filter", status = "primary", solidHeader = TRUE, width = 4,
      selectInput(
        "chart_region", "Region:",
        choices  = c("All regions", levels(ADSL$REGION)),
        selected = "All regions"
      ),
      sliderInput(
        "chart_age", "Age range:",
        min = min(ADSL$AGE), max = max(ADSL$AGE),
        value = c(min(ADSL$AGE), max(ADSL$AGE))
      ),
      helpText("Both charts react to these controls.")
    ),
    box(
      title = "Cumulative enrollment (ggplot)", status = "info",
      solidHeader = TRUE, width = 8,
      plotOutput("chart_enroll", height = 260)
    )
  ),
  fluidRow(
    box(
      title = "Adverse events by arm (plotly)", status = "info",
      solidHeader = TRUE, width = 12,
      plotlyOutput("chart_ae", height = 280)
    )
  )
)

# --- Body: Data tab ----------------------------------------------------------
# A box wrapping a DT table of the ADSL data.
tab_data <- tabItem(
  tabName = "data",
  h2("Subject-level data (ADSL)"),
  fluidRow(
    box(
      title = "ADSL listing", status = "primary", solidHeader = TRUE,
      width = 12,
      DTOutput("data_table")
    )
  )
)

# --- Body: Widgets tab -------------------------------------------------------
# taskItem-style progress in a box, gradient/background boxes, a jump-to-tab
# button (updateTabItems), and a button that pushes an entry into the dynamic
# sidebar menu (renderMenu).
tab_widgets <- tabItem(
  tabName = "widgets",
  h2("Widgets & navigation"),

  fluidRow(
    box(
      title = "Progress (taskItem widgets in a box)", status = "primary",
      solidHeader = TRUE, width = 6,
      # taskItem renders a labelled progress bar; usable in the body too.
      tags$ul(
        class = "todo-list",
        taskItem(value = 90, color = "green",  "Database lock prep"),
        taskItem(value = 55, color = "aqua",   "AE coding"),
        taskItem(value = 30, color = "yellow", "SDTM mapping")
      )
    ),
    box(
      title = "Navigation", status = "success", solidHeader = TRUE, width = 6,
      p("Programmatically jump to another tab with updateTabItems():"),
      actionButton("go_overview", "Go to Overview",
                   icon = icon("gauge-high"), class = "btn-primary"),
      br(), br(),
      p("Add an item to the dynamic sidebar menu (renderMenu):"),
      actionButton("add_menu_item", "Add sidebar item",
                   icon = icon("plus"), class = "btn-success")
    )
  ),

  # Gradient-ish background boxes (AdminLTE colored backgrounds).
  fluidRow(
    box(background = "light-blue", width = 4,
        h4("Background light-blue"),
        "Colored-background boxes work as compact KPI tiles."),
    box(background = "purple", width = 4,
        h4("Background purple"),
        textOutput("widget_clicks")),
    box(background = "navy", width = 4,
        h4("Background navy"),
        "Three colored tiles in a row.")
  )
)

# --- Body: About tab ---------------------------------------------------------
tab_about <- tabItem(
  tabName = "about",
  h2("About this app"),
  box(
    title = "shinydashboard layout showcase", status = "primary",
    solidHeader = TRUE, width = 8,
    p("A reference / demo app exercising shinydashboard layout features:"),
    tags$ul(
      tags$li("Header: messages / notifications / tasks dropdowns + a dynamic one"),
      tags$li("Sidebar: user panel, search form, badges, sub-items, dynamic menu"),
      tags$li("Overview: valueBoxes, infoBoxes (fill T/F), dynamic value box"),
      tags$li("Boxes: status, solidHeader, collapsible, background, footer, tabBox"),
      tags$li("Charts: ggplot + plotly, both filtered by box inputs"),
      tags$li("Data: DT table inside a box"),
      tags$li("Widgets: progress, gradient boxes, updateTabItems, renderMenu")
    ),
    p("Colors use AdminLTE 2 names (aqua, light-blue, navy, ...); box status",
      "uses Bootstrap statuses (primary, success, info, warning, danger).")
  )
)

# --- Body --------------------------------------------------------------------
body <- dashboardBody(
  tabItems(
    tab_overview,
    tab_boxes,
    tab_charts,
    tab_data,
    tab_widgets,
    tab_about
  )
)

# --- Assemble the page -------------------------------------------------------
# skin is one of blue/black/purple/green/red/yellow (NOT a Bootstrap status).
ui <- dashboardPage(
  skin   = "blue",
  header = header,
  sidebar = sidebar,
  body   = body,
  title  = APP_TITLE
)
