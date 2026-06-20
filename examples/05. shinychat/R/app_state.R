# =============================================================================
# app_state.R — R6 class for shared application state
# Created: 2026-06-19
# Purpose: Holds the shared ellmer Chat client as a reactiveVal so all modules
#   can observe and update it. The Control Panel module writes to app_state$client
#   when settings change; the Basic Chat and Module Pattern tabs read from it to
#   get the current client.
#
# Design rationale: R6 over reactiveValues — the client swap pattern benefits
#   from the encapsulation and the make_client() factory method being co-located
#   with the state it produces.
# =============================================================================

#' @title AppState
#' @description
#' R6 class managing the shared shinychat application state — specifically the
#' current ellmer Chat client (a `reactiveVal`), the current system prompt, and
#' factory helpers for re-creating the client with updated settings.
#'
#' Instantiated once in `server.R` and passed to each module server as an
#' argument. Modules read `app_state$client()` to get the current Chat object
#' and write to it via `app_state$client(new_client)`.
#'
#' @export
AppState <- R6::R6Class(
  "AppState",
  public = list(

    # --- Public fields -------------------------------------------------------

    #' @field client A `shiny::reactiveVal` wrapping the current `ellmer::Chat`.
    #' Read: `app_state$client()`. Write: `app_state$client(new_chat)`.
    client = NULL,

    # --- Initialize ----------------------------------------------------------

    #' @description
    #' Initialise the app state. Must be called inside a Shiny reactive context
    #' (i.e. inside `server.R`), since `reactiveVal()` requires a session.
    #'
    #' @param model Character. ellmer model id. Default `"claude-sonnet-4-6"`.
    #' @param system_prompt Character. Default system prompt for the shared client.
    initialize = function(
      model         = "claude-sonnet-4-6",
      system_prompt = "You are a helpful AI assistant built with shinychat and ellmer in R Shiny."
    ) {
      # --- Create the initial ellmer client --- [2026-06-19]
      initial_client <- ellmer::chat_anthropic(
        model         = model,
        system_prompt = system_prompt
      )

      # Wrap in a reactiveVal so modules can observe changes
      self$client <- shiny::reactiveVal(initial_client)

      log_event("INFO", "AppState initialised", model = model)
    },

    #' @description
    #' Factory helper: create a new ellmer Chat client with the given settings.
    #' Does NOT update `self$client` — caller is responsible for assigning the
    #' result via `self$client(new_client)`.
    #'
    #' @param model         Character. Model id.
    #' @param system_prompt Character. System prompt text.
    #' @param params_obj    Optional `ellmer::params()` object.
    #' @return A new `ellmer::Chat` object.
    make_client = function(
      model         = "claude-sonnet-4-6",
      system_prompt = "You are a helpful AI assistant built with shinychat and ellmer in R Shiny.",
      params_obj    = NULL
    ) {
      # --- Validate inputs --- [2026-06-19]
      if (!is.character(model) || length(model) != 1L) {
        stop("`model` must be a single character string.", call. = FALSE)
      }
      if (!is.character(system_prompt) || length(system_prompt) != 1L) {
        stop("`system_prompt` must be a single character string.", call. = FALSE)
      }

      ellmer::chat_anthropic(
        model         = model,
        system_prompt = system_prompt,
        params        = params_obj
      )
    }
  )
)
