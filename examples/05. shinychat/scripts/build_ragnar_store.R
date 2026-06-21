# =============================================================================
# build_ragnar_store.R — build the ragnar DuckDB knowledge store for Tab 6
# Created: 2026-06-20
#
# WHAT THIS DOES
#   Reads a curated subset of the repo's markdown docs (rag/sources/*.md),
#   chunks them, and writes a self-contained ragnar DuckDB store to
#   data/shiny_kb.duckdb — the store the "RAG Chat" tab (mod_rag_chat.R)
#   connects to at runtime.
#
# RETRIEVAL_MODE — the dependency trade-off this script exists to demonstrate
#   "fts" (DEFAULT) — BM25 / full-text keyword retrieval, NO embeddings.
#       ZERO system dependencies: pure R packages (ragnar + duckdb + dbplyr),
#       all restored by renv::restore(). No embedding model, no Ollama, no
#       Python, no API key, no network. DuckDB is embedded (in-process, like
#       SQLite) — there is no database server to install. This is the
#       lightweight reference: clone -> renv::restore() -> build -> run, with
#       nothing for IT to provision. Retrieval is lexical (keyword) — strong
#       for technical docs (function/argument names) and for LLM-tool-driven
#       search where the model picks good keywords.
#   "vss" — semantic vector search. Higher quality on paraphrased/conceptual
#       queries, but needs an embedding provider at BUILD time AND at RUNTIME
#       (ragnar embeds the query per lookup). Here that provider is local
#       Ollama (nomic-embed-text); in a real deployment, point one of ragnar's
#       embed_*() functions at a managed endpoint your environment already runs
#       (embed_azure_openai / embed_bedrock / embed_databricks / embed_openai
#       with base_url=...) so there is still no local daemon to install.
#   Select with the env var RAG_RETRIEVAL_MODE, e.g.
#       RAG_RETRIEVAL_MODE=vss Rscript ... build_ragnar_store.R
#
# WHEN TO RUN IT
#   Once, before launching the app for the first time, and again any time the
#   curated source files change. It is NOT sourced by global.R — it is a
#   one-shot build step, deliberately kept out of the app's startup path.
#
# PREREQUISITES
#   - "fts" mode: renv restored (ragnar, duckdb, dbplyr). Nothing else.
#   - "vss" mode: the above, PLUS Ollama running (ollama serve) with the model
#     pulled (ollama pull nomic-embed-text).
#
# HOW TO RUN  (from the repo root, with renv active)
#   NOT_CRAN=true Rscript -e 'source("renv/activate.R")' \
#     -e 'source("examples/05. shinychat/scripts/build_ragnar_store.R")'
#   — or simply run this file from within the app directory.
#
# NOTE ON read_as_markdown()
#   We deliberately do NOT use ragnar::read_as_markdown(): on a .md file it
#   routes through a Python (reticulate/markitdown) toolchain and downloads a
#   large environment. Our sources are already markdown, so we build a
#   MarkdownDocument straight from the file text — no Python needed at build or
#   run time, in either mode.
# =============================================================================

suppressPackageStartupMessages({
  library(ragnar)
  library(duckdb)
  library(dbplyr)   # required by ragnar_retrieve()'s SQL backend
})

# --- Locate the repo root and app dir regardless of how this is run ----------
# Works whether sourced interactively or run via `Rscript --file=`.
get_script_dir <- function() {
  args <- commandArgs(trailingOnly = FALSE)
  file_arg <- grep("^--file=", args, value = TRUE)
  if (length(file_arg)) {
    return(dirname(normalizePath(sub("^--file=", "", file_arg))))
  }
  of <- tryCatch(sys.frames()[[1]]$ofile, error = function(e) NULL)
  if (!is.null(of)) return(dirname(normalizePath(of)))
  getwd()
}

script_dir <- get_script_dir()                                 # .../scripts
app_dir    <- normalizePath(file.path(script_dir, ".."))       # .../05. shinychat
repo_root  <- normalizePath(file.path(app_dir, "..", ".."))    # repo root
sources_dir <- file.path(repo_root, "rag", "sources")

# --- Configuration -----------------------------------------------------------
# Curated subset: the docs most relevant to "how do I build a Shiny chat app
# with shinychat + ellmer, grounded with ragnar?". Kept small so the store
# builds fast and stays committable.
SOURCE_FILES <- c(
  "shinychat.md",
  "ellmer.md",
  "ragnar.md",
  "bslib.md",
  "shiny.md"
)

# Retrieval mode: "fts" (zero-dependency BM25, default) or "vss" (semantic,
# needs an embedding provider). See the header for the full trade-off.
RETRIEVAL_MODE <- Sys.getenv("RAG_RETRIEVAL_MODE", "fts")

EMBED_MODEL <- "nomic-embed-text"   # used only in "vss" mode
STORE_PATH  <- file.path(app_dir, "data", "shiny_kb.duckdb")
STORE_NAME  <- "shiny_kb"
STORE_TITLE <- "R Shiny + shinychat + ellmer knowledge base"

# --- Validate inputs ---------------------------------------------------------
if (!RETRIEVAL_MODE %in% c("fts", "vss")) {
  stop("`RAG_RETRIEVAL_MODE` must be \"fts\" or \"vss\", not \"",
       RETRIEVAL_MODE, "\".", call. = FALSE)
}
if (!dir.exists(sources_dir)) {
  stop("Source directory not found: ", sources_dir, call. = FALSE)
}
src_paths <- file.path(sources_dir, SOURCE_FILES)
missing   <- SOURCE_FILES[!file.exists(src_paths)]
if (length(missing) > 0) {
  stop("Missing source file(s) in ", sources_dir, ": ",
       paste(missing, collapse = ", "), call. = FALSE)
}

# --- Fresh build: remove any prior store so re-runs are reproducible ----------
if (file.exists(STORE_PATH)) {
  message("Removing existing store: ", STORE_PATH)
  file.remove(STORE_PATH)
}

# --- Create the store --------------------------------------------------------
# In "fts" mode embed = NULL: no embedding function is stored, so no model is
# ever called — at build OR at runtime. In "vss" mode we attach an Ollama embed
# function (swap for a managed embed_*() endpoint in production).
message("Retrieval mode:     ", RETRIEVAL_MODE,
        if (RETRIEVAL_MODE == "fts") "  (BM25 keyword — zero system dependencies)"
        else "  (semantic vector search)")
message("Creating store at:  ", STORE_PATH)

embed_fn <- if (RETRIEVAL_MODE == "vss") {
  message("Embedding model:    ", EMBED_MODEL, " (via Ollama)")
  \(x) ragnar::embed_ollama(x, model = EMBED_MODEL)
} else {
  NULL
}

store <- ragnar_store_create(
  location = STORE_PATH,
  embed    = embed_fn,
  name     = STORE_NAME,
  title    = STORE_TITLE,
  version  = 2
)

# --- Chunk + insert each source ----------------------------------------------
# Build a MarkdownDocument from the raw file text (origin = basename so the
# citations panel can show which doc a chunk came from), chunk it, insert.
total_chunks <- 0L
for (i in seq_along(SOURCE_FILES)) {
  fname <- SOURCE_FILES[i]
  text  <- paste(readLines(src_paths[i], warn = FALSE), collapse = "\n")

  doc    <- ragnar::MarkdownDocument(text, origin = fname)
  chunks <- ragnar::markdown_chunk(doc)

  ragnar_store_insert(store, chunks)
  total_chunks <- total_chunks + nrow(chunks)
  message(sprintf("  ingested %-14s %3d chunks", fname, nrow(chunks)))
}

# --- Build the retrieval index -----------------------------------------------
# "fts" builds only the BM25 full-text index (no embeddings exist to index).
# "vss" builds both so ragnar_retrieve() can do hybrid vector + keyword search.
index_type <- if (RETRIEVAL_MODE == "vss") c("vss", "fts") else "fts"
message("Building index (", paste(index_type, collapse = " + "), ") ...")
ragnar_store_build_index(store, type = index_type)

# --- Sanity check: a retrieval round-trip ------------------------------------
probe <- ragnar_retrieve(
  store,
  "How do I register a retrieval tool with an ellmer chat?",
  top_k = 3L
)
message(sprintf("Index OK — probe query returned %d chunk(s).", nrow(probe)))

# --- Report + tidy up --------------------------------------------------------
DBI::dbDisconnect(store@con, shutdown = TRUE)

size_mb <- round(file.info(STORE_PATH)$size / 1024^2, 2)
message(sprintf(
  "\nDone. %d chunks from %d files -> %s (%.2f MB)",
  total_chunks, length(SOURCE_FILES), STORE_PATH, size_mb
))
