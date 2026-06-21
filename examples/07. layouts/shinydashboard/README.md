# shinydashboard Layout Showcase

A **reference / demo** Shiny app whose only job is to exercise as many
`shinydashboard` layout features as is reasonable in one place. It is not a
production listing — read it as a catalogue of the AdminLTE 2 dashboard
vocabulary. Built with the three-file layout (`global.R` / `ui.R` / `server.R`);
data is synthetic, CDISC-flavoured, and generated in-memory (no PHI).

```
shinydashboard/
  global.R                 # packages, source R/, build shared datasets
  ui.R                     # dashboardPage(): header + sidebar + body
  server.R                 # dynamic boxes, charts, DT, renderMenu, updateTabItems
  R/
    fct_sample_data.R      # make_adsl / make_enrollment / make_ae_by_arm
    utils_charts.R         # plot_enrollment (ggplot) / plot_ae_by_arm (plotly)
  tests/testthat/
    setup.R                # loads pkgs + sources R/ for the unit tests
    helper-shiny-smoke.R   # expect_no_shiny_errors() (copied verbatim)
    test-fct-sample-data.R # unit tests for the data factories
    test-utils-charts.R    # unit tests for the chart builders
    test-all-tabs-smoke.R  # AppDriver: visits every tab, asserts nothing threw
  .gitignore
```

## What each surface demonstrates

### Header — `dashboardHeader()`
- `dropdownMenu(type = "messages")` with three `messageItem()`s (from / message /
  icon / time).
- `dropdownMenu(type = "notifications")` with three `notificationItem()`s
  (text / icon / Bootstrap `status`).
- `dropdownMenu(type = "tasks")` with four `taskItem()`s (progress bar `value`,
  AdminLTE `color`).
- `dropdownMenuOutput("dynamic_msgs")` — a **dynamic** header dropdown rebuilt by
  `renderMenu()` from the sidebar search box.

### Sidebar — `dashboardSidebar()`
- `sidebarUserPanel()` — identity card (name / subtitle / image).
- `sidebarSearchForm()` — text input + search button (reports as inputs).
- `sidebarMenu(id = "sidebar_tabs")` — the `id` makes `input$sidebar_tabs` report
  the active tab and is the target of `updateTabItems()`.
- `menuItem()`s with icons and `badgeLabel` / `badgeColor`.
- A parent `menuItem(startExpanded = TRUE)` holding two `menuSubItem()`s.
- `sidebarMenuOutput("dynamic_menu")` — a **dynamic** sidebar menu built by
  `renderMenu()` that grows by one item per button click.

### Body — one `tabItem()` per menu `tabName`
- **Overview** — a row of `valueBox()`es across several AdminLTE colors
  (`aqua`, `yellow`, `light-blue`, `green`); a row of `infoBox()`es with
  `fill = FALSE` and `fill = TRUE`; a dynamic `valueBoxOutput()` +
  `infoBoxOutput()` driven by a `selectInput` (`renderValueBox` / `renderInfoBox`).
- **Boxes** — `box()`es showing `status`, `solidHeader`, `collapsible`,
  `collapsed`, `height`, a `footer`, and `background` (AdminLTE color names);
  two `tabBox()`es with multiple `tabPanel()`s (one `side = "right"`,
  `selected`).
- **Charts** — a ggplot (`plotOutput`) and a plotly chart (`plotlyOutput`) inside
  boxes, both filtered by a `selectInput` + `sliderInput` in a control box.
- **Data** — a `DTOutput()` of the ADSL listing inside a box.
- **Widgets** — `taskItem()` progress bars in a box, AdminLTE `background` tiles,
  an `actionButton` that calls `updateTabItems()` to jump to Overview, and a
  button that pushes an entry into the dynamic sidebar menu.
- **About** — a summary of the features above.

## Color vocabulary (verified gotcha)

`shinydashboard` uses **AdminLTE 2** color names — NOT Bootstrap-5 / bs4Dash names.

| Argument | Takes | Examples |
|----------|-------|----------|
| `valueBox(color=)`, `infoBox(color=)`, `taskItem(color=)`, `box(background=)` | AdminLTE colors | `aqua`, `light-blue` (hyphenated), `navy`, `teal`, `olive`, `maroon`, `purple`, `green`, `yellow`, `red`, `black` |
| `box(status=)`, `notificationItem(status=)`, `dropdownMenu(badgeStatus=)` | Bootstrap statuses | `primary`, `success`, `info`, `warning`, `danger` |
| `dashboardPage(skin=)` | skin | `blue`, `black`, `purple`, `green`, `red`, `yellow` |

## Running it

From the **repo root** with renv active:

```sh
NOT_CRAN=true Rscript -e 'source("renv/activate.R"); \
  shiny::runApp("examples/07. layouts/shinydashboard", launch.browser = FALSE, port = 8703)'
```

## Tests

```sh
NOT_CRAN=true Rscript -e 'source("renv/activate.R"); library(shinytest2); \
  testthat::test_dir("examples/07. layouts/shinydashboard/tests/testthat")'
```

The suite is 33 checks: unit tests for the data factories and chart builders,
plus an `AppDriver` all-tabs smoke test that launches the real app, visits every
`tabItem`, exercises each tab's headline interaction, and asserts no Shiny
render/runtime error reached stderr, the DOM, or the browser console.

## Notes

- No new package dependencies — uses `shinydashboard`, `shiny`, `DT`, `plotly`,
  `ggplot2`, `dplyr`, `tibble`, all already in the project lockfile. The weekly
  enrollment rollup uses base `cut(..., breaks = "week")` rather than adding
  `lubridate`.
- A harmless `clock-o` FontAwesome-4 deprecation warning is printed by
  `shinydashboard`'s own internal `messageItem` time rendering — it is from the
  package, not this app, and does not affect rendering.
