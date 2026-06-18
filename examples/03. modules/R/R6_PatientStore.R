# =============================================================================
# R/R6_PatientStore.R — R6 class for shared patient selection state
# =============================================================================
# Purpose: Demonstrates how to use R6 for cross-module reactive state in Shiny.
#
# Key teaching points:
#   - R6 class anatomy: initialize(), public fields, public methods
#   - A reactiveVal() stored INSIDE the R6 instance acts as the reactive bridge:
#     any observer/reactive that calls get_patient() will invalidate when
#     set_patient() is called — exactly like a plain reactiveVal(), but the
#     logic and value live inside the R6 object instead of floating in the
#     server function.
#   - The R6 instance is created ONCE in server.R and passed as an argument to
#     each module that needs it. This is the idiomatic pattern for shared state
#     that is more complex than a simple reactiveValues() object.
#   - R6 > reactiveValues when you need methods (encapsulated logic), not just
#     raw value storage. Use reactiveValues() for simple key-value state.
#
# Created: 2026-06-18
# =============================================================================

#' @title PatientStore
#'
#' @description
#' R6 class that manages the currently selected patient across Shiny modules.
#' Internally uses a \code{reactiveVal()} so that any reactive context
#' (observe, reactive, render*) that calls \code{get_patient()} will
#' automatically re-execute when \code{set_patient()} is called.
#'
#' @details
#' ## Why R6 instead of reactiveValues?
#' \code{reactiveValues()} is a named list of reactive values — great for
#' simple key-value state. R6 adds:
#' \itemize{
#'   \item Encapsulated methods (business logic lives with the data)
#'   \item Input validation inside \code{set_patient()}
#'   \item Easy extension (add \code{clear()}, \code{history()}, etc.)
#'   \item Testability — R6 methods can be unit-tested without a Shiny session
#' }
#'
#' ## Usage in server.R
#' \preformatted{
#'   store <- PatientStore$new(valid_ids = adsl$USUBJID)
#'   mod_r6_selector_server("sel", store = store, adsl = adsl)
#'   mod_r6_details_server("det", store = store, adsl = adsl, adlb = adlb)
#' }
#'
#' @export
PatientStore <- R6::R6Class(
  classname = "PatientStore",

  public = list(

    # --- Public fields -------------------------------------------------------
    # valid_ids is stored for input validation in set_patient().
    # It is a plain character vector, not reactive — it does not change at
    # runtime in this app.
    valid_ids = NULL,

    # --- initialize() --------------------------------------------------------
    #' @description
    #' Create a new PatientStore. Must be called inside a Shiny reactive
    #' context (i.e., inside server.R or a module server), because
    #' \code{reactiveVal()} requires a reactive domain to be active.
    #'
    #' @param valid_ids Character vector of valid USUBJID values. Used to
    #'   validate the argument passed to \code{set_patient()}.
    initialize = function(valid_ids = character(0)) {
      # --- Validate inputs --- [2026-06-18]
      # Ensure valid_ids is a character vector. This catches caller errors early.
      if (!is.character(valid_ids)) {
        stop("`valid_ids` must be a character vector.", call. = FALSE)
      }

      self$valid_ids <- valid_ids

      # --- Create the reactive bridge --- [2026-06-18]
      # reactiveVal() is the Shiny primitive that powers reactive invalidation.
      # We store it in a PRIVATE field so external code cannot replace it —
      # all access must go through get_patient() and set_patient().
      # NULL means "no patient selected yet."
      private$.selected_patient <- reactiveVal(NULL)
    },

    # --- set_patient() -------------------------------------------------------
    #' @description
    #' Set the currently selected patient. Calling this invalidates any reactive
    #' context that has called \code{get_patient()}.
    #'
    #' @param usubjid Character scalar. The USUBJID to select.
    #'   Pass \code{NULL} to clear the selection.
    #'
    #' @return Invisibly returns \code{self} for method chaining.
    set_patient = function(usubjid) {
      # --- Validate inputs --- [2026-06-18]
      # Allow NULL (deselect), but require a valid ID otherwise.
      if (!is.null(usubjid)) {
        if (!is.character(usubjid) || length(usubjid) != 1) {
          stop("`usubjid` must be a character scalar or NULL.", call. = FALSE)
        }
        if (length(self$valid_ids) > 0 && !(usubjid %in% self$valid_ids)) {
          warning(
            "USUBJID '", usubjid, "' not found in valid_ids — selection may be invalid.",
            call. = FALSE
          )
        }
      }

      # --- Update the reactive value --- [2026-06-18]
      # Calling private$.selected_patient(value) triggers invalidation of any
      # reactive context that previously called get_patient(). This is the same
      # mechanism as a plain reactiveVal() defined in server.R, but now the
      # logic is encapsulated inside the R6 class.
      private$.selected_patient(usubjid)

      invisible(self)
    },

    # --- get_patient() -------------------------------------------------------
    #' @description
    #' Return the currently selected USUBJID as a reactive expression.
    #' Call this inside a reactive context to subscribe to changes.
    #'
    #' @return The value of the internal \code{reactiveVal}: a character scalar
    #'   USUBJID, or \code{NULL} if no patient is selected.
    get_patient = function() {
      # --- Read the reactive value --- [2026-06-18]
      # Calling private$.selected_patient() with no argument READS the value
      # and registers the calling reactive context as a dependent. When
      # set_patient() writes a new value, all dependents are invalidated and
      # will re-execute. This is the core of Shiny reactivity.
      private$.selected_patient()
    }
  ),

  private = list(
    # --- Private reactive storage --- [2026-06-18]
    # Prefixed with "." to signal it is internal. External code cannot access
    # this field directly — only get_patient() and set_patient() can.
    .selected_patient = NULL
  )
)
