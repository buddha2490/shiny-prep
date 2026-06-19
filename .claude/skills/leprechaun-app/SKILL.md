---
name: leprechaun-app
description: Auto-invoked when creating or modifying a leprechaun-based Shiny application. Governs project scaffolding, a la carte feature addition, module creation, build system, and deployment within the leprechaun framework.
---

# Leprechaun Application Skill

This skill governs all work within a **leprechaun** Shiny application. Leprechaun is a **code generator, not a runtime dependency** — it scaffolds a Shiny app into a standard R package structure, then gets out of the way. Generated code belongs to your package with no runtime dependency on leprechaun itself.

> **App-entry exception:** the project "never `app.R`" rule applies to **raw** three-file apps only. Leprechaun scaffolds a package with its own entry points (`R/ui.R`, `R/server.R`, `R/run.R`, and a thin top-level `app.R`) — use them as the framework intends; do not convert a leprechaun app to the three-file layout.

## When to Use Leprechaun

- Package-based Shiny apps without the overhead of golem as a runtime dependency
- Projects that want a la carte features — add only what you need
- Teams that prefer owning all generated code (no framework lock-in)
- Lighter alternative to golem when full golem infrastructure is overkill

## Key Difference from Golem

Golem adds itself as a runtime `Imports` dependency and provides helper functions at runtime. Leprechaun generates self-contained code into your package — once scaffolded, leprechaun is only needed in `Suggests` (for updates). Your app has zero runtime dependency on leprechaun.

## Project Scaffolding

**Step 1:** Create a standard R package first:

```r
usethis::create_package("myapp")
```

**Step 2:** Scaffold from within the package root:

```r
leprechaun::scaffold(ui = "navbarPage")  # or "fluidPage"
```

`scaffold()` signature:

```r
leprechaun::scaffold(
  ui = c("navbarPage", "fluidPage"),
  bs_version = bootstrap_version(),   # auto-detects: shiny > 1.6 = 5, else 4
  overwrite = FALSE
)
```

This generates:

```
myapp/
├── .leprechaun                   # JSON lock file (tracks generated file versions)
├── DESCRIPTION                   # shiny, bslib, htmltools added to Imports
├── NAMESPACE
├── R/
│   ├── _disable_autoload.R       # disables shiny::loadSupport
│   ├── assets.R                  # serveAssets() — auto-discovers JS/CSS from inst/
│   ├── input-handlers.R          # custom Shiny input handlers
│   ├── leprechaun-utils.R        # make_send_message() helper
│   ├── run.R                     # run() and run_dev() functions
│   ├── server.R                  # server(input, output, session)
│   └── ui.R                      # ui(req) with navbarPage or fluidPage
├── inst/
│   ├── assets/                   # CSS and JS files (auto-served by serveAssets())
│   ├── dev/                      # Build scripts (sourced by leprechaun::build())
│   ├── img/                      # Images served at /img/ path
│   └── run/app.R                 # Dev runner script
└── R/zzz.R                       # .onLoad() registers img resource path
```

## File Naming Conventions

| Element | Convention | Example |
|---------|-----------|---------|
| Module file | `R/module_{name}.R` | `R/module_counter.R` |
| Module UI function | `{name}UI` | `counterUI(id)` |
| Module server function | `{name}_server` | `counter_server(id)` |
| Core generated files | kebab-case | `leprechaun-utils.R`, `input-handlers.R` |

## Adding Modules

```r
leprechaun::add_module("counter")
```

Creates `R/module_counter.R`:

```r
#' counter UI
#'
#' @param id Unique id for module instance.
#'
#' @keywords internal
counterUI <- function(id){
  ns <- NS(id)
  tagList(
    h2("counter")
  )
}

#' counter Server
#'
#' @param id Unique id for module instance.
#'
#' @keywords internal
counter_server <- function(id){
  moduleServer(
    id,
    function(input, output, session){
      ns <- session$ns
      send_message <- make_send_message(session)

      # your code here
    }
  )
}

# UI
# counterUI('id')

# server
# counter_server('id')
```

Note: Module names must not contain spaces. The function errors if the file already exists.

## A La Carte Features (`use_*` Functions)

Leprechaun's power is in adding only what you need. Each `use_*` function:
- Generates code into your package
- Updates the `.leprechaun` lock file
- Adds any required dependencies to DESCRIPTION
- Is idempotent-guarded (errors if already applied unless `overwrite = TRUE`)

### `use_sass()` — Sass/SCSS Pipeline

```r
leprechaun::use_sass()
```

- Creates `scss/main.scss` and `scss/_core.scss`
- Creates `inst/dev/sass.R` build script
- Adds `sass` to DESCRIPTION Suggests
- **Requires** `leprechaun::build()` to compile to `inst/assets/style.min.css`

### `use_config()` — YAML Configuration

```r
leprechaun::use_config()
```

- Creates `R/config.R` with `config_read()` and `config_get(value)`
- Creates `inst/config.yml` (default: `production: true`)
- Adds `yaml` to DESCRIPTION Imports

### `use_packer()` — JavaScript Build (webpack)

```r
# First scaffold packer, then enable in leprechaun
packer::scaffold_leprechaun()
leprechaun::use_packer()
```

- Requires an existing `package.json` (from packer scaffold)
- Creates `inst/dev/packer.R` build script
- **Requires** `leprechaun::build()` to bundle JS

### `use_js_utils()` — DOM Helper Functions

```r
leprechaun::use_js_utils()
```

- Requires `use_packer()` already applied
- Creates JS utilities: show/hide/toggle/enable/disable/eval
- Creates R wrappers: `show()`, `hide()`, `toggle()`, `disable()`, `enable()`, `eval_js()`

### `use_html_utils()` — Bootstrap HTML Helpers

```r
leprechaun::use_html_utils()
```

- Creates `R/html-utils.R`
- Bootstrap version-aware (v4 vs v5 templates)
- Provides: `col1()` through `col12()`, `badge()`, `alert()`, `tag2()`
- Bootstrap 5 also adds: `offCanvas*()` functions

### `use_endpoints_utils()` — Session Endpoints

```r
leprechaun::use_endpoints_utils()
```

- Creates `R/endpoint-utils.R`
- Adds `jsonlite` to DESCRIPTION Imports
- Provides: `register_endpoint()`, `register_endpoint_json()`, `http_response_json()`

## The Build System

```r
leprechaun::build()
```

Sources all `.R` files in `inst/dev/` alphabetically. This compiles Sass, bundles JS, or runs any other build steps added by `use_*` functions.

**Do NOT call `build()` from within the app.** It is a development-time command.

To auto-run build during `devtools::document()`, add the roclet to DESCRIPTION:

```
Roxygen: list(markdown = TRUE, roclets = c("namespace", "collate", "rd", "leprechaun::build_roclet"))
```

## R-to-JS Messaging

Leprechaun provides `make_send_message(session)` for namespaced custom messages:

```r
# In server or module code
send_message <- make_send_message(session)
send_message("my-handler", x = 1, y = 2)
```

This automatically handles namespace prefixing for modules.

## Asset Handling

### Simple approach (no build step)
Drop `.js` or `.css` files directly into `inst/assets/`. The `serveAssets()` function in `R/assets.R` auto-discovers and serves them.

### Packer approach (complex JS)
1. `packer::scaffold_leprechaun()` — creates `srcjs/`, webpack config
2. `leprechaun::use_packer()` — adds build script
3. Write JS in `srcjs/index.js`
4. `leprechaun::build()` — webpack bundles to `inst/`

## Deployment

```r
leprechaun::add_app_file()
```

Creates `app.R` at package root for deployment to Posit Connect / shinyapps.io:

```r
pkgload::load_all(reset = TRUE, helpers = FALSE)
run()
```

## Updating Generated Code

When leprechaun releases updates to its templates:

```r
leprechaun::sitrep()             # check if updates are available
leprechaun::update_scaffold()    # regenerate outdated files
```

Only files tracked in the `.leprechaun` lock file are updated. Your custom code is untouched.

## The Lock File (`.leprechaun`)

JSON file tracking which components are installed and at what version:

```json
{
  "package": "myapp",
  "version": "1.0.0",
  "bs_version": 5,
  "r": { "ui": "1.0.0", "assets": "1.0.0", ... },
  "uses": { "sass": "1.0.0", "config": "1.0.0", ... }
}
```

## Testing

Leprechaun does not generate an opinionated test scaffold. Use standard `testthat` / `shinytest2` conventions:

```r
usethis::use_testthat()
usethis::use_test("module_counter")
```

## Key Conventions

1. **Leprechaun is a code generator, not a runtime dependency.** It should be in `Suggests`, not `Imports`.
2. **The `.leprechaun` lock file must be committed** — it tracks what was generated and enables `update_scaffold()`.
3. **Run `leprechaun::build()` after modifying Sass or JS sources.**
4. **Module naming differs from golem:** UI is `{name}UI`, server is `{name}_server` (not `mod_` prefix).
5. **`serveAssets()` auto-discovers files in `inst/assets/`** — no manual registration needed.
6. **Files marked "DO NOT EDIT"** are managed by leprechaun's update system. Edit the others freely.
7. **Add features incrementally** with `use_*()` — only what you need, nothing more.
