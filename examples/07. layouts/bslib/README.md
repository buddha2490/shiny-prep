# bslib Layout Showcase

A **reference / demo** Shiny app that packs in as many [bslib](https://rstudio.github.io/bslib/)
layout primitives as possible, on tiny synthetic (PHI-free) CDISC-flavored data.
It is intentionally feature-dense and heavily commented — read it as AI-readable
reference code, not a production template.

Three-file layout (`global.R` / `ui.R` / `server.R`), per the project's
`shiny-app-structure` rule.

## Run it

```bash
NOT_CRAN=true Rscript -e 'source("../../../renv/activate.R"); shiny::runApp(".", launch.browser = FALSE, port = 8701)'
```

## Feature catalog (what each tab demonstrates)

### Page shell — `page_navbar()`
- `title` (with a bsicons icon), `theme = bs_theme(...)` (custom `primary`,
  `font_google("Inter")`, `preset = "shiny"`), `fillable = TRUE`
- A **page-level `sidebar = sidebar(...)`** shared across every tab (global
  arm + age filters, a `popover()` info trigger)
- `navbar_options()` (bslib ≥ 0.9.0) for navbar appearance
- A navbar `nav_menu()` dropdown (grouping an "About" panel + external
  `nav_item()` links), `nav_spacer()`, and `input_dark_mode()` pinned via
  `nav_item()`

### Tab "Layouts"
- `layout_columns()` with a `breakpoints()` object (1/2/3 cols by screen size)
- `layout_columns()` with explicit numeric `col_widths` **including a negative
  spacer** (`c(7, -1, 4)`)
- `layout_column_wrap(width = 1/2)`
- Full card anatomy: `card_header()` / `card_body()` / `card_footer()`,
  `full_screen = TRUE`, `fill`
- A `card()` containing a **card-level `layout_sidebar()`** (distinct from the
  page sidebar)
- Real content: `plotlyOutput` (enrollment curve), `DTOutput` (ADSL listing
  with `formatStyle`)
- `tooltip()` on a card header

### Tab "Value boxes"
- Four `value_box()` variants: `showcase = bsicons::bs_icon(...)`, every
  `showcase_layout` (`"left center"`, `"top right"`, `"bottom"`), different
  `theme`s (solid, `bg-gradient-indigo-blue`, `danger`, `success`), and one
  box whose showcase is a **full-bleed live sparkline `plotOutput`**
- `accordion()` / `accordion_panel()` with `multiple = TRUE`
- `input_switch()`, `popover()` on a button, and an `actionButton()` wired via
  `observeEvent()` + a `reactiveVal()` counter

### Tab "Navsets"
- `navset_card_tab()` **with its own `sidebar=`** shared across its inner tabs
- `navset_card_pill()` (placement above) with a `nav_menu()`
- `navset_card_underline()`
- Server-side `nav_select()` driven by a button (jumps the card tabset)

### Tab "Theming"
- Live `selectInput` of Bootswatch presets feeding
  `session$setCurrentTheme(bs_theme(bootswatch = ...))` — re-themes the whole
  app at runtime
- A ggplot that recolors to match light/dark mode
- Value boxes that recolor with the active theme

## Packages

`shiny`, `bslib`, `bsicons`, `DT`, `plotly`, `ggplot2`, `dplyr`, `tibble`,
`tidyr`. No new dependencies were added.

## Note on `thematic`

The Theming tab's brief called for `thematic_shiny()`. `thematic` is **not in
the project's locked library** and the project rules forbid adding new deps, so
the theme-aware ggplot is recolored by a **hand-rolled `mode_theme()`** helper
(`R/utils_plots.R`) that reads `input$dark_mode` and applies matching
background/text/grid colors. The live Bootswatch + dark-mode switching (the
substantive feature) is fully functional.

## Files

```
07. layouts/bslib/
  global.R                      # packages, sources, synthetic data, app_theme
  ui.R                          # page_navbar shell + 4 showcase tabs
  server.R                      # real plotly/DT/ggplot outputs per tab
  R/
    fct_sample_data.R           # ADSL / enrollment / AE-count factories (seeded)
    utils_plots.R               # palettes, mode_theme(), plot builders, sparkline
  tests/testthat/
    setup.R                     # sources factories + helpers for unit tests
    helper-shiny-smoke.R        # expect_no_shiny_errors() (copied verbatim)
    test-fct-sample-data.R      # factory unit tests
    test-utils-plots.R          # plot-helper unit tests
    test-all-tabs-smoke.R       # AppDriver: visit every tab, exercise, assert clean
```

## Verification

- **Unit tests:** 32 assertions across the factories and plot helpers — pass.
- **Smoke test (AppDriver):** launches the real app, visits all 5 nav panels,
  exercises each tab's primary interaction (sidebar filters, switch, action
  button, inner-tab switch, server `nav_select`, live Bootswatch swap, dark-mode
  toggle), and asserts no Shiny stderr error, no `.shiny-output-error`, and a
  clean browser console — pass.
- **Full suite:** 39 pass / 0 fail.
- **Real-app launch:** boots clean, serves HTTP 200 (~75 KB page).

### Gotcha discovered
A value_box `"bottom"` showcase holding a `plotOutput(height = "100%")` can
collapse to ~0 px on first render in a short, non-full-screen box, tripping
ggplot's **"figure margins too large"**. The smoke gate caught this (it surfaced
in the app's stderr). Fix: give the box a `min_height` and the showcase plot an
explicit pixel height.
