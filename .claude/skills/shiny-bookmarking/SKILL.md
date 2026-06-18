---
name: shiny-bookmarking
description: Auto-invoked when implementing bookmarkable state in Shiny — saving/restoring app state via URL or server. Governs enableBookmarking(), the function(request) UI signature, bookmarkButton(), setBookmarkExclude(), URL vs server stores, tab/multi-button bookmarking, updateQueryString(), the onBookmark/onRestore/onBookmarked/onRestored callbacks for non-input state, bookmarking with modules, and reproducibility with set.seed/repeatable.
---

# Shiny Bookmarking State

Bookmarking lets users save the state of an app and get a URL that restores it. Two stores:

| Store | URL looks like | Values visible? | Extra files? | URL length risk | Hosting requirement |
|-------|----------------|-----------------|--------------|-----------------|---------------------|
| `"url"` | `...?_inputs_&n=200` | Yes (in query string) | No | Yes — ~2000-char browser limit | Works everywhere |
| `"server"` | `...?_state_id_=d80625dc681e913a` | No | Yes | No | Shiny Server (OSS/Pro ≥1.4.7), Posit Connect (≥1.4.6) |

**Pharma note:** prefer `"server"` for clinical apps — patient/filter selections stay off the URL (no PII leakage into browser history, proxy logs, or shared links), and server state can persist uploaded files. URL bookmarking is fine for non-sensitive demos and small input sets.

---

## The two required changes

Per the project's three-file layout (never `app.R`), enabling bookmarking touches **`global.R`** and **`ui.R`**:

### 1. `ui.R` — wrap the UI in `function(request)`

The UI must be a **function taking one argument** (`request`), not a bare UI object.

```r
## ui.R ##
function(request) {
  page_sidebar(
    title = "Patient Explorer",
    sidebar = sidebar(
      selectInput("trt", "Treatment", choices = c("Placebo", "Drug A", "Drug B")),
      sliderInput("age", "Age range", min = 18, max = 90, value = c(18, 90)),
      bookmarkButton()
    ),
    DT::DTOutput("listing")
  )
}
```

**Critical:** every input-generating call (`selectInput()`, `sliderInput()`, …) must run **inside** the `request` function — directly or via a helper the function calls. Inputs created once and stored in a top-level variable **will not restore**.

```r
## global.R ##
# WRONG — input built outside the request function; restore silently fails
trt_input <- selectInput("trt", "Treatment", choices = ...)

## ui.R ##
function(request) {
  page_sidebar(sidebar = sidebar(trt_input, bookmarkButton()))  # broken
}
```

### 2. `global.R` — call `enableBookmarking()`

```r
## global.R ##
library(shiny)
library(bslib)

source("R/mod_listing.R")

enableBookmarking(store = "server")   # or "url"
```

`server.R` is unchanged — a normal `function(input, output, session)`.

> The PDF shows `shinyApp(ui, server, enableBookmarking = "url")` for single-file apps. In this project's three-file layout there is no `shinyApp()` call, so the equivalent is `enableBookmarking()` in `global.R`.

---

## How restore works (and when it breaks)

Bookmarking automatically saves **all input values** and re-seeds them on restore. If the reactive flow is straightforward (inputs → reactives → outputs), the app restores cleanly.

It breaks — and needs manual `onBookmark`/`onRestore` logic — when the state of inputs at time *t* does **not** fully determine the outputs at time *t*. Common culprits:

- State held in `reactiveValues()` / `reactiveVal()` / an R6 object rather than inputs
- `insertUI()` / dynamically generated inputs
- Values computed from random numbers (see reproducibility below)

**Inputs never saved:**
- `passwordInput()` — never bookmarked (any store)
- `fileInput()` — saved only with `store = "server"`, never with `"url"`

---

## Excluding inputs — `setBookmarkExclude()`

Call in the server function with the input names to skip:

```r
## server.R ##
function(input, output, session) {
  setBookmarkExclude(c("search_box", "scratch_value"))
}
```

You must exclude any bookmark buttons you trigger manually (see below), or restoring re-triggers bookmarking immediately.

---

## Bookmarking the active tab

Give the tab container an `id` and its selected tab is saved automatically:

```r
## ui.R ##
function(request) {
  page_navbar(
    id = "main_tabs",          # <- required for the tab to be bookmarked
    nav_panel("Overview", ...),
    nav_panel("Listings", ...)
  )
}
```

Same rule for `tabsetPanel(id = ...)` and `navlistPanel(id = ...)`.

---

## Multiple bookmark buttons

Each needs a unique `id`, a manual trigger via `session$doBookmark()`, and exclusion from bookmarking:

```r
## ui.R ##
function(request) {
  page_fillable(
    navset_tab(
      id = "tabs",
      nav_panel("One", checkboxInput("chk1", "Checkbox 1"), bookmarkButton(id = "bookmark1")),
      nav_panel("Two", checkboxInput("chk2", "Checkbox 2"), bookmarkButton(id = "bookmark2"))
    )
  )
}

## server.R ##
function(input, output, session) {
  # Exclude the buttons, or restore immediately re-triggers a bookmark
  setBookmarkExclude(c("bookmark1", "bookmark2"))

  observeEvent(input$bookmark1, { session$doBookmark() })
  observeEvent(input$bookmark2, { session$doBookmark() })
}
```

---

## Updating the location bar instead of a modal

The default presentation is a modal dialog with the URL. To instead keep the browser address bar in sync on every input change:

```r
## server.R ##
function(input, output, session) {
  # Re-bookmark whenever any input changes
  observe({
    reactiveValuesToList(input)   # take a dependency on all inputs
    session$doBookmark()
  })

  # Write the generated URL into the address bar (no modal)
  onBookmarked(function(url) {
    updateQueryString(url)
  })
}
```

This makes the URL itself the "save" — the user just copies the address bar. Pairs naturally with `store = "url"`.

---

## Advanced — saving state that isn't an input

When meaningful state lives outside inputs (a `reactiveVal`, `reactiveValues`, or an R6 object), use the bookmark/restore callbacks. `onBookmark` writes into `state$values` (a plain environment); `onRestore` reads it back.

```r
## server.R ##
function(input, output, session) {

  # Non-input state: a running list of flagged patient IDs
  flagged <- reactiveVal(character(0))

  # --- Save: stash non-input state into the bookmark ---
  onBookmark(function(state) {
    state$values$flagged <- flagged()
  })

  # --- Restore: pull it back out before outputs render ---
  onRestore(function(state) {
    if (!is.null(state$values$flagged)) {
      flagged(state$values$flagged)
    }
  })
}
```

The four callbacks, in firing order:

| Callback | Fires | Use for |
|----------|-------|---------|
| `onBookmark(fun)` | Before state is saved | Write extra values into `state$values`; with `"server"`, save files into `state$dir` |
| `onBookmarked(fun)` | After the URL is generated | Show/customize the URL, or call `updateQueryString(url)` |
| `onRestore(fun)` | On restore, **before** inputs are set | Read `state$values`; restore non-input state |
| `onRestored(fun)` | On restore, **after** the session is fully flushed | Actions needing the restored inputs to already be in effect |

For `"server"` you can persist files alongside the state:

```r
onBookmark(function(state) {
  saveRDS(expensive_result(), file.path(state$dir, "result.rds"))
})
onRestore(function(state) {
  path <- file.path(state$dir, "result.rds")
  if (file.exists(path)) expensive_result(readRDS(path))
})
```

---

## Bookmarking with modules

Modules participate in bookmarking automatically — namespaced inputs are saved and restored like any other. Three module-specific points:

- **Module-local non-input state** uses `onBookmark`/`onRestore` *inside* `moduleServer`. The `state$values` you get is scoped to that module's namespace, so keys won't collide across module instances.
- **Exclude with bare names** inside the module — `setBookmarkExclude("scratch")`, not `setBookmarkExclude(ns("scratch"))`. Shiny applies the namespace for you.
- **Dynamically created inputs** (built in the server with `renderUI`/`insertUI`) need `restoreInput()` to recover their value, since they don't exist when the initial restore runs:

```r
## R/mod_dynamic.R ##
mod_dynamic_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    output$dyn <- renderUI({
      sliderInput(
        ns("threshold"), "Threshold",
        min = 0, max = 1,
        # Seed from the bookmark if present, else the default
        value = restoreInput(id = ns("threshold"), default = 0.5)
      )
    })
  })
}
```

---

## Reproducibility — randomness between inputs and outputs

If outputs depend on random numbers, the restored app won't match the bookmark. Make it deterministic:

```r
# Option A — fixed seed keyed on inputs
output$sim <- renderPlot({
  set.seed(input$seed)
  plot(rnorm(input$n))
})

# Option B — repeatable() captures the RNG state with the bookmark
draw <- repeatable(rnorm)
output$sim <- renderPlot({ plot(draw(input$n)) })
```

---

## Where server state is stored

| Run context | Directory |
|-------------|-----------|
| Shiny Server (OSS/Pro) | `/var/lib/shiny-server/bookmarks/...` |
| Posit Connect | `/var/lib/rstudio-connect/bookmarks/...` (default data dir) |
| Local `runApp("app_dir")` | `shiny_bookmarks/` inside the app directory |
| Local app with no directory | `shiny_bookmarks/` under the current working directory |

---

## Common Pitfalls

- **UI not a function** — the `ui.R` object must be `function(request) { ... }`. A bare `page_sidebar(...)` cannot be bookmarked.
- **Inputs built outside `function(request)`** — any `*Input()` stored in a top-level variable (e.g. in `global.R`) and reused inside the UI function will not restore. Build them inside the function.
- **Forgetting `enableBookmarking()`** — without it in `global.R`, `bookmarkButton()` renders but does nothing.
- **Manual bookmark button re-triggers on restore** — when using `session$doBookmark()`, always `setBookmarkExclude()` the button id, or the app re-bookmarks the instant it restores.
- **`store = "url"` and a long state** — many inputs can blow past the ~2000-char URL limit and silently break in some browsers. Switch to `"server"`.
- **`fileInput`/`passwordInput` not restoring** — by design. `passwordInput` is never saved; `fileInput` only with `"server"`.
- **Tab doesn't restore** — the `tabsetPanel`/`navset_*`/`navbarPage` needs an explicit `id`.
- **`reactiveValues`/R6 state lost on restore** — inputs restore automatically, but everything else needs `onBookmark`/`onRestore` with `state$values`.
- **Random output drifts after restore** — use `set.seed()` or `repeatable()`.
- **Dynamic inputs blank after restore** — inputs created by `renderUI`/`insertUI` must read `restoreInput(id = ns("x"), default = ...)` for their initial value.
- **`"server"` store fails on deploy** — confirm the host supports it (Shiny Server ≥1.4.7 / Connect ≥1.4.6) and that the bookmarks directory is writable.
