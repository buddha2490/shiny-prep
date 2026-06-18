---
name: shinydashboard-layout
description: Auto-invoked when creating or maintaining Shiny apps built with shinydashboard or bs4Dash. Governs dashboardPage/dashboardHeader/dashboardSidebar/dashboardBody, box/tabBox/infoBox/valueBox, sidebarMenu/menuItem with tabItems/tabItem, dynamic sidebars and conditional menu items, programmatic tab switching, and bs4Dash (Bootstrap 4) equivalents.
---

# shinydashboard Layout Skill

shinydashboard is the classic AdminLTE (Bootstrap 3) dashboard framework: a header + collapsible sidebar + body. **bs4Dash** is the Bootstrap 4 / AdminLTE3 successor with a near-identical API.

> **For new apps, prefer bslib** (`page_navbar` + `value_box` + `card`) — see the `bslib-layout` skill. Use this skill when **maintaining legacy pharma apps** already built on shinydashboard/bs4Dash, or when a project explicitly standardizes on one of them. Do **not** mix shinydashboard (Bootstrap 3) components with bslib (Bootstrap 5) in the same app — the CSS collides.

---

## Anatomy — `dashboardPage()`

Three required parts. In this project's three-file layout, the whole `dashboardPage()` is assigned to `ui` in `ui.R`; `library(shinydashboard)` and any data go in `global.R`.

```r
## global.R ##
library(shiny)
library(shinydashboard)

## ui.R ##
ui <- dashboardPage(
  skin = "blue",                          # blue, black, purple, green, red, yellow
  dashboardHeader(title = "Clinical Review"),
  dashboardSidebar(
    sidebarMenu(
      id = "tabs",                        # needed for updateTabItems() / observing the active tab
      menuItem("Overview",  tabName = "overview", icon = icon("dashboard")),
      menuItem("Listings",  tabName = "listings", icon = icon("table")),
      menuItem("Safety",    tabName = "safety",   icon = icon("triangle-exclamation"))
    )
  ),
  dashboardBody(
    tabItems(
      tabItem(tabName = "overview", h2("Overview"), /* boxes ... */),
      tabItem(tabName = "listings", h2("Patient Listings")),
      tabItem(tabName = "safety",   h2("Safety"))
    )
  )
)
```

**The golden rule:** each `menuItem(tabName = "x")` must have a matching `tabItem(tabName = "x")`. A mismatch (typo, missing pair) produces a blank body with no error — the single most common shinydashboard bug.

---

## Header — `dashboardHeader()`

```r
dashboardHeader(
  title = "Clinical Review",
  titleWidth = 300,                       # match dashboardSidebar(width = 300)

  # Dropdown menus appear as icons on the right
  dropdownMenu(
    type = "notifications",               # "messages" | "notifications" | "tasks"
    notificationItem("3 new adverse events", icon = icon("triangle-exclamation"),
                     status = "warning")
  ),
  dropdownMenu(
    type = "messages",
    messageItem("Data Manager", "ADaM refresh complete", time = "09:14")
  )
)
```

Render dropdowns dynamically with `dropdownMenuOutput("id")` (UI) + `renderMenu({ dropdownMenu(...) })` (server).

---

## Sidebar — `dashboardSidebar()` + `sidebarMenu()`

```r
dashboardSidebar(
  width = 300,
  sidebarMenu(
    id = "tabs",

    # menuItem with a badge
    menuItem("Listings", tabName = "listings", icon = icon("table"),
             badgeLabel = "new", badgeColor = "green"),

    # Expandable parent with sub-items (each sub-item is its own tab)
    menuItem("Safety", icon = icon("triangle-exclamation"), startExpanded = TRUE,
      menuSubItem("Adverse Events", tabName = "ae"),
      menuSubItem("Labs",           tabName = "labs")
    ),

    # External link (no tabName — opens a URL)
    menuItem("Protocol", icon = icon("file-pdf"),
             href = "https://example.org/protocol.pdf")
  ),

  # Inputs can live directly in the sidebar (outside sidebarMenu)
  selectInput("trt", "Treatment", choices = c("Placebo", "Drug A", "Drug B"))
)
```

Notes:
- `menuItem()` with sub-items has **no** `tabName`; the `menuSubItem()`s carry the tab names.
- Sidebar inputs outside `sidebarMenu()` are normal Shiny inputs.
- `collapsed = TRUE` on `dashboardSidebar()` starts the sidebar hidden.

---

## Body — boxes

`dashboardBody()` content is laid out on a 12-column grid (`fluidRow()` + `box(width = ...)`, where `width` is **Bootstrap columns 1–12**, not a sum).

### `box()`

```r
fluidRow(
  box(
    title = "Enrollment Over Time",
    status = "primary",        # primary, success, info, warning, danger -> header color
    solidHeader = TRUE,        # filled header band (vs. just a colored top border)
    collapsible = TRUE,        # adds a collapse toggle
    width = 8,                 # 8 of 12 columns
    plotOutput("enroll_plot")
  ),
  box(
    title = "Filters",
    width = 4,
    background = "light-blue",  # fills the WHOLE box body (overrides status colors)
    selectInput("site", "Site:", choices = sites)
  )
)
```

`status` colors the header; `background` colors the entire box. Don't expect `status` to show if you also set a solid `background`.

### `tabBox()` — tabs inside a box

```r
tabBox(
  title = "Analysis", width = 6, side = "right",
  id = "analysis_tabs",                  # observe input$analysis_tabs for the active tab
  tabPanel("Plot",    plotOutput("p")),
  tabPanel("Table",   DT::DTOutput("t")),
  tabPanel("Summary", verbatimTextOutput("s"))
)
```

`tabBox()` uses base Shiny `tabPanel()` (not `nav_panel()`).

### `infoBox()` and `valueBox()`

Both are KPI tiles. `valueBox()` is bolder (big number, colored block); `infoBox()` is lighter with an icon chip.

```r
# Static, defined in the body
valueBox(value = 482, subtitle = "Subjects Enrolled",
         icon = icon("users"), color = "aqua", width = 4)

infoBox(title = "Open Queries", value = 17,
        icon = icon("clipboard-question"), color = "yellow",
        fill = TRUE, width = 4)
```

Reactive versions — `*Output()` in UI, `render*()` in server:

```r
## ui.R (body) ##
valueBoxOutput("vb_subjects", width = 4)
infoBoxOutput("ib_queries", width = 4)

## server.R ##
output$vb_subjects <- renderValueBox({
  valueBox(nrow(adsl()), "Subjects Enrolled",
           icon = icon("users"), color = "aqua")
})
output$ib_queries <- renderInfoBox({
  infoBox("Open Queries", n_open_queries(),
          icon = icon("clipboard-question"),
          color = if (n_open_queries() > 10) "red" else "green")
})
```

> **Color names differ from bslib.** shinydashboard uses AdminLTE names: `red, yellow, aqua, blue, light-blue, green, navy, teal, olive, lime, orange, fuchsia, purple, maroon, black`. These are **not** the Bootstrap theme names (`primary`, `danger`, …) used by `box(status=)` and bslib. Mixing them up silently yields no color.

---

## Switching tabs programmatically

With `sidebarMenu(id = "tabs")`, drive the active tab from the server:

```r
## server.R ##
observeEvent(input$go_to_safety, {
  updateTabItems(session, "tabs", selected = "safety")
})

# React to the current tab
observeEvent(input$tabs, {
  if (input$tabs == "labs") load_labs()
})
```

---

## Dynamic sidebar & conditional menu items

Build the menu in the server when items depend on data, role, or login. Use `sidebarMenuOutput()` + `renderMenu()`:

```r
## ui.R (sidebar) ##
dashboardSidebar(sidebarMenuOutput("menu"))

## server.R ##
output$menu <- renderMenu({
  items <- list(
    menuItem("Overview", tabName = "overview", icon = icon("dashboard")),
    menuItem("Listings", tabName = "listings", icon = icon("table"))
  )
  # Conditional item — only for unblinded reviewers
  if (isTRUE(user_role() == "unblinded")) {
    items <- c(items, list(
      menuItem("Treatment Assignment", tabName = "rand", icon = icon("flask"))
    ))
  }
  sidebarMenu(.list = items, id = "tabs")   # pass a list via .list
})
```

`menuItemOutput("id")` + `renderMenu()` works the same for a single item.

**Caveat:** a `tabItem(tabName = "rand")` must still exist in `dashboardBody()` for the dynamically added item to render content. Gate access by also checking `user_role()` server-side — hiding the menu item alone is not security; the tab still exists.

---

## bs4Dash equivalents (Bootstrap 4 / AdminLTE3)

`library(bs4Dash)` mirrors the shinydashboard API; most code ports by swapping the library and adjusting a few names. Both export `box()`/`valueBox()`/etc., so **load only one** to avoid masking.

| shinydashboard | bs4Dash | Notes |
|----------------|---------|-------|
| `dashboardPage()` | `dashboardPage()` / `bs4DashPage()` | bs4Dash adds `dark`, `freshTheme`, `help`, `fullscreen` args |
| `dashboardHeader()` | `dashboardHeader()` | bs4Dash supports a left/right navbar via `leftUi`/`rightUi` |
| `dashboardSidebar()` | `dashboardSidebar()` | richer: `minified`, `collapsed`, `elevation`, brand logo |
| `sidebarMenu()` / `menuItem()` | `sidebarMenu()` / `menuItem()` | same `tabName` contract |
| `box(status=, solidHeader=)` | `box(status=, solidHeader=, gradient=, collapsed=)` | bs4Dash adds gradients, label, dropdown header menu |
| `valueBox()` / `infoBox()` | `valueBox()` / `infoBox()` / `bs4ValueBox()` | colors use Bootstrap names (`primary`, `success`, …), **not** AdminLTE names |
| `tabBox()` | `tabBox()` | similar |
| `updateTabItems()` | `updateTabItems()` | same |
| — | `bs4Card`, `bs4InfoBox`, `userBox`, `sortable`, `accordion` | bs4Dash-only extras |

Biggest gotcha porting to bs4Dash: **color names switch from AdminLTE to Bootstrap**. shinydashboard accepts `aqua`, `blue`, `light-blue`, `navy`, … (the `validColors` set); bs4Dash uses Bootstrap statuses `primary`, `secondary`, `info`, `success`, `warning`, `danger` plus extras. Watch the near-misses: bs4Dash spells it **`lightblue`** (one word), shinydashboard **`light-blue`** (hyphenated); `aqua` doesn't exist in bs4Dash at all. An invalid name renders with no color and no error — audit every `color =` / `status =` when migrating. bs4Dash also lets `valueBox()`/`infoBox()` take a `tabName` so a KPI tile can navigate like a `menuItem` — a feature shinydashboard lacks.

---

## Common Pitfalls

- **Blank body, no error** — a `menuItem(tabName=)` with no matching `tabItem(tabName=)` (or a typo). Every navigable `tabName` must be paired.
- **`box(width=)` is 1–12, not a sum** — each box's `width` is its Bootstrap column span within a `fluidRow()`; widths in a row should add up to ≤ 12.
- **Wrong color vocabulary** — `valueBox`/`infoBox` use AdminLTE colors (`aqua`, `light-blue`); `box(status=)` uses Bootstrap statuses (`primary`, `danger`). They are not interchangeable; a bad name shows no color.
- **`status` ignored when `background` is set** — `background` fills the whole box and overrides the header status color.
- **Don't mix with bslib** — shinydashboard is Bootstrap 3; combining it with bslib (`bs_theme(version = 5)`, `card()`, `value_box()`) breaks CSS. Pick one framework per app.
- **`tabBox()` uses `tabPanel()`** — not bslib's `nav_panel()`.
- **Dynamic menu needs `id` and `.list`** — `renderMenu()` must return a `sidebarMenu()`; pass programmatic items via `.list =`, and set `id =` if you need `updateTabItems()`/`input$<id>`.
- **`updateTabItems()` needs the menu `id`** — without `sidebarMenu(id = "tabs")` you can't switch tabs from the server or read the active tab.
- **`renv::snapshot()` after adding the package** — `shinydashboard` or `bs4Dash` must land in the lockfile in the same commit (per the renv rule).
- **bs4Dash ≠ drop-in** — the API is close but color names, several arg defaults, and theming (`freshTheme`/`bslib`) differ; test every screen after a migration rather than assuming parity.
