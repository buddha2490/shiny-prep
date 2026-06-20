# Example 05 — shinychat + ellmer Streaming Chat

A reference Shiny app exercising the full **shinychat** + **ellmer** API surface,
backed by the Anthropic Claude API. Built to be copied from, not deployed.

Five tabs: Basic Chat (token-by-token streaming), Module Pattern
(`chat_mod_server()` + its returned reactives), Markdown Stream
(`output_markdown_stream()`), Advanced ellmer (tool calling, structured output,
turn inspector), and Control Panel (model/params, token usage, export, reset).

## Running it — read this first

This app **must run against the project's renv library**. Running it from a
long-lived R/RStudio session that already loaded packages (an old `DT`, etc.)
before renv activated is the #1 cause of cryptic startup crashes — you'll see
errors naming symbols that don't exist in the locked versions (e.g.
`object 'datatables_html' not found`). The app now detects this and shows a
warning telling you to restore, but the clean path is:

```r
# From the repo root, in a FRESH R session:
renv::restore()                          # ensure the library matches renv.lock
Sys.setenv(ANTHROPIC_API_KEY = "sk-...") # or have it in .Renviron
shiny::runApp("examples/05. shinychat")
```

Or from the shell (guarantees the renv library is on the path):

```bash
cd /path/to/shiny-prep
NOT_CRAN=true Rscript -e 'source("renv/activate.R"); shiny::runApp("examples/05. shinychat", launch.browser = TRUE)'
```

### Requirements

- `ANTHROPIC_API_KEY` set (environment or `.Renviron`). The app builds an ellmer
  client at startup; without the key it shows a clean "client unavailable" notice.
- Packages from `renv.lock`: `shinychat`, `ellmer`, `coro`, `bsicons`, `DT`,
  `bslib` (+ the usual `shiny`, `log4r`, `promises`, `scales`, `R6`).

## Tests

```bash
# From the repo root, with renv active and the API key set:
cd /path/to/shiny-prep
NOT_CRAN=true Rscript -e '
  source("renv/activate.R"); setwd("examples/05. shinychat")
  library(shinytest2); library(testthat); source("global.R")
  testthat::test_dir("tests/testthat")
'
```

The suite includes `test-all-tabs-smoke.R` — a startup smoke test that opens
**every** tab and asserts the app logged no `FATAL`/`ERROR` and the browser
console is clean. The live-API tests skip automatically when
`ANTHROPIC_API_KEY` is unset.

## Logging

log4r writes to `logs/shinychat-app.log` (gitignored). Threshold via `LOG_LEVEL`
(default `INFO`). Never logs PHI — this app has none, but it follows the rule.
