---
name: bslib-layout
description: Auto-invoked when creating or modifying Shiny layouts using bslib. Governs page types (page_sidebar, page_navbar, page_fillable), cards, value boxes, layout functions, navsets, theming with bs_theme(), and accordion components.
---

# bslib Layout Skill

bslib is the modern layout and theming system for Shiny (Bootstrap 5). Prefer bslib over shinydashboard for new applications.

## Page Types -- Decision Table

| Page Function | Use When |
|---------------|----------|
| `page_sidebar()` | Single-page app with a sidebar for controls and a main area for outputs |
| `page_navbar()` | Multi-page app with tabs across the top |
| `page_fillable()` | Single-page app where content fills the browser window (maps, full-screen plots) |
| `page_fluid()` | Classic fluid layout without bslib's fillable behavior |

---

## Page Templates

### `page_sidebar()` -- Most Common

```r
library(shiny)
library(bslib)

ui <- page_sidebar(
  title = "My App",
  sidebar = sidebar(
    title = "Controls",
    selectInput("group", "Group:", choices = c("A", "B", "C")),
    dateRangeInput("dates", "Date Range:"),
    actionButton("apply", "Apply", class = "btn-primary")
  ),
  # Main content area -- cards, tables, plots
  layout_columns(
    col_widths = c(4, 4, 4),
    value_box("Subjects", textOutput("n_subjects"), showcase = bsicons::bs_icon("people")),
    value_box("Events", textOutput("n_events"), showcase = bsicons::bs_icon("exclamation-triangle")),
    value_box("Sites", textOutput("n_sites"), showcase = bsicons::bs_icon("building"))
  ),
  card(
    card_header("Results"),
    plotOutput("main_plot")
  )
)
```

### `page_navbar()` -- Multi-Page

```r
ui <- page_navbar(
  title = "Clinical Dashboard",
  theme = bs_theme(version = 5, bootswatch = "flatly"),
  nav_panel("Overview",
    layout_columns(
      card(card_header("Summary"), tableOutput("summary_table")),
      card(card_header("Trend"), plotOutput("trend_plot"))
    )
  ),
  nav_panel("Patient Listing",
    card(DTOutput("patient_table"))
  ),
  nav_panel("Safety",
    mod_safety_ui("safety")
  ),
  nav_spacer(),
  nav_item(
    tags$a(bsicons::bs_icon("gear"), href = "#", `data-bs-toggle` = "offcanvas")
  )
)
```

### `page_fillable()` -- Full-Screen Content

```r
ui <- page_fillable(
  card(
    full_screen = TRUE,
    card_header("Interactive Map"),
    leafletOutput("map", height = "100%")
  )
)
```

---

## Cards

Cards are the primary content container in bslib.

```r
# Basic card
card(
  card_header("Title"),
  card_body(
    plotOutput("plot")
  ),
  card_footer("Source: Clinical Data 2024")
)

# Card with full-screen toggle
card(
  full_screen = TRUE,    # adds expand button in top-right
  card_header(
    class = "bg-primary",
    "Important Results"
  ),
  card_body(
    plotOutput("plot"),
    DTOutput("table")
  )
)

# Card with multiple body sections and a sidebar
card(
  card_header("Analysis"),
  layout_sidebar(
    sidebar = sidebar(
      selectInput("param", "Parameter:", choices = params),
      open = "always"     # sidebar always visible (not collapsible)
    ),
    plotOutput("plot")
  )
)
```

---

## Value Boxes

```r
# Basic value box
value_box(
  title = "Total Subjects",
  value = textOutput("n_subjects"),
  showcase = bsicons::bs_icon("people-fill"),
  theme = "primary"
)

# Themed value boxes
value_box("AEs", textOutput("n_ae"), theme = "danger",
          showcase = bsicons::bs_icon("exclamation-triangle-fill"))
value_box("Complete", textOutput("n_complete"), theme = "success",
          showcase = bsicons::bs_icon("check-circle-fill"))

# Value box with sub-content
value_box(
  title = "Enrollment",
  value = textOutput("enrolled"),
  p("Target: 500"),
  showcase = bsicons::bs_icon("graph-up"),
  theme = "info"
)
```

Theme values: `"primary"`, `"secondary"`, `"success"`, `"danger"`, `"warning"`, `"info"`, `"light"`, `"dark"`, or any valid Bootstrap color.

---

## Layout Functions

### `layout_columns()` -- Responsive Column Grid

```r
# Equal-width columns
layout_columns(
  card("Column 1"),
  card("Column 2"),
  card("Column 3")
)

# Custom widths (must sum to 12)
layout_columns(
  col_widths = c(4, 8),
  card("Sidebar-width"),
  card("Main-width")
)

# Responsive breakpoints
layout_columns(
  col_widths = breakpoints(
    sm = c(12, 12),    # stacked on small screens
    md = c(6, 6),      # side-by-side on medium
    lg = c(4, 8)       # sidebar + main on large
  ),
  card("Left"),
  card("Right")
)
```

### `layout_column_wrap()` -- Auto-Wrapping Cards

```r
# Fixed-width cards that wrap automatically
layout_column_wrap(
  width = "250px",      # each card is at least 250px wide
  height = "200px",     # uniform height
  value_box("A", "100", showcase = bsicons::bs_icon("graph-up")),
  value_box("B", "200", showcase = bsicons::bs_icon("graph-up")),
  value_box("C", "300", showcase = bsicons::bs_icon("graph-up")),
  value_box("D", "400", showcase = bsicons::bs_icon("graph-up"))
)
```

### `layout_sidebar()` -- Sidebar Within a Card or Page

```r
# Inside a card
card(
  layout_sidebar(
    sidebar = sidebar(
      selectInput("var", "Variable:", choices = names(data)),
      width = 300
    ),
    plotOutput("plot")
  )
)
```

---

## Sidebar Configuration

```r
sidebar(
  title = "Filters",
  width = 300,           # pixels
  open = "desktop",      # "desktop" = open on wide screens, closed on mobile
                         # "always" = always open, "closed" = starts collapsed
  bg = "#f8f9fa",        # background color
  # Controls go here
  selectInput("x", "X:", choices),
  selectInput("y", "Y:", choices)
)
```

---

## Navsets -- Tabbed Content Within a Page

```r
# Tabs (horizontal)
navset_tab(
  nav_panel("Tab 1", plotOutput("plot1")),
  nav_panel("Tab 2", plotOutput("plot2")),
  nav_panel("Tab 3", tableOutput("table"))
)

# Card-embedded tabs
navset_card_tab(
  title = "Analysis Views",
  nav_panel("Plot", plotOutput("plot")),
  nav_panel("Table", DTOutput("table")),
  nav_panel("Summary", verbatimTextOutput("summary"))
)

# Pill-style tabs
navset_pill(
  nav_panel("Overview", "..."),
  nav_panel("Details", "..."),
  nav_menu("More",
    nav_panel("Settings", "..."),
    nav_panel("About", "...")
  )
)
```

---

## Accordion

```r
accordion(
  id = "filters",
  open = "Demographics",    # which panel starts open
  accordion_panel(
    title = "Demographics",
    icon = bsicons::bs_icon("person"),
    selectInput("age", "Age Group:", choices = age_groups),
    selectInput("sex", "Sex:", choices = c("M", "F"))
  ),
  accordion_panel(
    title = "Treatment",
    icon = bsicons::bs_icon("capsule"),
    selectInput("arm", "Treatment Arm:", choices = arms)
  ),
  accordion_panel(
    title = "Time Period",
    icon = bsicons::bs_icon("calendar"),
    dateRangeInput("dates", "Dates:")
  )
)

# Server: programmatically open/close panels
accordion_panel_open("filters", values = "Treatment")
accordion_panel_close("filters", values = "Demographics")
```

---

## Theming with `bs_theme()`

```r
# In ui.R or page function
ui <- page_sidebar(
  theme = bs_theme(
    version = 5,
    bootswatch = "flatly",           # preset theme (optional)
    primary = "#0d6efd",             # override Bootstrap variables
    "navbar-bg" = "#2c3e50",
    base_font = font_google("Open Sans"),
    heading_font = font_google("Roboto Slab"),
    font_scale = 0.9
  ),
  # ...
)

# Interactive theme customization (dev only)
# Add to ui.R temporarily during development
bs_themer()    # opens a live theme editor panel
```

### Theme + ggplot2 auto-styling

```r
# In global.R -- auto-apply bslib theme to ggplot2 plots
library(thematic)
thematic_shiny()    # inherits font, background, and accent colors from bs_theme()
```

---

## Common Pitfalls

- **`page_sidebar()` vs `fluidPage()` + `sidebarLayout()`** -- `page_sidebar()` is the bslib replacement; do not mix bslib page functions with classic `fluidPage()` layout helpers
- **`card()` height** -- cards inside `page_fillable()` fill available space; set explicit `height` on cards in `page_fluid()` if needed
- **`value_box()` showcase icon** -- requires `bsicons` package; use `bsicons::bs_icon("name")` not raw HTML
- **`layout_columns()` col_widths** -- must sum to 12 per row, or use `breakpoints()` for responsive behavior
- **`sidebar(open = "desktop")`** -- default behavior is correct for most apps; use `"always"` only when the sidebar must never collapse
- **Bootstrap version** -- `bs_theme(version = 5)` is the default; do not mix Bootstrap 3/4 components (shinydashboard) with bslib Bootstrap 5
- **`nav_panel()` not `tabPanel()`** -- in bslib page functions, use `nav_panel()` (bslib) not `tabPanel()` (base shiny)
