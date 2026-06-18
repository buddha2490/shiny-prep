# =============================================================================
# ui.R — Shiny Modules Reference App
# =============================================================================
# Defines the top-level bslib page_navbar UI. Each nav_panel corresponds to
# one module pattern tab. Module UI calls go here; all IDs must match the
# server calls in server.R.
#
# Layout: page_navbar with 6 tabs, one per pattern. A sidebar-style layout is
# used inside tabs that have filter + content panels.
#
# Created: 2026-06-18
# =============================================================================

ui <- page_navbar(
  title = APP_TITLE,
  theme = bs_theme(bootswatch = "flatly"),
  fillable = FALSE,

  # ---------------------------------------------------------------------------
  # Tab 1: Basic Module
  # Teaching: minimal NS + moduleServer pattern
  # ---------------------------------------------------------------------------
  nav_panel(
    title = "1. Basic Module",

    layout_columns(
      col_widths = 12,
      card(
        card_header(
          class = "bg-primary text-white",
          "Pattern: Basic Module (NS + moduleServer)"
        ),
        card_body(
          tags$p(
            tags$strong("What this tab shows: "),
            "The minimal Shiny module structure. One module, one namespace, ",
            "one filter input, one table output. See ",
            tags$code("R/mod_demographics.R"), "."
          ),
          tags$ul(
            tags$li(tags$code("NS(id)"), " — wraps all input/output IDs to prevent namespace collision"),
            tags$li(tags$code("moduleServer(id, ...)"), " — server counterpart; input/output are pre-namespaced"),
            tags$li("Data is passed as a plain argument; modules never reach into global scope")
          )
        )
      ),
      # Module UI call — id "demo" must match mod_demographics_server("demo") in server.R
      mod_demographics_ui("demo")
    )
  ),

  # ---------------------------------------------------------------------------
  # Tab 2: Module Communication (returned reactive)
  # Teaching: producer module returns a reactive; consumer module accepts it
  # ---------------------------------------------------------------------------
  nav_panel(
    title = "2. Module Communication",

    layout_columns(
      col_widths = 12,
      card(
        card_header(
          class = "bg-primary text-white",
          "Pattern: Module Communication via Returned Reactive"
        ),
        card_body(
          tags$p(
            tags$strong("What this tab shows: "),
            "A filter module RETURNS a reactive; a listing module CONSUMES it. ",
            "See ", tags$code("R/mod_filter.R"), " and ",
            tags$code("R/mod_listing.R"), "."
          ),
          tags$ul(
            tags$li("Producer: ", tags$code("mod_filter_server()"), " returns a reactive expression"),
            tags$li("Consumer: ", tags$code("mod_listing_server()"), " receives the reactive as an argument"),
            tags$li(
              "The parentheses convention: ",
              tags$code("data()"), " reads the value; ",
              tags$code("data"), " is the reactive object itself"
            )
          )
        )
      )
    ),
    layout_columns(
      col_widths = c(3, 9),
      mod_filter_ui("filter"),
      mod_listing_ui("listing")
    )
  ),

  # ---------------------------------------------------------------------------
  # Tab 3: Shared State with reactiveValues
  # Teaching: parent creates rv; multiple modules read/write it
  # ---------------------------------------------------------------------------
  nav_panel(
    title = "3. reactiveValues State",

    layout_columns(
      col_widths = 12,
      card(
        card_header(
          class = "bg-primary text-white",
          "Pattern: Shared State with reactiveValues"
        ),
        card_body(
          tags$p(
            tags$strong("What this tab shows: "),
            "Three modules sharing one ", tags$code("reactiveValues"), " object. ",
            "See ", tags$code("R/mod_ae_filters.R"), ", ",
            tags$code("R/mod_ae_table.R"), ", ",
            tags$code("R/mod_ae_summary.R"), "."
          ),
          tags$ul(
            tags$li(
              tags$code("rv"), " is created ONCE in ", tags$code("server.R"),
              " and passed to all three modules"
            ),
            tags$li("Writer module: ", tags$code("mod_ae_filters"), " — sets rv fields via observe()"),
            tags$li(
              "Reader modules: ", tags$code("mod_ae_table"), " and ",
              tags$code("mod_ae_summary"), " — read rv fields, re-execute automatically on change"
            ),
            tags$li("Multiple readers observe the same fields with no explicit wiring between them")
          )
        )
      )
    ),
    # Summary cards span full width above the filter + table layout
    mod_ae_summary_ui("ae_summary"),
    layout_columns(
      col_widths = c(3, 9),
      mod_ae_filters_ui("ae_filters", usubjid_choices = adsl$USUBJID),
      mod_ae_table_ui("ae_table")
    )
  ),

  # ---------------------------------------------------------------------------
  # Tab 4: Shared State with R6
  # Teaching: R6 class with reactiveVal bridge, methods for encapsulated state
  # ---------------------------------------------------------------------------
  nav_panel(
    title = "4. R6 State",

    layout_columns(
      col_widths = 12,
      card(
        card_header(
          class = "bg-primary text-white",
          "Pattern: Shared State with R6 + reactiveVal Bridge"
        ),
        card_body(
          tags$p(
            tags$strong("What this tab shows: "),
            "An R6 class (", tags$code("PatientStore"), ") manages selected ",
            "patient state. A reactiveVal inside the R6 instance provides ",
            "reactive invalidation. See ",
            tags$code("R/R6_PatientStore.R"), ", ",
            tags$code("R/mod_r6_selector.R"), ", ",
            tags$code("R/mod_r6_details.R"), "."
          ),
          tags$ul(
            tags$li(
              tags$code("PatientStore$new()"), " is called in server.R; the instance is passed to both modules"
            ),
            tags$li(
              "Writer: ", tags$code("store$set_patient()"), " — updates the internal reactiveVal"
            ),
            tags$li(
              "Reader: ", tags$code("store$get_patient()"), " — reads the reactiveVal, ",
              "creating a reactive dependency"
            ),
            tags$li(
              "R6 > reactiveValues when you need encapsulated methods, ",
              "input validation, or testable business logic"
            )
          )
        )
      )
    ),
    layout_columns(
      col_widths = c(3, 9),
      mod_r6_selector_ui("r6_selector", usubjid_choices = adsl$USUBJID),
      mod_r6_details_ui("r6_details")
    )
  ),

  # ---------------------------------------------------------------------------
  # Tab 5: Nested Modules
  # Teaching: outer module wraps inner modules; NS nesting; data flows down
  # ---------------------------------------------------------------------------
  nav_panel(
    title = "5. Nested Modules",

    layout_columns(
      col_widths = 12,
      card(
        card_header(
          class = "bg-primary text-white",
          "Pattern: Nested Modules (Outer coordinates Inner modules)"
        ),
        card_body(
          tags$p(
            tags$strong("What this tab shows: "),
            "An outer module (", tags$code("mod_patient_profile"), ") contains ",
            "three inner modules. The outer module handles patient selection ",
            "and passes pre-filtered reactives down to inners. ",
            "See ", tags$code("R/mod_patient_profile.R"), " and the three ",
            tags$code("R/mod_profile_*.R"), " files."
          ),
          tags$ul(
            tags$li(
              "Outer UI: inner module UIs are called with ",
              tags$code("ns(\"inner_id\")"), " — this nests their namespace"
            ),
            tags$li(
              "Outer server: inner servers are called with ",
              tags$code("session$ns(\"inner_id\")"), " to match the nested UI namespace"
            ),
            tags$li("Data flows DOWN: outer filters datasets, inners only handle display"),
            tags$li("Inner modules are standard modules — no special 'inner' API")
          )
        )
      )
    ),
    # The outer module UI is a single call — it renders all inner UIs internally
    mod_patient_profile_ui("patient_profile", usubjid_choices = adsl$USUBJID)
  ),

  # ---------------------------------------------------------------------------
  # Tab 6: Dynamic Modules
  # Teaching: insertUI/removeUI, unique IDs, instance lifecycle management
  # ---------------------------------------------------------------------------
  nav_panel(
    title = "6. Dynamic Modules",

    layout_columns(
      col_widths = 12,
      card(
        card_header(
          class = "bg-primary text-white",
          "Pattern: Dynamic Module Instances (insertUI / removeUI)"
        ),
        card_body(
          tags$p(
            tags$strong("What this tab shows: "),
            "A host module creates and destroys card module instances at runtime. ",
            "Each card is independent with its own ARM filter. ",
            "See ", tags$code("R/mod_dynamic_host.R"), " and ",
            tags$code("R/mod_dynamic_card.R"), "."
          ),
          tags$ul(
            tags$li(
              "Counter pattern: each instance gets a unique ID from an ",
              "incrementing ", tags$code("reactiveVal"), " — never reuse IDs"
            ),
            tags$li(
              tags$code("insertUI()"), " adds UI; module server is called immediately after"
            ),
            tags$li(
              tags$code("removeUI()"), " removes UI; host observes the card's remove reactive"
            ),
            tags$li(
              tags$code("local()"), " captures loop variable by value to avoid R closure bug"
            )
          )
        )
      )
    ),
    mod_dynamic_host_ui("dynamic_host")
  )
)
