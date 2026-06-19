---
name: golem-app
description: Auto-invoked when creating or modifying a golem-based Shiny application. Governs project scaffolding, module creation, asset management, testing, and deployment within the golem framework.
---

# Golem Application Skill

This skill governs all work within a **golem** Shiny application. Golem apps are R packages — every golem project must be a valid, installable R package with DESCRIPTION, NAMESPACE, and roxygen2 documentation.

> **App-entry exception:** the project "never `app.R`" rule applies to **raw** three-file apps only. Golem uses its own entry points (`R/app_ui.R`, `R/app_server.R`, `R/run_app.R`, and a thin top-level `app.R`) — use them as the framework intends; do not convert a golem app to the three-file layout.

## When to Use Golem

- Production-grade applications that need package infrastructure
- Apps that will be installed, versioned, and deployed as artifacts
- Teams familiar with R package development (`devtools`, `roxygen2`, `testthat`)
- Apps targeting Posit Connect, ShinyProxy, or Docker deployment

## Project Scaffolding

Create a new golem project with:

```r
golem::create_golem("path/to/myapp")
```

This generates:

```
myapp/
├── DESCRIPTION
├── NAMESPACE
├── R/
│   ├── app_config.R        # app_sys() and get_golem_config()
│   ├── app_server.R         # app_server(input, output, session)
│   ├── app_ui.R             # app_ui(request) + golem_add_external_resources()
│   └── run_app.R            # exported run_app() entry point
├── dev/
│   ├── 01_start.R           # one-time project setup (run interactively)
│   ├── 02_dev.R             # ongoing dev commands (run interactively)
│   ├── 03_deploy.R          # deployment commands (run interactively)
│   └── run_dev.R            # dev launcher script
├── inst/
│   ├── app/www/             # static assets (JS, CSS, images)
│   │   └── favicon.ico
│   └── golem-config.yml     # environment-specific config
├── man/
└── tests/testthat/
```

**Important:** The `dev/` scripts are interactive notebooks — each line is meant to be run one at a time, not sourced as a script.

## File Naming Conventions

Golem enforces these prefixes automatically via its helper functions:

| File type | Prefix | Example |
|-----------|--------|---------|
| Module | `mod_` | `R/mod_data_import.R` |
| Factory/helper functions | `fct_` | `R/fct_helpers.R` |
| Utility functions | `utils_` | `R/utils_helpers.R` |
| Module-specific fct | `mod_<name>_fct_<fct>` | `R/mod_data_import_fct_connect.R` |
| Module-specific utils | `mod_<name>_utils_<utils>` | `R/mod_data_import_utils_wrapper.R` |

Function names within modules follow the pattern:
- UI: `mod_<name>_ui(id)`
- Server: `mod_<name>_server(id)`

## Adding Modules

```r
golem::add_module(
  name = "data_import",    # "mod_" prefix added automatically
  with_test = TRUE         # creates tests/testthat/test-mod_data_import.R
)
```

Generated module template (`R/mod_data_import.R`):

```r
#' data_import UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_data_import_ui <- function(id) {
  ns <- NS(id)
  tagList(

  )
}

#' data_import Server Functions
#'
#' @noRd
mod_data_import_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

  })
}

## To be copied in the UI
# mod_data_import_ui("data_import_1")

## To be copied in the server
# mod_data_import_server("data_import_1")
```

Wire modules into the app:

```r
# In R/app_ui.R
app_ui <- function(request) {
  tagList(
    golem_add_external_resources(),
    fluidPage(
      mod_data_import_ui("data_import_1")
    )
  )
}

# In R/app_server.R
app_server <- function(input, output, session) {
  mod_data_import_server("data_import_1")
}
```

## Adding Helper Files

```r
golem::add_fct("helpers", with_test = TRUE)    # R/fct_helpers.R
golem::add_utils("helpers", with_test = TRUE)  # R/utils_helpers.R

# Module-scoped helpers
golem::add_fct("connect", module = "data_import")   # R/mod_data_import_fct_connect.R
golem::add_utils("wrapper", module = "data_import")  # R/mod_data_import_utils_wrapper.R
```

## Adding Front-End Assets

All assets go to `inst/app/www/` and are auto-discovered by `bundle_resources()`:

```r
golem::add_js_file("script")           # inst/app/www/script.js
golem::add_js_handler("handlers")      # inst/app/www/handlers.js (with Shiny.addCustomMessageHandler)
golem::add_css_file("custom")          # inst/app/www/custom.css
golem::add_sass_file("custom")         # inst/app/www/custom.scss
```

## Configuration System

`inst/golem-config.yml` supports environment-specific settings:

```yaml
default:
  golem_name: myapp
  golem_version: 0.0.0.9000
  app_prod: no

production:
  app_prod: yes

dev:
  golem_wd: !expr golem::pkg_path()
```

Access config values:
```r
get_golem_config("app_prod")                          # reads from default
get_golem_config("app_prod", config = "production")   # reads from production
```

The active environment is set via `GOLEM_CONFIG_ACTIVE` or `R_CONFIG_ACTIVE` env vars.

## Runtime Options

Pass arbitrary options at launch and retrieve them in server/module code:

```r
# Launch
run_app(env = "production", data_path = "/data/")

# Retrieve anywhere in server code
get_golem_options("study_id")
get_golem_options("data_path")
```

## Dev/Prod Mode

```r
# Set in dev/run_dev.R
options(golem.app.prod = FALSE)

# Check in code
golem::app_prod()   # TRUE in production
golem::app_dev()    # TRUE in development

# Dev-only output (suppressed in production)
golem::cat_dev("debug: loaded ", nrow(data), " records\n")
```

## Internal File References

Always use `app_sys()` to reference files in `inst/`:

```r
# Correct
config_path <- app_sys("golem-config.yml")
template <- app_sys("app", "www", "template.html")

# Wrong — do not use system.file() directly
```

## Testing

Set up recommended tests:
```r
golem::use_recommended_tests()
```

This creates `tests/testthat/test-golem-recommended.R` which tests:
- `app_ui()` returns a valid tag list
- `app_server()` is a closure with correct formals
- `app_sys()` resolves paths
- `golem-config.yml` loads correctly
- `testServer()` basic input binding
- App launches without error

Per-module tests are created via `with_test = TRUE` in `add_module()`.

## Dependency Management

Use `{attachment}` to scan code and update DESCRIPTION:

```r
attachment::att_amend_desc()
```

Or add packages explicitly:
```r
usethis::use_package("dplyr")
```

Use roxygen2 import tags in `.R` files:
```r
#' @importFrom dplyr filter mutate
#' @import shiny
```

## Deployment

```r
# Posit Connect / shinyapps.io / Shiny Server
golem::add_positconnect_file()    # creates app.R for Posit Connect
golem::add_shinyappsio_file()     # creates app.R for shinyapps.io
golem::add_shinyserver_file()     # creates app.R for Shiny Server

# Docker
golem::add_dockerfile()                              # generic Dockerfile
golem::add_dockerfile_shinyproxy()                    # ShinyProxy Dockerfile
golem::add_dockerfile_with_renv(output_dir = "deploy") # Docker + renv lockfile
```

Always run `devtools::check()` before deployment.

## Key Conventions

1. **Every golem app is an R package.** `devtools::check()` must pass.
2. **Use golem helper functions** to create modules, fct, utils, and asset files — they enforce the naming conventions.
3. **Modules use `moduleServer()` pattern** (modern Shiny), not `callModule()`.
4. **`@noRd`** on all internal functions — they get roxygen docs but are not exported.
5. **`app_sys()`** is the only way to reference `inst/` files.
6. **`golem_add_external_resources()`** in `app_ui.R` auto-discovers all CSS/JS in `inst/app/www/`.
7. **`dev/` scripts are run interactively**, line by line — never source them.
8. **Package name must be lowercase**, no underscores or periods.
9. **Run `attachment::att_amend_desc()`** whenever imports change.
