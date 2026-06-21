---
name: examples-built
description: Reference apps built in examples/ and their key architectural facts (packages, data, helpers)
type: codebase-fact
updated: 2026-06-20
---

# Examples Built

## `examples/02. plotly/` — Plotly Reference App
- 5-tab app demonstrating all major plotly patterns
- 10M-row GWAS dataset (`gwas_data.csv`), uses `scattergl` + downsampling
- Reusable theme helpers in `R/utils_plotly_theme.R`
- Key packages: shiny, bslib, data.table, plotly, ggplot2, viridisLite

## `examples/03. modules/` — Shiny Modules Reference App
- 6-tab bslib `page_navbar` app demonstrating all major module patterns
- Inline synthetic clinical data (adsl/adae/adlb, no CSV)
- See [[module-patterns]] for the per-pattern cheat sheet

## `examples/05. shinychat/` — shinychat + ellmer Reference App (2026-06-19)
- 5-tab bslib flatly `page_navbar` (three-file layout). Packages: shinychat 0.4.0, ellmer 0.4.1, coro 1.1.0, bsicons 0.1.2, httr2 1.2.2
- Modules: `mod_basic_chat`, `mod_module_pattern`, `mod_markdown_stream`, `mod_advanced_ellmer`, `mod_control_panel`
- Shared state via `AppState` R6 class (`R/app_state.R`) — holds primary ellmer Chat client as `reactiveVal`
- **Tab 1 Basic Chat**: `chat_ui()` with `enable_cancel=TRUE`; streaming via `chat_append(id, client$stream_async(input))`;
  greeting with suggestion chips via `chat_set_greeting()` on `input$chat_greeting_requested`;
  badge toggled via `session$sendCustomMessage("update_status_badge", ...)` + JS handler in `www/status_badge.js`
- **Tab 2 Module Pattern**: `chat_mod_server()` returns locked env with `$status()`, `$last_input()`, `$last_turn()`,
  `$set_client()`, `$clear()`; `last_turn()` is an ellmer Turn object — extract text with `ellmer::contents_text(turn@contents)`
- **Tab 3 Markdown Stream**: `output_markdown_stream()` + `markdown_stream(id, content_stream=stream, operation="replace")`
  — note arg is `content_stream` (NOT `stream`); fresh client per click
- **Tab 4 Advanced ellmer**: `tool()` with `arguments=list(name=type_integer(...))` syntax; `chat_structured_async(text, type=.type)`
  returns a promise; sentiment type built with `type_object()` + `type_enum()` + `type_number()` + `type_string()`
- **Tab 5 Control Panel**: `ellmer::token_usage()` (session-level, no args); `client$get_tokens()` (per-client tibble 5 cols);
  `downloadHandler` exports turns as .md; `params(temperature=, top_p=, max_tokens=)` for LLM params
- Default model: `claude-sonnet-4-6` (ellmer default in this environment is `claude-sonnet-4-5-20250929`)
- `utils_logger.R` + `utils_error.R` copied verbatim from examples/04
- Status badge: CSS + JS in `www/`; NOT shinyjs (not installed)

## `examples/07. layouts/bs4dash/` — bs4Dash Layout Showcase (2026-06-20)
- Feature-dense DEMO app. Three-file layout. Packages (all already in renv, NOT
  in lockfile yet — recorded:n): bs4Dash 2.3.5, fresh 0.2.2, waiter, DT, plotly, ggplot2
- 5 sidebar tabs (sidebarMenu id="sidebar_menu"): overview / boxes / components / charts / data
- `R/fct_sample_data.R`: make_adsl / make_enrollment / make_ae_counts (synthetic CDISC, seeded)
- `R/utils_theme.R`: build_dashboard_theme() -> fresh::create_theme(bs4dash_status, bs4dash_layout, bs4dash_sidebar_light)
- Shell: dashboardPage(fullscreen=TRUE, dark=NULL, help=TRUE, freshTheme=, preloader=waiter)
  with dashboardBrand, leftUi/rightUi dropdownMenu(messageItem/notificationItem),
  dashboardControlbar(controlbarMenu + skinSelector), dashboardFooter
- Imperative widgets wired: updateBox(action="toggle"/"toggleMaximize"), updateBoxSidebar,
  updateAccordion(selected=int), updateControlbar (one-shot session$onFlushed), toast()
- VERIFIED bs4Dash API gotchas (see [[pitfalls]]):
  - statuses = Bootstrap 4 set; NO "aqua"/"light-blue" (those are shinydashboard, silently break)
  - callout() status restricted to info/success/warning/danger (no primary)
  - fresh::create_theme() returns rendered CSS, class c("css","html","character") — NOT a list
  - prettySwitch is shinyWidgets NOT bs4Dash — used base checkboxInput instead
  - bs4Dash toast(title, body, options=list(autohide=, icon=, close=, position=, class=)) — differs from bslib toast
- 28 tests pass (factory + theme units + AppDriver all-tabs smoke). Real app launches clean.
- GOTCHA running tests: `source("examples/.../renv/activate.R")` from a SUBDIR triggers a
  renv self-bootstrap DOWNLOAD that fails offline. Run from REPO ROOT (where .Rprofile
  auto-activates renv) then setwd() into the app — that's the working pattern.

## `examples/07. layouts/bslib/` — bslib Layout Showcase (2026-06-20)
- Feature-dense DEMO app, sibling to the bs4dash showcase. Three-file layout.
  Packages (all already in renv lockfile): shiny, bslib 0.9.0, bsicons 0.1.2,
  DT, plotly 4.11.0, ggplot2, dplyr/tibble/tidyr. NO new deps added.
- Shell: `page_navbar(id="nav", theme=app_theme, sidebar=sidebar(...))` with a
  PAGE-LEVEL sidebar shared across all tabs; `navbar_options()`; navbar tail =
  `nav_spacer()` + `nav_menu()` (dropdown w/ About panel + external nav_item
  links) + `nav_item(input_dark_mode(id="dark_mode"))`
- 4 showcase tabs + an About panel inside the nav_menu. Tab values:
  "Layouts" / "Value boxes" / "Navsets" / "Theming" / "About"
- `R/fct_sample_data.R`: make_adsl / make_enrollment / make_ae_counts (synthetic
  CDISC, seeded; `lubridate_floor_week()` base-R helper avoids a lubridate dep)
- `R/utils_plots.R`: ARM_COLORS/SEV_COLORS palettes; `mode_theme(mode)` =
  hand-rolled light/dark ggplot theme (thematic stand-in); `plot_enrollment`,
  `plot_ae_counts`, `sparkline_plot`
- Layouts tab: `layout_columns()` w/ `breakpoints()` AND explicit `col_widths`
  incl. negative spacer `c(7,-1,4)`; `layout_column_wrap(width=1/2)`; full card
  anatomy + `full_screen=TRUE`; a card-level `layout_sidebar()`
- Value-boxes tab: 4 `value_box()` (every showcase_layout + themes incl
  `bg-gradient-indigo-blue`; one full-bleed sparkline plotOutput); `accordion()`
  `multiple=TRUE`; `input_switch()`; `popover()`; actionButton via observeEvent +
  reactiveVal counter
- Navsets tab: `navset_card_tab()` w/ own `sidebar=`, `navset_card_pill()`,
  `navset_card_underline()`; server `nav_select("inner_tabs", selected="Table")`
- Theming tab: live `session$setCurrentTheme(bs_theme(bootswatch=...))` from a
  selectInput (BOOTSWATCH_PRESETS); ggplot recolors via mode_theme + dark_mode
- **thematic is NOT in the locked library** despite prompt claiming it — used
  hand-rolled mode_theme() instead of thematic_shiny() (no-new-deps rule)
- 39 tests pass (4 unit files + AppDriver all-tabs smoke). Real app boots clean,
  serves HTTP 200 (~75KB).
- The smoke gate CAUGHT a real "figure margins too large" render error from the
  bottom-showcase sparkline at height="100%" — see [[pitfalls]] for the fix.
- OFFLINE-RENV WORKAROUND (this env has no network): `renv/activate.R` tries a
  renv self-update DOWNLOAD that fails offline AND pollutes Rscript stdout. The
  renv library lives at `renv/library/macos/R-4.5/aarch64-apple-darwin20`
  (flat macos layout, NOT R-4.5/<platform>). To run tests/app cleanly: prepend
  that path to `.libPaths()` and set `RENV_CONFIG_AUTOLOADER_ENABLED=FALSE` +
  `R_LIBS_USER=<that path>` so the AppDriver subprocess inherits it.

## `examples/07. layouts/shinydashboard/` — shinydashboard Layout Showcase (2026-06-20)
- Feature-dense DEMO app, sibling to the bs4dash + bslib showcases. Three-file
  layout. Packages (all already in renv lockfile): shiny, shinydashboard 0.7.3,
  DT, plotly 4.11.0, ggplot2, dplyr/tibble. NO new deps added.
- Shell: `dashboardPage(skin="blue", header, sidebar, body)`.
  - HEADER: 3 static dropdownMenu (messages/notifications/tasks) + a dynamic
    `dropdownMenuOutput("dynamic_msgs")` rebuilt by renderMenu from search box.
  - SIDEBAR: sidebarUserPanel + sidebarSearchForm + `sidebarMenu(id="sidebar_tabs")`
    (this id is BOTH the active-tab input AND the updateTabItems target) with
    badged menuItems, a parent menuItem(startExpanded=TRUE) holding menuSubItems,
    and a dynamic `sidebarMenuOutput("dynamic_menu")` that grows per click.
  - BODY: tabItems/tabItem per tabName: overview/boxes/charts/data/widgets/about.
- 6 tabs. Overview = valueBox row (aqua/yellow/light-blue/green) + infoBox row
  (fill T/F) + dynamic valueBoxOutput/infoBoxOutput from a selectInput. Boxes =
  status/solidHeader/collapsible/collapsed/height/footer/background + 2 tabBox
  (one side="right", selected=). Charts = ggplot plotOutput + plotly plotlyOutput
  filtered by select+slider. Data = DTOutput in a box. Widgets = taskItem progress
  in body + background tiles + updateTabItems jump + dynamic-menu add button.
- `R/fct_sample_data.R`: make_adsl / make_enrollment / make_ae_by_arm (synthetic
  CDISC, seeded). Weekly rollup uses base `as.Date(cut(d, breaks="week"))` to
  AVOID a lubridate dep (lubridate is NOT in the locked library here).
- `R/utils_charts.R`: plot_enrollment (ggplot area+line+point) / plot_ae_by_arm
  (plotly bar). Both validate inputs and return finished objects (testable).
- VERIFIED shinydashboard gotchas (vs bs4Dash — see [[pitfalls]]):
  - colors are AdminLTE 2 names: valueBox/infoBox/taskItem `color=` + box
    `background=` take "aqua","light-blue"(hyphen),"navy","teal","olive",
    "maroon","purple","green","yellow","red","black". NOT Bootstrap names.
  - box `status=` / notificationItem `status=` / dropdownMenu `badgeStatus=` take
    Bootstrap statuses (primary/success/info/warning/danger).
  - dashboardPage `skin=` is blue/black/purple/green/red/yellow.
  - messageItem(from, message, icon, time); notificationItem(text, icon, status);
    taskItem(text, value, color). Dynamic menus via renderMenu + .list arg.
  - SMOKE-GATE BUG CAUGHT: `sprintf("%d", stats::median(int_vec))` throws
    "invalid format '%d'" because median() interpolates to a DOUBLE for even N.
    Use %g (or as.integer()). This fired at UI-BUILD time -> HTTP 500 on first
    load; the live-app probe caught it before tests even ran.
  - harmless `clock-o` FA4 deprecation warning printed by shinydashboard's own
    messageItem time rendering — package internal, not app code, no render impact.
- 33 tests pass (factory + chart units + AppDriver all-tabs smoke). Real app
  boots clean, HTTP 200 (~37KB), all 6 tabs render. Gate validated by breaking a
  renderValueBox -> went red on the stderr scan -> restored.
- shinydashboard switches tabs by the sidebarMenu `id` input (input$sidebar_tabs),
  NOT a navbar input — smoke test uses `app$set_inputs(sidebar_tabs=<tabName>)`.
- SAME offline-renv gotcha as the siblings: run tests/app from REPO ROOT
  (`source("renv/activate.R")` then absolute app path). Sourcing activate.R from
  the app SUBDIR triggers a renv self-bootstrap DOWNLOAD that fails offline.

Related: [[confirmed-conventions]] [[pitfalls]]
