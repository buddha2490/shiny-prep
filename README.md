# shiny-prep

A preparation and reference environment for building R Shiny applications in a pharma/clinical context, powered by [Claude Code](https://docs.anthropic.com/en/docs/claude-code). Contains specialized AI agents, coding rules, auto-invoked skills, a RAG knowledge base, and worked reference examples covering the most common Shiny patterns.

## What's in this repo

### Reference Examples

Ten worked examples, each a runnable Shiny app demonstrating a specific pattern:

| # | Example | What it covers |
|---|---------|----------------|
| 01 | **async** | 7 async patterns — promises, future + promise, future + callr, plain callr, ExtendedTask, crew, mirai |
| 02 | **plotly** | Interactive plotting — scattergl for large data, plotlyProxy partial updates, ggplotly conversion, crosstalk linked views |
| 03 | **modules** | Shiny modules — NS/moduleServer, returned reactives, R6 bridge for shared state, nested modules, dynamic UI |
| 04 | **error-handling** | Logging and error handling — log4r setup, `with_error_handling()` wrapper, error catalog with incident IDs, validation patterns |
| 05 | **shinychat** | LLM chat integration — shinychat + ellmer streaming, RAG chat, module patterns, control panel with export |
| 06 | **tables** | Table packages — DT, gt, reactable, rhandsontable side-by-side with tests |
| 07 | **layouts** | Layout frameworks — bslib, shinydashboard, and bs4Dash implementations of the same dashboard |
| 08 | **css-styling** | Custom CSS patterns — external stylesheets, Bootstrap utilities, CSS custom properties, namespace-aware selectors |
| 09 | **animation** | Animated/streaming UI patterns |

All multi-file apps use the three-file layout (`global.R`, `ui.R`, `server.R`).

### Claude Code Tooling

```
.claude/
  agents/         # 6 specialized agents (see Agent Workflow below)
  agent-memory/   # persistent memory per agent
  rules/          # 12 project-wide rules, always loaded into context
  skills/         # 23 auto-invoked skill files for specific tasks
```

**Rules** encode project conventions — R style, app structure, testing, error handling, logging, CDISC data, renv, CSS, git, namespace conflicts, pharmaRTF patterns, and error messages.

**Skills** are auto-invoked patterns for specific tasks: bslib layout, reactive programming, modules, async, caching, profiling, performance review, testing, error handling, downloads/uploads, bookmarking, R6 in Shiny, table packages (DT, gt, reactable, rhandsontable), plotly, app frameworks (raw Shiny, golem, rhino, leprechaun), shinydashboard/bs4Dash, CDISC data validation, mirai, R packages, and general R code.

### RAG Knowledge Base

A local vector + FTS5 search index over version-pinned documentation for the packages this project targets. Exposed as an MCP server.

```
rag/
  mcp_server.py        # MCP server (hybrid vector + keyword search)
  ingest.py            # document ingestion pipeline
  pdf_to_markdown.py   # CRAN-manual PDF -> markdown parser
  ig_to_markdown.py    # CDISC IG PDF -> markdown parser
  sources/             # ingested markdown source files
  rag.db               # SQLite store (embeddings + FTS5 index)
```

Covers: bslib, plotly, DT, gt, shinytest2, mirai, log4r, renv, R6, shinydashboard, bs4Dash, CDISC SDTM/ADaM Implementation Guides, and more.

## Agent Workflow

Six specialized agents form a feature-development pipeline:

1. **shiny-feature-planner** — requirements intake, clarifying questions, implementation plan
2. **shiny-ux-arbiter** — UI/UX design decisions (layout, components, CSS, interactions)
3. **shiny-r-architect** — R/Shiny code implementation, architecture, R6 design
4. **r-test-developer** — unit tests, `testServer()`, `AppDriver` E2E tests
5. **r-code-reviewer** — final quality gate (style, performance, codebase impact)
6. **shiny-debugger** *(on-demand)* — diagnoses broken behavior at any point

Not every task needs all five pipeline steps. Small fixes can go straight to the architect or debugger. New features should start with the planner.

## Conventions

- **App structure:** Three-file layout (`global.R`, `ui.R`, `server.R`) — never `app.R`
- **Pharma context:** CDISC data (SDTM/ADaM), patient listings, safety dashboards
- **Layout:** bslib (`page_sidebar`, `page_navbar`, cards) for new apps
- **Tables:** DT for interactive, gt for publication-quality
- **Pipe:** `%>%` (tidyverse) by default
- **Testing:** Every non-trivial function gets a test; factory functions for test data
- **Packages:** Managed with renv; `renv::snapshot()` after every change; lockfile committed with the code
- **Logging:** log4r with structured `key=value` fields; never log PHI/PII
- **Errors:** Catalog codes (`ERR-<DOMAIN>-<NNN>`) + incident IDs; users never see internals

## Getting Started

```bash
# Clone the repo
git clone https://github.com/buddha2490/shiny-prep.git
cd shiny-prep

# Restore the R package environment
Rscript -e 'renv::restore()'

# Run any example app
Rscript -e 'source("renv/activate.R"); shiny::runApp("examples/06. tables")'
```

### RAG Server Setup

```bash
cd rag
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

### MCP Configuration

The RAG server is registered as an MCP server in two places:

- **`.mcp.json`** — used by Claude Code (CLI)
- **`.vscode/.mcp.json`** — used by VS Code with the Claude extension

Both files contain **absolute paths** that must be updated to match your local checkout. After cloning, edit each file and replace the paths to point to your repo location:

```jsonc
// .mcp.json and .vscode/.mcp.json — update these three paths:
{
  "mcpServers": {
    "shiny-rag": {
      "command": "<your-repo-path>/rag/.venv/bin/python3",
      "args": ["<your-repo-path>/rag/mcp_server.py"],
      "env": {
        "DB_PATH": "<your-repo-path>/rag/rag.db"
      }
    }
  }
}
```

