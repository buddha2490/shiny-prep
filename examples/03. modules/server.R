# =============================================================================
# server.R — Shiny Modules Reference App
# =============================================================================
# Wires all module servers to their UI counterparts. No library() calls here
# (all packages loaded in global.R). No data loading here (all datasets
# created in global.R).
#
# Read the comments in each module file for detailed teaching notes on each
# pattern. This file intentionally stays thin — it is the "wiring harness,"
# not the logic.
#
# Created: 2026-06-18
# =============================================================================

server <- function(input, output, session) {

  # ---------------------------------------------------------------------------
  # Tab 1: Basic Module
  # ---------------------------------------------------------------------------
  # Simplest possible wiring: pass the id string and the dataset.
  # The "demo" id must match mod_demographics_ui("demo") in ui.R.
  mod_demographics_server("demo", adsl = adsl)

  # ---------------------------------------------------------------------------
  # Tab 2: Module Communication via returned reactive
  # ---------------------------------------------------------------------------
  # Key pattern: mod_filter_server RETURNS a reactive.
  # We assign it and pass it to mod_listing_server as an argument.
  # filtered_subjects is a reactive object (a function) — NOT a data frame.
  # mod_listing_server receives it and calls filtered_subjects() internally.
  filtered_subjects <- mod_filter_server("filter", adsl = adsl)
  mod_listing_server("listing", data = filtered_subjects)

  # ---------------------------------------------------------------------------
  # Tab 3: Shared State with reactiveValues
  # ---------------------------------------------------------------------------
  # rv is created HERE in the parent server, not inside any module.
  # This is the pattern: parent owns the shared state; children receive it.
  # We set initial values so reader modules have a defined state at startup.
  rv <- reactiveValues(
    severity_filter   = "All",
    serious_only      = FALSE,
    selected_subjects = "ALL"
  )

  # All three modules receive the same rv object. The writer (ae_filters)
  # will update rv fields; the readers (ae_table, ae_summary) will react.
  mod_ae_filters_server("ae_filters", rv = rv)
  mod_ae_table_server("ae_table",     rv = rv, adae = adae)
  mod_ae_summary_server("ae_summary", rv = rv, adae = adae)

  # ---------------------------------------------------------------------------
  # Tab 4: Shared State with R6
  # ---------------------------------------------------------------------------
  # PatientStore is instantiated HERE, with valid USUBJID values for validation.
  # Must be inside server() because initialize() calls reactiveVal(), which
  # requires an active Shiny reactive domain.
  store <- PatientStore$new(valid_ids = adsl$USUBJID)

  # Both modules receive the SAME store instance.
  # Selector writes to it; details reads from it.
  mod_r6_selector_server("r6_selector", store = store, adsl = adsl)
  mod_r6_details_server("r6_details",   store = store, adsl = adsl, adlb = adlb)

  # ---------------------------------------------------------------------------
  # Tab 5: Nested Modules
  # ---------------------------------------------------------------------------
  # Single call to the outer module server. All inner module servers are
  # called INSIDE mod_patient_profile_server() — see that file for details
  # on how session$ns() is used to create nested namespaces.
  mod_patient_profile_server(
    "patient_profile",
    adsl = adsl,
    adlb = adlb,
    adae = adae
  )

  # ---------------------------------------------------------------------------
  # Tab 6: Dynamic Modules
  # ---------------------------------------------------------------------------
  # Single call to the host module. Dynamic card instances are created and
  # destroyed entirely inside mod_dynamic_host_server() — see that file for
  # the insertUI / removeUI pattern and the counter/closure details.
  mod_dynamic_host_server("dynamic_host", adae = adae)
}
