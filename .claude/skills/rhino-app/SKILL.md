---
name: rhino-app
description: Auto-invoked when creating or modifying a rhino-based Shiny application. Governs project scaffolding, box module imports, view/logic separation, Sass/JS pipelines, and Cypress testing within the rhino framework.
---

# Rhino Application Skill

This skill governs all work within a **rhino** Shiny application (by Appsilon). Rhino enforces strict software engineering practices: modular architecture via `box::use()`, no `library()` or `source()` in app code, and a clear separation between view (Shiny) and logic (pure R) layers.

> **App-entry exception:** the project "never `app.R`" rule applies to **raw** three-file apps only. Rhino owns a top-level `app.R` containing only `rhino::app()` (never edit it) and organizes code under `app/` — use the framework's structure; do not convert a rhino app to the three-file layout.

## When to Use Rhino

- Enterprise applications requiring strict code organization
- Teams that want enforced linting, formatting, and testing standards
- Apps needing a JS/Sass build pipeline (webpack, Dart Sass)
- Projects with Cypress E2E testing requirements
- When `box::use()` module system is preferred over `library()` + `::` imports

## Project Scaffolding

```r
rhino::init("myapp")
# Then: setwd("myapp") and restart R so .Rprofile loads renv
```

This generates:

```
myapp/
├── app/
│   ├── js/
│   │   └── index.js              # JS entry point (ES6+, webpack)
│   ├── logic/
│   │   └── __init__.R            # Pure R business logic (no Shiny)
│   ├── static/
│   │   ├── favicon.ico
│   │   ├── css/app.min.css       # BUILD OUTPUT — do not edit
│   │   └── js/app.min.js         # BUILD OUTPUT — do not edit
│   ├── styles/
│   │   └── main.scss             # Sass entry point
│   ├── view/
│   │   └── __init__.R            # Shiny modules only
│   └── main.R                    # Root module — exports ui() and server()
├── tests/
│   ├── cypress/e2e/app.cy.js     # Cypress E2E tests
│   ├── testthat/test-main.R      # R unit tests
│   └── cypress.config.js
├── .lintr                        # lintr config (box.linters)
├── .Rprofile                     # renv activation
├── app.R                         # DO NOT EDIT — contains only rhino::app()
├── config.yml                    # Runtime config (log levels, etc.)
├── dependencies.R                # Package declarations (library() calls for renv)
├── renv.lock                     # Locked dependency versions
└── rhino.yml                     # Framework config (sass engine, etc.)
```

## The Cardinal Rules

1. **No `library()` in app code** — only in `dependencies.R` for renv detection
2. **No `source()` in app code** — use `box::use()` for all imports
3. **No `package::function()` in app code** — use `box::use(pkg[fn])`
4. **Never edit `app.R`** — it only contains `rhino::app()`
5. **Never edit `app/static/css/app.min.css` or `app/static/js/app.min.js`** — these are build outputs

## box::use() Import System

All imports use `box::use()` in two separate blocks — external packages first, then local modules:

```r
# External packages — explicit function imports
box::use(
  dplyr[case_when, filter, mutate, select],
  shiny[moduleServer, NS, renderText, tagList],
)

# Local modules — separate box::use block
box::use(
  app/logic/data_validation,
  app/view/chart[ui, server],
)
```

**Import rules:**
- Explicit function lists — no glob imports
- Alphabetical ordering at both package and function level
- Trailing commas on the last item
- If >8 functions needed from one package, import the whole package and use `pkg$fn()` notation

**Exporting functions:**
Every function that should be importable must have `#' @export`:

```r
#' @export
ui <- function(id) { ... }

#' @export
server <- function(id) { ... }
```

Without `#' @export`, functions are private to the module file.

## app/view/ vs app/logic/ Organization

### `app/view/` — Shiny modules only

Every file exports a `ui(id)` and `server(id, ...)` pair:

```r
# app/view/data_table.R
box::use(
  shiny[moduleServer, NS, renderTable, tableOutput, tagList],
)

box::use(
  app/logic/data_processing[clean_data],
)

#' @export
ui <- function(id) {
  ns <- NS(id)
  tagList(
    tableOutput(ns("table"))
  )
}

#' @export
server <- function(id, raw_data) {
  moduleServer(id, function(input, output, session) {
    output$table <- renderTable({
      clean_data(raw_data())
    })
  })
}
```

### `app/logic/` — Pure R, no Shiny

Data transformation, utility functions, calculations. No `shiny` imports allowed:

```r
# app/logic/data_processing.R
box::use(
  dplyr[filter, mutate],
)

#' @export
clean_data <- function(df) {
  df %>%
    filter(!is.na(value)) %>%
    mutate(value_scaled = value / 100)
}
```

### `app/main.R` — Root orchestration module

Composes view modules and wires reactive data flows:

```r
# app/main.R
box::use(
  shiny[fluidPage, moduleServer, NS, reactive],
)

box::use(
  app/view/data_table,
  app/view/summary_chart,
)

#' @export
ui <- function(id) {
  ns <- NS(id)
  fluidPage(
    data_table$ui(ns("table")),
    summary_chart$ui(ns("chart"))
  )
}

#' @export
server <- function(id) {
  moduleServer(id, function(input, output, session) {
    raw_data <- reactive({ load_data() })
    data_table$server("table", raw_data = raw_data)
    summary_chart$server("chart", raw_data = raw_data)
  })
}
```

## Accessing Imported Modules

```r
# Module-level import (dot notation)
box::use(app/view/chart)
chart$ui(ns("chart"))
chart$server("chart", data = data)

# Function-level import (direct call)
box::use(app/view/chart[ui, server])
ui(ns("chart"))
server("chart", data = data)
```

## Dependency Management

```r
# Add a package (updates dependencies.R and renv.lock)
rhino::pkg_install("dplyr")

# Remove a package
rhino::pkg_remove("dplyr")
```

`dependencies.R` contains `library()` calls solely as declarations for renv:

```r
# dependencies.R
library(box)
library(dplyr)
library(rhino)
library(shiny)
```

## Sass/CSS Pipeline

**Entry point:** `app/styles/main.scss`
**Output:** `app/static/css/app.min.css` (auto-injected by `rhino::app()`)

```r
rhino::build_sass()              # one-time build
rhino::build_sass(watch = TRUE)  # watch mode (Node.js sass engine only)
```

Configure the Sass engine in `rhino.yml`:

```yaml
sass: node     # "node" (Dart Sass, recommended), "r" (R sass package), or "custom"
```

Use `sass: custom` when integrating with `bslib` theming.

## JavaScript Pipeline

**Entry point:** `app/js/index.js`
**Output:** `app/static/js/app.min.js` (auto-injected by `rhino::app()`)
**Toolchain:** Babel + webpack (ES6+ supported)

```r
rhino::build_js()              # one-time build
rhino::build_js(watch = TRUE)  # watch mode
```

Exported JS functions are accessible via the `App` namespace:

```js
// app/js/index.js
export function showHelp() {
  alert("Help text");
}
```

```r
# In Shiny UI
tags$button(onclick = "App.showHelp()")
```

## Configuration

### `rhino.yml` — Framework config

```yaml
sass: node     # sass engine selection
```

### `config.yml` — Runtime config (uses the config package)

```yaml
default:
  rhino_log_level: !expr Sys.getenv("RHINO_LOG_LEVEL", "INFO")
  rhino_log_file: !expr Sys.getenv("RHINO_LOG_FILE", NA)
```

## Testing

### R Unit Tests

```r
rhino::test_r()           # run testthat tests
rhino::auto_test_r()      # watch mode, auto-rerun on change
rhino::covr_r()           # test coverage
```

Tests live in `tests/testthat/`. Standard testthat conventions. Test `app/logic/` functions independently of Shiny.

### Cypress E2E Tests

```r
rhino::test_e2e()                    # headless mode
rhino::test_e2e(interactive = TRUE)  # opens Cypress UI
```

Tests live in `tests/cypress/e2e/`. CSS selector convention for Shiny module elements:

```
#app-{moduleName}-{outputId}
```

Example test:

```javascript
describe("Data Table", () => {
  beforeEach(() => {
    cy.visit("/");
  });

  it("displays the table", () => {
    cy.get("#app-table-data_table").should("be.visible");
  });
});
```

## Linting and Formatting

```r
rhino::lint_r()       # lint R files (app/ and tests/testthat/)
rhino::lint_sass()    # lint Sass files
rhino::lint_js()      # lint JS files

rhino::format_r()     # auto-format R (styler + box.linters)
rhino::format_sass()  # auto-format Sass
rhino::format_js()    # auto-format JS
```

The `.lintr` file uses `box.linters::rhino_default_linters` which enforces `box::use()` compliance.

## Naming Conventions

| Element | Convention | Example |
|---------|-----------|---------|
| R files | `snake_case.R` | `data_validation.R` |
| R functions | `snake_case` | `clean_data()` |
| CSS classes | `kebab-case` | `component-box` |
| JS functions | `camelCase` | `App.showHelp()` |
| Shiny module IDs | `snake_case` | `ns("data_table")` |

## Key Developer Commands

```r
rhino::app()            # returns runnable app object (used by app.R)
rhino::diagnostics()    # system diagnostics
rhino::devmode()        # development mode (watches files, rebuilds)

rhino::build_sass()     # compile Sass
rhino::build_js()       # compile JS

rhino::test_r()         # R unit tests
rhino::test_e2e()       # Cypress E2E tests
rhino::covr_r()         # test coverage

rhino::lint_r()         # lint R
rhino::format_r()       # format R

rhino::pkg_install()    # add dependency
rhino::pkg_remove()     # remove dependency
```
