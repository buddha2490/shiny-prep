# shiny-prep

Preparation environment for R Shiny development in a pharma/clinical context. Contains Claude Code tooling (agents, rules, skills), a RAG knowledge base, and reference examples.

## Agent Workflow

For new features, follow this pipeline in order:

1. **shiny-feature-planner** -- requirements intake, clarifying questions, parallelizable implementation plan
2. **shiny-ux-arbiter** -- UI/UX design decisions (layout, components, CSS, interaction patterns)
3. **shiny-r-architect** -- R/Shiny code implementation, architecture decisions, R6 design
4. **r-test-developer** -- unit tests, testServer(), AppDriver tests, roxygen updates
5. **r-code-reviewer** -- final quality gate (style, performance, codebase impact)

Not every task needs all 5 steps. Small bug fixes can go straight to the architect. But for new features, start with the planner.

## Key Directories

```
.claude/
  agents/         # 5 specialized agents (see workflow above)
  rules/          # Project-wide rules (always loaded into context)
  skills/         # Auto-invoked skill files for specific tasks
examples/
  async/          # 7 async pattern examples (promises, future, ExtendedTask, etc.)
rag/
  mcp_server.py   # RAG MCP server (hybrid vector + keyword search)
  ingest.py       # Document ingestion pipeline
  sources/        # Markdown/QMD files to ingest (populate as needed)
docs/
  shiny-developer-inventory.qmd  # Comprehensive skills/tools checklist
  shiny-dev-claude.md            # Claude setup evaluation and action plan
```

## Conventions

- **App structure:** Three-file layout (`global.R`, `ui.R`, `server.R`). Never `app.R`.
- **Pharma context:** CDISC data (SDTM/ADaM), patient listings, safety dashboards, clinical review tools.
- **Layout default:** Prefer bslib (`page_sidebar`, `page_navbar`, cards) for new apps.
- **Table default:** DT for interactive tables, gt for static/publication-quality tables. Ask if unclear.
- **Pipe:** Use `%>%` (tidyverse) unless specifically asked for `|>` (base).
- **Testing:** Every non-trivial function gets a test. Factory functions for test data.
- **Packages:** `renv::snapshot()` after every install/remove/update. Lockfile committed with the code.
