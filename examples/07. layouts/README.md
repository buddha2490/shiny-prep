# 07. Layout / UI Frameworks

Three **native, feature-packed reference apps** — one per layout framework in the
project knowledge base — built to show off *as much of each package as possible*.
These are **demo / reference apps, not production apps**: the goal is breadth of
features you can lift into real work, not a minimal clean build.

| Sub-app | Framework | Bootstrap / theme engine | Shape |
|---------|-----------|--------------------------|-------|
| [`bslib/`](bslib/) | **bslib** | Bootstrap 5 + Sass (`bs_theme`) | Compositional — pick a page shell, nest primitives freely |
| [`shinydashboard/`](shinydashboard/) | **shinydashboard** | AdminLTE 2 (Bootstrap 3) | Template — fixed `dashboardPage(header, sidebar, body)` |
| [`bs4dash/`](bs4dash/) | **bs4Dash** | AdminLTE 3 (Bootstrap 4) + `fresh` | Template, richer — control bar, closable/maximizable boxes |

## Why three apps instead of one

Each framework **owns the page shell and ships its own CSS framework** — Bootstrap 5
(bslib) vs AdminLTE 2 / Bootstrap 3 (shinydashboard) vs AdminLTE 3 / Bootstrap 4
(bs4Dash). You cannot nest `dashboardPage()` inside `page_navbar()`; their stylesheets
collide and the result is visually broken. The only way to demonstrate each framework's
*full* surface cleanly is to give each its own native three-file app. (This mirrors the
`examples/01. async/` layout of one sub-app per pattern.)

Each sub-app follows the project three-file layout (`global.R` / `ui.R` / `server.R`,
never `app.R`), shares the same tiny synthetic ADSL-flavored dataset built by a seeded
factory in `R/fct_sample_data.R` (no PHI), and ships an `AppDriver` all-tabs smoke test.

## How to run

From the **repo root** (so `.Rprofile` activates renv before any package loads — see
`.claude/rules/testing.md` rule 7):

```sh
# Pick one:
NOT_CRAN=true Rscript -e 'source("renv/activate.R"); shiny::runApp("examples/07. layouts/bslib")'
NOT_CRAN=true Rscript -e 'source("renv/activate.R"); shiny::runApp("examples/07. layouts/shinydashboard")'
NOT_CRAN=true Rscript -e 'source("renv/activate.R"); shiny::runApp("examples/07. layouts/bs4dash")'
```

Run a sub-app's smoke test:

```sh
NOT_CRAN=true Rscript -e 'source("renv/activate.R"); library(shinytest2); testthat::test_dir("examples/07. layouts/bslib/tests/testthat")'
```

All three suites pass clean (bslib 39 / shinydashboard 33 / bs4Dash 28 tests), each
launching the real app and visiting every tab. See each sub-app's own `README.md` for
its per-tab feature catalog.

## What each app demonstrates

### `bslib/` — Bootstrap 5, compositional
`page_navbar()` shell with a page-level `sidebar`, `nav_menu()` dropdown, `nav_item()`
external links, `nav_spacer()`, and `input_dark_mode()`. Tabs cover:
- **Layouts** — `layout_columns()` (`col_widths` with a negative spacer + `breakpoints()`),
  `layout_column_wrap()`, full `card()` anatomy (`card_header`/`body`/`footer`,
  `full_screen`, `fill`), card-level `layout_sidebar()`.
- **Value boxes & components** — `value_box()` across every `showcase_layout`
  (`"left center"`/`"top right"`/`"bottom"`), one with a live sparkline `plotOutput`;
  `accordion(multiple=)`, `tooltip()`, `popover()`, `input_switch()`.
- **Navsets** — `navset_card_tab()` / `_pill()` / `_underline()`, one with its own sidebar;
  server-side `nav_select()`.
- **Theming** — live `session$setCurrentTheme(bs_theme(bootswatch=))`, dark-mode-aware ggplot.

### `shinydashboard/` — AdminLTE 2, template
`dashboardPage(skin=)` with header `dropdownMenu`s (messages / notifications / tasks),
a `sidebarMenu` with badged `menuItem`s + `menuSubItem`s + `sidebarUserPanel` +
`sidebarSearchForm`, and `tabItems`. Tabs: `valueBox`/`infoBox` rows (incl. dynamic
`renderValueBox`), `box()` (`status`/`solidHeader`/`collapsible`/`background`/footer) +
`tabBox`, ggplot + plotly charts, a DT listing, and widgets (`updateTabItems()` tab-jump,
dynamic `renderMenu` sidebar).

### `bs4dash/` — AdminLTE 3, template (richest imperative widgets)
`dashboardPage(fullscreen=, dark=, help=, freshTheme=)` with `dashboardBrand`, a
**`dashboardControlbar` (right rail, unique to bs4Dash)** with `skinSelector()`,
`dashboardFooter`, and a preloader. Tabs: gradient/elevated `valueBox`/`infoBox`;
the full box affordance set (`collapsible`/`closable`/`maximizable`, `ribbon()`,
`boxLabel()`, `boxSidebar()`, `boxDropdown()`) driven server-side by `updateBox()`;
`accordion()` + `updateAccordion()`, `callout()`s, drag-and-drop `sortable()`; charts;
a DT listing; and a `toast()` notification.

## Color-vocabulary gotcha (verified — do not mix frameworks)

The single most common cross-framework bug. The same argument name takes a **different
color vocabulary** in each package:

| | shinydashboard | bs4Dash | bslib |
|---|---|---|---|
| `valueBox`/`infoBox` color | AdminLTE 2 names: `"aqua"`, `"light-blue"` (hyphen), `"navy"`, `"olive"`, `"maroon"` | Bootstrap 4 statuses + extended: `"primary"`, `"lightblue"` (one word, **no `"aqua"`**), `"indigo"` | theme tokens: `theme = "primary"`/`"teal"` |
| `box(status=)` | `validStatuses`: `"primary"`/`"success"`/`"info"`/`"warning"`/`"danger"` | same Bootstrap statuses | n/a — `card()` styled via classes / `bs_theme()` |
| Page theming | `skin = "blue"/"black"/...` | `fresh::create_theme(bs4dash_*)` | `bs_theme(bootswatch=, primary=, ...)` |

A `color = "aqua"` copied from a shinydashboard app **silently breaks** in bs4Dash
(it has no `"aqua"`). See `.claude/skills/shinydashboard-layout/` and the RAG comparison
guide `layout-bslib-shinydashboard-bs4dash` for the full breakdown.

## When to use which (clinical/pharma lens)

- **bslib** — default for new apps. Portable Sass theming for corporate branding, no
  AdminLTE ceiling, cards are the same primitive everywhere. Reach for it unless you
  specifically want prebuilt dashboard chrome.
- **shinydashboard** — fast to stand up a conventional, familiar dashboard; mature and
  stable. Trade-off: AdminLTE 2 is dated and real branding means fighting CSS by hand.
- **bs4Dash** — when you want dashboard chrome *and* rich imperative widgets (a control
  bar, closable/maximizable boxes, `fresh` theming). Trade-off: heaviest client, many
  widgets have no bslib equivalent so an app that leans on them is hard to port.
