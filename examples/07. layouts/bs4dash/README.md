# bs4Dash Layout Showcase

A **reference / demo** Shiny app that exercises as much of the
[bs4Dash](https://bs4dash.rinterface.com) (Bootstrap 4 / AdminLTE3) feature set
as is sensible in one app. It is intentionally feature-dense — the goal is to
show capability, not to be a minimal production listing.

Built with the three-file layout (`global.R` / `ui.R` / `server.R`), themed via
`fresh`, on tiny **synthetic** CDISC-flavored data (no PHI).

## Run it

From the repo root, with renv active:

```r
NOT_CRAN=true Rscript -e 'setwd("examples/07. layouts/bs4dash"); shiny::runApp(".", launch.browser = FALSE, port = 8703)'
```

## File tree

```
examples/07. layouts/bs4dash/
  global.R                     # packages, sources, synthetic data, fresh theme
  ui.R                         # dashboardPage shell + 5 tabItems
  server.R                     # outputs + imperative bs4Dash widgets
  R/
    fct_sample_data.R          # make_adsl / make_enrollment / make_ae_counts
    utils_theme.R              # build_dashboard_theme() -> fresh::create_theme()
  tests/testthat/
    setup.R                    # loads pkgs + sources R/ for unit tests
    helper-shiny-smoke.R       # expect_no_shiny_errors() (copied verbatim)
    test-fct-sample-data.R     # data-factory unit tests
    test-utils-theme.R         # theme builder unit test
    test-all-tabs-smoke.R      # AppDriver: launch real app, visit every tab
```

## What each surface demonstrates

### Shell (`dashboardPage`)
- `fullscreen = TRUE` (navbar fullscreen toggle), `dark = NULL` (light start +
  light/dark toggle shown), `help = TRUE` (global tooltip/popover toggle),
  `scrollToTop = TRUE`, `preloader` (waiter splash).
- `freshTheme` from `fresh::create_theme(bs4dash_status(), bs4dash_layout(),
  bs4dash_sidebar_light())` — the supported way to recolour bs4Dash.
- **Header:** `dashboardBrand()` (title + image + link); `leftUi` dropdown of
  `messageItem`s; `rightUi` dropdown of `notificationItem`s.
- **Sidebar:** `sidebarUserPanel()`, `sidebarHeader()`, and the navigation
  `sidebarMenu(id = "sidebar_menu")` of icon `menuItem`s (with `minified`,
  `skin`, `status`, `elevation`).
- **Controlbar** (the right rail, *unique to bs4Dash*): `controlbarMenu()` with
  a `skinSelector()` (live theme switch) and global inputs (slider + checkbox).
- **Footer:** `dashboardFooter(left, right)`.

### Tab "Overview"
`valueBox()`es with `gradient = TRUE` + `elevation`; `infoBox()`es with
`fill`/`gradient`; one **dynamic** `valueBoxOutput()` / `renderValueBox()` driven
by the controlbar slider (colour flips to success once the target is met) and a
dynamic `infoBoxOutput()` / `renderInfoBox()`.

### Tab "Boxes"
The full `box()` affordance set — `status`, `solidHeader`, `collapsible`,
`closable`, `maximizable`, `elevation`; a box with a `ribbon()`; a box with a
header `label = boxLabel()`; a box with `sidebar = boxSidebar()`; a box with
`dropdownMenu = boxDropdown(boxDropdownItem())`. Action buttons drive
`updateBox(action = "toggle" | "toggleMaximize")` and `updateBoxSidebar()`
server-side; a dropdown item fires a `toast()`.

### Tab "Components"
`accordion()` / `accordionItem()` with `updateAccordion()` driven by radio
buttons; `callout()`s in info/warning/danger; a drag-and-drop `sortable()`
section (three columns of boxes).

### Tab "Charts"
A `box` with a ggplot `plotOutput` (enrollment trend) and a `box` with a
`plotlyOutput` (grouped AE bars), both filtered by a `checkboxGroupInput` of
treatment arms; the controlbar checkbox toggles points on the trend line.

### Tab "Data"
A `box()` wrapping a `DTOutput()` ADSL listing with column filters and paging.

## Verified gotchas

- **Statuses are Bootstrap 4 names**, not shinydashboard's: use
  `"primary" / "secondary" / "info" / "success" / "warning" / "danger"` plus the
  extended palette (`"lightblue"` one word, `"indigo"`, `"navy"`, `"purple"`,
  `"teal"`, `"olive"`, …). There is **no** `"aqua"` / `"light-blue"` — those are
  shinydashboard names and silently break here.
- **`callout()` status is a restricted set:** only `info / success / warning /
  danger` (no `primary`).
- **`fresh::create_theme()` returns rendered CSS** (class `c("css","html",
  "character")`), not a list — pass it straight to `freshTheme`.
- **`prettySwitch` is shinyWidgets, not bs4Dash** — this app uses a base
  `checkboxInput` to avoid adding a dependency.
- **bs4Dash `toast()` differs from bslib's:** it takes `title` + `body` +
  `options = list(autohide=, icon=, close=, position=, class=)`.

## Verification (Acceptance Gate)

```r
# Full suite (28 tests) in the renv-locked library:
NOT_CRAN=true Rscript -e 'setwd("examples/07. layouts/bs4dash"); library(shinytest2); testthat::test_dir("tests/testthat")'
```

The `test-all-tabs-smoke.R` test launches the **real** app, visits all five
sidebar tabs, exercises each tab's headline interaction (value box slider,
`updateBox`/`updateBoxSidebar`/toast, accordion update, chart filter + point
toggle), then asserts no Shiny stderr error, no `.shiny-output-error` element,
and a clean browser console — plus that every primary output positively
rendered.
