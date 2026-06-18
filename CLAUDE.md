# shiny-prep

Preparation environment for R Shiny development in a pharma/clinical context. Contains Claude Code tooling (agents, rules, skills), a RAG knowledge base, and reference examples.

## Knowledge Base & Skills (use these first)

Two curated assets back all work in this repo. Reach for them before relying on training memory — they are the project's highest-value resources, and every agent is wired to consult them.

- **RAG knowledge base** — search it with the `mcp__shiny-rag__rag_search` MCP tool; list what's ingested with `mcp__shiny-rag__rag_list_sources`. It holds authoritative, version-pinned docs for the packages this project uses (bslib, plotly, DT/gt, shinytest2, mirai, log4r, renv, R6, shinydashboard/bs4Dash, the CDISC SDTM/ADaM IGs, and more). Trust the RAG over memory when they disagree — it reflects the exact package versions targeted here. The server is `rag/mcp_server.py`, registered in `.mcp.json`.
- **`.claude/skills/`** — 23 auto-invoked skill files, each encoding the house-standard pattern for a specific task (layout, tables, modules, reactivity, async, testing, error-handling, CDISC validation, app frameworks). The relevant skill overrides any generic approach. Read it before writing the code it governs.

## Agent Workflow

For new features, follow this pipeline in order:

1. **shiny-feature-planner** -- requirements intake, clarifying questions, parallelizable implementation plan
2. **shiny-ux-arbiter** -- UI/UX design decisions (layout, components, CSS, interaction patterns)
3. **shiny-r-architect** -- R/Shiny code implementation, architecture decisions, R6 design
4. **r-test-developer** -- unit tests, testServer(), AppDriver tests, roxygen updates
5. **r-code-reviewer** -- final quality gate (style, performance, codebase impact)

Plus a sixth, on-demand agent:

- **shiny-debugger** -- diagnoses broken behavior: cryptic R errors, blank/non-updating outputs, reactive-graph problems (loops, over-firing), namespace/ID mismatches, and deployment failures. Invoke it whenever something is broken, at any point in the workflow.

Not every task needs all 5 pipeline steps. Small bug fixes can go straight to the architect (or the debugger if something is broken). But for new features, start with the planner. Each agent keeps persistent notes in `.claude/agent-memory/<agent-name>/`.

## Key Directories

```
.claude/
  agents/         # 6 specialized agents (5-step pipeline + shiny-debugger; see workflow)
  agent-memory/   # per-agent persistent memory (one dir per agent)
  rules/          # project-wide rules, always loaded into context
  skills/         # 23 auto-invoked skill files for specific tasks
examples/
  01. async/          # 7 async patterns (promises, future, ExtendedTask, mirai, ...)
  02. plotly/         # plotly reference app (scattergl, plotlyProxy, ggplotly, crosstalk)
  03. modules/        # Shiny module patterns (NS, returned reactives, R6 bridge, nesting)
  04. error-handling/ # logging + error-handling reference app (log4r, with_error_handling)
rag/
  mcp_server.py        # RAG MCP server (hybrid vector + FTS5 keyword search)
  ingest.py            # document ingestion pipeline
  pdf_to_markdown.py   # CRAN-manual PDF -> markdown parser
  ig_to_markdown.py    # CDISC IG PDF -> markdown parser
  sources/             # markdown files ingested into the knowledge base
  rag.db               # SQLite store (embeddings + FTS5 index)
docs/
  shiny-dev-claude-v2.md         # current readiness review + prioritized backlog
  shiny-dev-claude.md            # v1 setup evaluation
  shiny-developer-inventory.qmd  # comprehensive skills/tools checklist
```

## Conventions

- **App structure:** Three-file layout (`global.R`, `ui.R`, `server.R`). Never `app.R`.
- **Pharma context:** CDISC data (SDTM/ADaM), patient listings, safety dashboards, clinical review tools.
- **Layout default:** Prefer bslib (`page_sidebar`, `page_navbar`, cards) for new apps.
- **Table default:** DT for interactive tables, gt for static/publication-quality tables. Ask if unclear.
- **Pipe:** Use `%>%` (tidyverse) unless specifically asked for `|>` (base).
- **Testing:** Every non-trivial function gets a test. Factory functions for test data.
- **Packages:** `renv::snapshot()` after every install/remove/update. Lockfile committed with the code.
