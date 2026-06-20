---
name: raw-shiny-app
description: Auto-invoked when creating or modifying a Shiny application without a framework (golem, rhino, or leprechaun). Governs what is unique to framework-less apps — when to use raw Shiny vs. a framework, R/ auto-sourcing, www/ assets, config without a framework, a startup preflight, deployment, and when to graduate. Defers the three-file layout to the shiny-app-structure rule, modules to shiny-modules, reactivity to reactive-programming, and testing to shiny-testing.
---

# Raw Shiny Application Skill

This skill governs Shiny applications built **without a framework** — no golem,
rhino, or leprechaun. Use it for prototypes, small apps, internal tools, and
situations where framework overhead is not justified.

It covers only what is *specific to framework-less apps*. The cross-cutting
patterns live in their own places — read those, don't duplicate them:

| Topic | Where it's governed |
|-------|---------------------|
| Three-file layout (`global.R`/`ui.R`/`server.R`), file responsibilities | `shiny-app-structure` **rule** |
| Module pattern (`NS()`/`moduleServer()`), inter-module communication | `shiny-modules` **skill** |
| Reactive primitives (`reactive`/`observe`/`req`/…) | `reactive-programming` **skill** |
| Package loading, `::` vs. unqualified, pipes, style | `r-style` **rule** |
| testServer / shinytest2 / the testing hierarchy | `shiny-testing` **skill** |
| Error handling + logging | `shiny-error-handling` **skill** |

**Project rule (non-negotiable):** always the three-file layout — `global.R`,
`ui.R`, `server.R`. Never `app.R`. (Details: `shiny-app-structure` rule.)

## When to Use Raw Shiny

- Prototyping and proof-of-concept apps
- Small single-purpose tools (< 5 modules)
- Quick dashboards that won't grow into large production apps
- When the team is not familiar with any framework

## Directory Layout — the raw-app specifics

The three-file responsibilities are in the `shiny-app-structure` rule. What's
particular to a *raw* app is the supporting directories:

```
myapp/
├── global.R               # packages, sources, constants (see shiny-app-structure)
├── ui.R                   # UI definition          (see shiny-app-structure)
├── server.R               # server logic           (see shiny-app-structure)
├── R/                     # AUTO-SOURCED by Shiny (alphabetically) at startup
│   ├── mod_*.R            # one module per file: mod_<name>_ui / mod_<name>_server
│   └── utils_*.R          # shared helpers, business logic (testable without Shiny)
├── www/                   # static assets, served at the app root (/)
└── data/                  # app data files (reference.rds, lookup tables)
```

### `R/` auto-sourcing — the one behavior to remember

Files in `R/` are **auto-sourced by Shiny at startup (Shiny 1.5+), alphabetically**.

- Do **not** rely on sourcing order. If one file must load before another (e.g. a
  constant a module needs at source time), `source()` it explicitly from
  `global.R` instead of trusting the alphabetical sweep.
- This is the framework-less equivalent of golem's `R/` collation or rhino's
  `box` imports — there is no manifest, so naming and explicit `source()` are your
  only ordering levers.
- Keep business logic in `utils_*.R` / `fct_*.R` so it is unit-testable
  independently of Shiny (see `shiny-testing`).

## Static Assets (`www/`)

Place files in `www/` — they are served at the app root:

```r
tags$link(rel = "stylesheet", href = "style.css")   # www/style.css
tags$script(src = "script.js")                       # www/script.js
tags$img(src = "logo.png", height = "50px")          # www/logo.png
```

## Configuration without a framework

A raw app has no framework config system, so wire one of these yourself:

```r
# Simple — environment variables with defaults (good for one or two settings)
data_path <- Sys.getenv("DATA_PATH", "data/")

# config package — multiple environments (dev/staging/prod) from config.yml
library(config)
conf      <- config::get()      # reads R_CONFIG_ACTIVE to pick the environment
data_path <- conf$data_path
```

## Startup Preflight (resist "works on my machine")

The most common way a working app fails for someone else is **environment**, not
code: a package isn't installed, a secret/env var isn't set, or a dependency
resolves to a different version than was tested (the classic symptom is a cryptic
`object 'X' not found` deep inside a package — a symbol that exists in one version
but not another). Don't let these crash mid-flight with an opaque message. Run a
**preflight** at the very top of `global.R`, before the `library()` calls, and
turn each failure into a readable message.

Keep the helper base-R only and make every check best-effort (skip what it can't
verify) so it is portable across renv / packrat / Docker / Connect / a bare
library — **do not hard-code an assumption about the deployment environment**.

```r
# global.R — FIRST thing, before library() calls
source("R/utils_preflight.R")               # base-R only; safe pre-library

REQUIRED_PACKAGES <- c("shiny", "bslib", "DT")        # single source of truth
PREFLIGHT <- preflight(
  packages = REQUIRED_PACKAGES,
  env_vars = "DB_PASSWORD"                   # secrets the app needs at startup
)
if (length(PREFLIGHT) > 0) {
  warning(paste(c("Startup preflight problems:", PREFLIGHT), collapse = "\n  "),
          call. = FALSE)
}
for (pkg in REQUIRED_PACKAGES) {
  suppressPackageStartupMessages(library(pkg, character.only = TRUE))
}
```

Then in `server.R`, surface the findings to the user (blocking = `type="error"`,
drift = `type="warning"`) so they see "package X is missing / restore your
library" instead of a stack trace. A reference implementation lives in
`examples/05. shinychat/R/utils_preflight.R` (checks installed packages, required
env vars, and — if a lockfile is reachable — version drift, parsed via renv OR
jsonlite OR skipped). Copy it verbatim and adjust the package/secret lists.

This pairs with the Acceptance Gate (`CLAUDE.md`) and `testing` rules 6–7: the
gate proves the app runs **in your environment**; the preflight tells the *next*
environment exactly what it's missing.

## Deployment

Raw Shiny apps deploy directly — no package build step:

```r
rsconnect::deployApp()              # shinyapps.io
rsconnect::deployApp(appDir = ".")  # Posit Connect
```

Ship `renv.lock` with the app so the target restores the exact tested library
(`renv` rules). For Docker / Connect / CI specifics, see the deployment guidance
when available.

## When to Graduate to a Framework

Consider moving to golem, rhino, or leprechaun when:

- The app exceeds ~5 modules
- Multiple developers are contributing
- The app requires formal testing infrastructure (testthat, shinytest2, Cypress)
- Deployment needs Docker, CI/CD, or version pinning beyond `renv.lock`
- The app needs configuration for multiple environments and a build step

## Key Conventions (raw-app specific)

The module/reactivity/style conventions are owned by the skills and rules linked
at the top. The conventions unique to *raw* apps:

1. **Three-file layout always** — `global.R`, `ui.R`, `server.R`. No `app.R`.
2. **Use the `R/` directory** for modules and utilities — Shiny auto-sources it.
3. **Do not rely on `R/` sourcing order** — alphabetical; `source()` explicitly when order matters.
4. **Use `www/`** for static assets (CSS, JS, images).
5. **Keep business logic in `utils_*.R` / `fct_*.R`** so it is testable without Shiny.
6. **Ship `renv.lock`** with the app — there is no framework to pin dependencies for you.
