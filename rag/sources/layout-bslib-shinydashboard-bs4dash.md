# Layout / UI Frameworks: bslib vs shinydashboard vs bs4Dash

*Part of the R package comparison series for pharma/clinical Shiny development.*

---

## 1. TL;DR

For any **new** app, use **bslib**. It is the modern Bootstrap 5 layout toolkit, actively developed by Posit, and is now the default UI layer for Shiny itself. Its composable primitives (`page_sidebar()`, `page_navbar()`, `card()`, `value_box()`, `layout_columns()`) cover everything shinydashboard and bs4Dash do, plus first-class theming via `bs_theme()`. Reach for **shinydashboard** or **bs4Dash** only when you specifically want the *AdminLTE dashboard chrome* (a fixed left rail with `menuItem()` tabs, collapsible boxes, a right control bar) or when you are **maintaining an existing app already built on one of them**. Of those two, prefer **bs4Dash** — it is AdminLTE 3 / Bootstrap 4 and a near-drop-in replacement for the older Bootstrap 3 shinydashboard.

| Framework | Bootstrap version | Best for | Avoid when | Maintenance status |
|---|---|---|---|---|
| **bslib** | Bootstrap 5 | All new apps; modern dashboards, navbar/sidebar apps, value-box landing pages; anything needing Sass theming | You must match an existing AdminLTE app's look, or a stakeholder explicitly demands the classic dashboard chrome | **Active** — Posit, default Shiny UI layer |
| **bs4Dash** | Bootstrap 4 (AdminLTE 3) | AdminLTE-style dashboards needing control bars, collapsible/closable boxes, gradient value boxes; migrating off shinydashboard | New greenfield work where bslib would do; apps needing the newest Bootstrap components | **Community** — RinteRface, maintained but slower cadence |
| **shinydashboard** | Bootstrap 3 (AdminLTE 2) | Maintaining legacy apps already built on it | Any new app; anything needing Bootstrap 4/5 components or current security patches | **Maintenance mode** — bug fixes only, no new features |

The Bootstrap version divide is the spine of this comparison: shinydashboard is stuck on **Bootstrap 3 / AdminLTE 2** (legacy), bs4Dash modernized it to **Bootstrap 4 / AdminLTE 3**, and bslib leapt to **Bootstrap 5** with a completely different, composable design philosophy.

---

## 2. The contenders

**bslib** is a modern Bootstrap 5 (and 4/3-capable) toolkit, not a dashboard template. You compose a UI from small, fillable primitives — pages (`page_sidebar()`, `page_navbar()`, `page_fillable()`), `card()`s, `value_box()`es, `layout_columns()` / `layout_column_wrap()`, `sidebar()`, and `accordion()`s. Theming is data-driven through `bs_theme()` (a `bs_theme()` object carrying Sass layers), so colors, fonts, and Bootstrap variables are first-class R arguments. It is developed by Posit and is the UI foundation Shiny now ships on.

**shinydashboard** is the classic AdminLTE 2 dashboard skin on **Bootstrap 3**. You assemble a fixed structure: `dashboardPage(dashboardHeader(), dashboardSidebar(), dashboardBody())`, navigate via a `sidebarMenu()` of `menuItem()`s wired to `tabItems()`, and fill the body with `box()`, `valueBox()`, and `infoBox()`. It pioneered the "dashboard in R" pattern but is in maintenance mode (current version ~0.7.3) and frozen on Bootstrap 3.

**bs4Dash** ("A 'Bootstrap 4' Version of 'shinydashboard'", by RinteRface) is the AdminLTE 3 / Bootstrap 4 successor. It mirrors shinydashboard's API almost name-for-name (`dashboardPage()`, `dashboardSidebar()`, `sidebarMenu()`, `menuItem()`, `box()`, `valueBox()`) so migration is near drop-in, while adding richer widgets — a right-hand `dashboardControlbar()`, closable/maximizable boxes, gradient value boxes, accordions, ribbons, user cards, and `fresh`-based theming.

---

## 3. Dimension-by-dimension comparison

### Page types & layout primitives

bslib is **compositional**: you pick a page shell and nest primitives freely.

```r
library(bslib)

ui <- page_sidebar(
  title   = "Safety Review",
  sidebar = sidebar(selectInput("study", "Study", choices = studies)),
  layout_columns(
    card(card_header("Enrollment"), plotOutput("enroll")),
    card(card_header("Listing"), DT::DTOutput("listing")),
    col_widths = c(5, 7)
  )
)
```

`layout_columns()` uses a 12-unit grid (`col_widths = c(6, 6, 12)`, negative values for spacers) and `breakpoints()` for responsive widths; `layout_column_wrap()` auto-wraps equal-width items. Both work *inside* a card too.

shinydashboard and bs4Dash are **template-shaped**: `dashboardPage(header, sidebar, body)` is fixed, and you fill the body with `fluidRow()` + `box(width = ...)` on the same Bootstrap 12-column grid. The structure is rigid by design — fast to stand up a conventional dashboard, harder to deviate from.

- **Strength (AdminLTE pair):** zero decisions — the dashboard chrome is prebuilt.
- **Trade-off:** that rigidity is a ceiling. Non-dashboard layouts (a wizard, a report, an embedded panel) fight the template. bslib has no such ceiling but asks you to compose the layout yourself.

### Cards / boxes / value boxes

| Concept | bslib | shinydashboard | bs4Dash |
|---|---|---|---|
| Container | `card()` + `card_header()`/`card_body()`/`card_footer()` | `box()` | `box()` / `bs4Card()` |
| Tabbed container | `navset_card_tab()`, `navset_card_pill()` | `tabBox()` | `tabBox()` / `bs4TabCard()` |
| KPI box | `value_box(title, value, showcase = bsicons::bs_icon(...))` | `valueBox(value, subtitle, icon, color)` | `valueBox()` / `bs4ValueBox()` (supports `gradient`) |
| Icon+stat box | (use `value_box()`) | `infoBox()` | `infoBox()` / `bs4InfoBox()` |
| Collapsible / closable | `full_screen = TRUE` (expand) | `collapsible = TRUE` | `collapsible`, `closable`, `maximizable` |

bslib's `card()` is fillable and full-screen-expandable (`full_screen = TRUE`) and its `value_box()` has flexible showcase layouts (`"left center"`, `"top right"`, `"bottom"`) that can hold an icon *or* a live `plotOutput()`.

- **Strength (bslib):** cards are the same primitive everywhere — in pages, columns, navsets. Consistent and fillable.
- **Strength (AdminLTE pair):** `box()` ships dashboard affordances out of the box — collapse, and in bs4Dash also close/maximize and a per-box dropdown. Replicating closable/maximizable boxes in bslib means custom work.
- **Trade-off (bslib):** no built-in "collapse this box" toggle on `card()`; you compose it. **Trade-off (AdminLTE):** boxes are visually heavier (header bars, borders) and less flexible to restyle.

### Sidebars & navigation

This is where the philosophies diverge most.

- **shinydashboard / bs4Dash** — the sidebar *is* the navigation. A `sidebarMenu(id = ...)` holds `menuItem(text, tabName = "x")` entries, each paired to a `tabItem(tabName = "x", ...)` in the body via `tabItems()`. The contract is explicit: a `menuItem`'s `tabName` **must** match a `tabItem`'s `tabName` or nothing happens. Server-side tab switching is `updateTabItems(session, "tabs", "x")`. bs4Dash also adds a **right-hand control bar** (`dashboardControlbar()` / `controlbarMenu()`) — a second collapsible rail with no shinydashboard or bslib equivalent.

```r
# shinydashboard / bs4Dash navigation contract
dashboardSidebar(
  sidebarMenu(
    id = "tabs",
    menuItem("Overview", tabName = "overview", icon = icon("chart-line")),
    menuItem("Listings", tabName = "listings", icon = icon("table"))
  )
)
# body
dashboardBody(
  tabItems(
    tabItem("overview", ...),
    tabItem("listings", ...)
  )
)
```

- **bslib** — navigation and sidebar are *separate* concerns. Navigation uses `navset_*()` / `nav_panel()` (and `page_navbar()` for full-page nav); the `sidebar()` is an independent layout element you can attach to a page, a card, or a navset. `nav_panel()` needs no `tabName` bookkeeping — the value is auto-derived. Programmatic control is `nav_select()` / `nav_show()` / `nav_hide()`; sidebars toggle with `toggle_sidebar(id)`.

```r
page_navbar(
  title = "Clinical Review",
  sidebar = sidebar(selectInput("trt", "Treatment", choices = arms)),
  nav_panel("Overview", ...),
  nav_panel("Adverse Events", ...),
  nav_spacer(),
  nav_menu("Links", nav_item(a("Protocol", href = "...")))
)
```

- **Strength (AdminLTE pair):** the menu-item rail is an instantly recognizable, dense navigation model — good for 6–15 sections.
- **Trade-off:** the `tabName`↔`tabName` coupling is a classic silent-failure source (mismatch = dead menu item), and the sidebar is bolted to navigation, so a sidebar of *inputs* (not nav) is awkward.
- **Strength (bslib):** sidebar-as-inputs and nav-as-sections are decoupled and far more flexible; `page_navbar()` can itself take a page-level `sidebar` shown on every panel.
- **Trade-off (bslib):** no single prebuilt "icon rail of sections" widget as polished as the AdminLTE menu; you assemble the equivalent.

### Theming & customization

| | bslib | shinydashboard | bs4Dash |
|---|---|---|---|
| Mechanism | `bs_theme()` Sass layers | fixed `skin` + custom CSS | `freshTheme =` via the `fresh` package + per-component `status` |
| Color model | Bootstrap 5 theme variables + contextual classes | **AdminLTE color names** | **Bootstrap statuses** |
| Programmatic | `bs_add_variables()`, `bs_add_rules()`, runtime theming | none (edit CSS) | `fresh::create_theme(bs4dash_status(...), ...)` |

bslib theming is the standout: `bs_theme(bg, fg, primary, base_font, ...)` returns a theme object, you can pull values back with `bs_get_variables()`, layer raw Sass with `bs_add_rules()`, and preview live. Bootswatch presets are built in.

```r
theme <- bs_theme(
  version = 5,
  primary = "#0b5394",          # corporate blue
  base_font = font_google("Inter"),
  "border-radius" = "0.25rem"
)
```

> **VERIFIED GOTCHA — color naming differs by framework, do not mix them up:**
> - **shinydashboard** uses **AdminLTE 2 color names**: `valueBox(color = "aqua")`, `"light-blue"` (hyphenated), plus `"red"`, `"yellow"`, `"green"`, `"navy"`, `"teal"`, `"olive"`, `"maroon"`, etc. Page skin is one of `"blue"`, `"black"`, `"purple"`, `"green"`, `"red"`, `"yellow"`.
> - **bs4Dash** uses **Bootstrap 4 statuses**: `box(status = "primary")`, `"info"`, `"success"`, `"warning"`, `"danger"`. Its extended palette spells light blue as **`"lightblue"` (one word)** and has **no `"aqua"`**. So `status = "aqua"` from a shinydashboard app silently breaks on migration.
> - **bslib** (Bootstrap 5) uses **theme variables and contextual classes** — `value_box(theme = "primary")` or named colors like `theme = "teal"`, and `bs_theme(primary = ...)`. No AdminLTE color names at all.

- **Strength (bslib):** theming is in R, portable, previewable, and powered by Sass — corporate branding without hand-written CSS.
- **Trade-off:** the abstraction has a learning curve, and `bs_add_variables()`/`bs_add_rules()` customizations are *not* guaranteed portable across Bootstrap major versions.
- **Strength (bs4Dash):** rich per-component `status` colors and `fresh` theming.
- **Trade-off (shinydashboard):** essentially "the skins you're given, plus CSS." Real branding means fighting AdminLTE 2 CSS by hand.

### Responsiveness & fillable / mobile

bslib was built around **fillable** layouts (flexbox): `page_fillable()`, `card()`, and `layout_sidebar()` grow/shrink to the viewport, and `fillable_mobile = TRUE` makes them fill height on narrow screens. Breakpoint-aware column widths are explicit via `breakpoints(sm = ..., md = ..., lg = ...)`. This is the right model for dashboards that must look correct on a tablet at the bedside or in a monitoring room.

shinydashboard and bs4Dash are responsive in the older Bootstrap row/column sense (boxes stack on small screens), and the AdminLTE sidebar collapses to a hamburger — but they are not "fillable-first." Tall dashboards tend to scroll rather than fit-to-screen, and fine-grained breakpoint control is weaker.

### Dynamic UI & control bars

- bslib: `nav_insert()`/`nav_remove()`, `nav_select()`, `accordion_panel_insert()`/`_open()`/`_close()`, `toggle_sidebar()`, `update_tooltip()` — a coherent set of server-side update functions.
- shinydashboard: `renderMenu()`/`sidebarMenuOutput()` for dynamic menus, `updateTabItems()`.
- bs4Dash: the above plus `updateControlbar()`, `updateBox()`/`updateCard()` (`action = "remove"/"toggle"/"toggleMaximize"`), `updateAccordion()`, and `skinSelector()`. The **control bar** (a second right rail) is unique to bs4Dash and useful for secondary filters or settings you don't want crowding the main sidebar.

- **Strength (bs4Dash):** the richest set of *imperative* dashboard widgets (boxes you can close/restore/maximize from the server, a control bar).
- **Trade-off:** more moving parts and a heavier client; many of these widgets have no bslib equivalent, so an app that leans on them is hard to port.

### Bootstrap version implications (ecosystem, security, maintenance)

This is the decisive axis.

- **shinydashboard = Bootstrap 3.** Bootstrap 3 reached end-of-life years ago. Third-party Bootstrap 5 components (and most modern bslib-targeted helpers) do not apply. You are on a frozen, unsupported front-end stack — relevant for any **validated/regulated** environment where dependency currency and security posture are reviewed.
- **bs4Dash = Bootstrap 4 (AdminLTE 3).** A large step forward, but Bootstrap 4 is itself superseded by Bootstrap 5. Community-maintained, so cadence depends on RinteRface.
- **bslib = Bootstrap 5.** Current, actively patched by Posit, and the same Bootstrap that Shiny itself targets — so Shiny inputs, `htmlwidgets`, and the broader ecosystem line up cleanly.

Mixing a Bootstrap-3 framework with components expecting Bootstrap 5 causes CSS/JS conflicts. The framework you choose effectively pins your whole front-end Bootstrap version.

### Maintenance / future-proofing

- **bslib:** active development, Posit-backed, the strategic direction for Shiny UI. Safest long-term bet.
- **bs4Dash:** maintained by RinteRface (community), stable, but not the trajectory Posit is investing in.
- **shinydashboard:** maintenance mode — bug fixes only, no new features, no Bootstrap upgrade planned. Treat it as legacy.

---

## 4. Decision guide

**Use bslib when…**
- It's a new app (default — and the project convention).
- You need real theming/branding via `bs_theme()` and Sass.
- You want fillable, mobile-correct, responsive layouts.
- Your layout isn't a stereotypical left-rail dashboard (navbar apps, report pages, embedded panels, wizards).

**Don't use bslib when…**
- You're patching an existing shinydashboard/bs4Dash app — don't introduce a second framework (see §6).
- A stakeholder contractually requires the exact AdminLTE dashboard look and you can't rebuild it.

**Use bs4Dash when…**
- You want the AdminLTE dashboard chrome but on a modern-ish (Bootstrap 4) stack.
- You need its specific widgets: right-hand control bar, closable/maximizable boxes, gradient value boxes, ribbons, user cards.
- You're migrating *off* shinydashboard and want a near-drop-in upgrade.

**Don't use bs4Dash when…**
- It's greenfield and bslib would serve — bslib is more future-proof.
- You need the newest Bootstrap 5 components or tight alignment with current Shiny.

**Use shinydashboard when…**
- You are maintaining an existing shinydashboard app and a full rewrite isn't justified yet.

**Don't use shinydashboard when…**
- You are starting anything new. It's Bootstrap 3, frozen, and unsupported for new components — a liability in a regulated review.

---

## 5. Pharma / clinical context

- **Clinical review dashboards (patient listings, query review):** bslib `page_sidebar()` with a `sidebar()` of study/subject/visit filters and a `card()` wrapping a `DT::DTOutput()` listing is the cleanest fit, and `full_screen = TRUE` lets reviewers expand a dense listing to fill the screen. If an existing review tool is already shinydashboard, keep it there.
- **Safety monitoring dashboards (AE/SAE trends, lab shifts):** the AdminLTE menu-rail model (shinydashboard/bs4Dash `sidebarMenu()` → `tabItems()`) maps naturally to "one tab per safety domain," which is why so many legacy safety dashboards use it. For a new one, bslib `page_navbar()` (a `nav_panel()` per domain) with a shared page-level `sidebar` of filters achieves the same with cleaner code and no `tabName` coupling.
- **KPI / value-box landing pages (enrollment, screen-fail rate, data-cleaning status):** bslib `value_box()` in a `layout_columns()` row is the strongest option — flexible showcase layouts, can embed a sparkline `plotOutput()`, and theme colors follow your `bs_theme()`. bs4Dash `valueBox(gradient = TRUE)` is a fine alternative within an existing bs4Dash app.
- **Maintaining LEGACY pharma apps — the migration reality:** a large share of existing pharma Shiny apps are **shinydashboard** (it was *the* dashboard option for years). Do not rewrite a validated, working shinydashboard app to bslib on a whim — revalidation cost is real. If a refresh is warranted, the low-risk path is **shinydashboard → bs4Dash** (near drop-in, modernizes to Bootstrap 4); a full **shinydashboard → bslib** move is a genuine rewrite and should be scoped as one.

> **Project convention:** for **new** apps, prefer **bslib** (`page_sidebar`, `page_navbar`, cards). The other two are AdminLTE-dashboard frameworks reserved for legacy maintenance or a deliberate need for the AdminLTE chrome.

---

## 6. Interop & migration notes

**Can you mix them? Generally no — pick one.** Each framework pulls in its own Bootstrap version and CSS/JS bundle (Bootstrap 3 vs 4 vs 5). Loading shinydashboard *and* bslib (or bs4Dash + bslib) in one app produces conflicting Bootstrap stylesheets and unpredictable rendering. Choose one framework per app and commit to it.

**shinydashboard → bs4Dash (near drop-in):** bs4Dash deliberately mirrors the API — `dashboardPage()`, `dashboardSidebar()`, `sidebarMenu()`/`menuItem()`, `tabItems()`/`tabItem()`, `box()`, `valueBox()`, `infoBox()`, `updateTabItems()` all carry over. The main edits are:
- **Colors:** swap AdminLTE names for Bootstrap statuses — `color = "aqua"` → `status = "primary"` (and remember `"light-blue"` → `"lightblue"`, no more `"aqua"`).
- **New slots:** optional `controlbar =` and `footer =` in `dashboardPage()`.
- **Theming:** AdminLTE skins → `freshTheme =` via `fresh`.

**shinydashboard → bslib (a rewrite):** there is no drop-in path. The page model, navigation model (`menuItem`/`tabItem` → `nav_panel`), container model (`box()` → `card()`), and theming (`skin` → `bs_theme()`) are all different. Plan it as a deliberate rebuild, not a find-and-replace.

**bslib cards inside other frameworks:** because `card()` is "just HTML," a bslib `card()` can sometimes be dropped into a shinydashboard/bs4Dash body and *mostly* render — but it will not pick up the framework's theme, may clash with the older Bootstrap CSS, and is not a supported pattern. Don't rely on it; use the host framework's native `box()`.

---

## 7. Bottom line

1. **New app? Use bslib.** It is the modern, Posit-maintained, Bootstrap 5 default — composable cards/value boxes/sidebars, real theming via `bs_theme()`, fillable responsive layouts. This is the project convention.
2. **Need the AdminLTE dashboard chrome (menu rail, collapsible/closable boxes, a control bar)? Use bs4Dash** — Bootstrap 4, actively community-maintained, and the right target if you're modernizing a shinydashboard app.
3. **shinydashboard is legacy.** Keep it only to maintain apps already built on it; never start something new on Bootstrap 3.

Default hierarchy: **bslib > bs4Dash > shinydashboard.**
