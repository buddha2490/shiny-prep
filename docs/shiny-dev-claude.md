# Shiny Developer Claude Setup -- Comprehensive Evaluation

**Date:** 2026-06-17
**Scope:** Full review of `.claude/` agents, rules, skills, RAG infrastructure, examples, and docs.

---

## Table of Contents

1. [Current Inventory](#1-current-inventory)
2. [Part 1: Inefficiencies and Optimization](#2-part-1-inefficiencies-and-optimization)
3. [Part 2: Suggested Additions](#3-part-2-suggested-additions)
4. [Part 3: Other Enhancements](#4-part-3-other-enhancements)
5. [Priority Action Plan](#5-priority-action-plan)

---

## 1. Current Inventory

### Agents (5)

| Agent | Purpose | Model | Lines |
|-------|---------|-------|-------|
| `shiny-feature-planner` | Feature intake, clarification, parallelizable implementation plans | Sonnet | ~160 |
| `shiny-ux-arbiter` | UI/UX design authority -- layout, components, CSS, interaction | Sonnet | ~180 |
| `shiny-r-architect` | R/Shiny implementation, R6 architecture, code writing | Sonnet | ~260 |
| `r-test-developer` | Unit tests, testServer(), AppDriver tests, roxygen updates | Sonnet | ~260 |
| `r-code-reviewer` | Code quality gate -- style, performance, codebase impact | Sonnet | ~200 |

### Rules (5)

| Rule | Purpose |
|------|---------|
| `shiny-app-structure` | Three-file layout (global.R, ui.R, server.R), directory conventions |
| `r-style` | Tidyverse style, snake_case, pipes, comments, formatting |
| `error-messages` | stop()/warning()/message() patterns, input validation order |
| `testing` | What to test, factory functions, full suite runs, 3-round remediation |
| `renv` | Snapshot after every change, lockfile with code, status checks |

### Skills (15)

| Skill | Trigger | Purpose |
|-------|---------|---------|
| `r-code` | Any R code request | Write-source-test-validate workflow |
| `shiny-modules` | Creating/modifying modules | NS/moduleServer, namespace rules, inter-module communication |
| `reactive-programming` | Reactive primitives | reactive(), observe(), isolate(), req(), debounce() |
| `shiny-testing` | Writing Shiny tests | Three-layer hierarchy, testServer(), AppDriver |
| `shiny-performance` | Performance optimization | Profiling, caching, async, anti-patterns |
| `r6-shiny` | R6 in Shiny | R6 anatomy, reactive bridging, shared state |
| `dt-table` | DT tables | DTOutput/renderDT, server-side, proxy, formatting |
| `reactable-table` | reactable tables | reactableOutput, colDef, selection, grouping |
| `gt-table` | gt tables | gt_output/render_gt, pipeline API, styling |
| `rhandsontable-table` | rhandsontable | Editable tables, hot_to_r(), validation |
| `raw-shiny-app` | Raw Shiny app | Lightweight apps without a framework |
| `golem-app` | golem apps | Package-based scaffold, deployment, config |
| `rhino-app` | rhino apps | box::use(), view/logic separation, Cypress |
| `leprechaun-app` | leprechaun apps | A la carte features, code generator |

### RAG Server

- Python MCP server with hybrid vector + keyword (FTS5) search
- Sentence-transformers (`all-MiniLM-L6-v2`) for embeddings
- SQLite backend with deduplication via content hashing
- **Currently empty** -- no documents ingested, no `rag/sources/` directory

### Examples

- 7 async examples (`examples/async/01-07`): promises, future_promise, future_callr, callr, extended_task, crew, mirai

### Docs

- `shiny-developer-inventory.qmd` -- comprehensive skill/tools checklist covering frameworks, packages, pharma topics

---

## 2. Part 1: Inefficiencies and Optimization

### CRITICAL: r-code Skill Contradicts Testing Rule

**Problem:** The `r-code` skill directly conflicts with the `testing` rule in several ways:

| Issue | `r-code` Skill Says | `testing` Rule Says |
|-------|---------------------|---------------------|
| Test location | `tests/test-<name>.R` | `tests/testthat/test-<name>.R` |
| Test data | Top-level `test_data <- tibble(...)` | Factory functions `make_data()` |
| Cleanup | `rm(list = ls())` at end of test file | Not mentioned (testthat handles isolation) |
| Source pattern | `source("R/<name>.R")` | Works for raw Shiny, breaks in packages |

**Impact:** When both fire in the same session, Claude gets contradictory instructions. The `r-code` skill fires first (broader trigger) and may override the more correct `testing` rule.

**Fix:**
1. Align the `r-code` skill test template with the `testing` rule (factory functions, correct path)
2. Remove `rm(list = ls())` -- it's a testthat anti-pattern that can interfere with test harness cleanup
3. Make the source pattern conditional: `source()` for raw Shiny, no source needed for package-based apps

### HIGH: Massive Rule Duplication Across Agents

**Problem:** Every agent re-states the project rules in full. Here's a rough token count of duplicated content:

- Three-file layout rules: repeated in all 5 agents (~50 lines each = ~250 lines total)
- R style rules: repeated in 4 agents (~30 lines each = ~120 lines total)
- Error message rules: repeated in 3 agents (~20 lines each = ~60 lines total)
- Testing rules: repeated in 3 agents (~30 lines each = ~90 lines total)
- renv rules: repeated in 3 agents (~15 lines each = ~45 lines total)

**Total duplication: ~565 lines of redundant content across agents.**

**Impact:** Each agent consumes ~150-260 lines of system prompt. When spawned as subagents, they each independently load all this duplicated content. This:
- Wastes context window space that could be used for actual code/reasoning
- Creates maintenance burden -- updating a rule means editing 5+ files
- Risks drift if one agent's copy gets out of sync with the canonical rule

**Fix:** Two approaches (choose one):

**Option A -- Reference Rules (Recommended):**
Replace the duplicated rule sections in each agent with a brief statement:
```
You MUST follow all project rules in `.claude/rules/`. These govern:
app structure (three-file layout), R style (tidyverse), error messages,
testing (factory functions, full suite), and renv (snapshot after changes).
Consult the rules directly if you need specifics.
```
This saves ~500 lines across agents while ensuring agents still read the canonical rules.

**Option B -- Shared Conventions File:**
Create `.claude/rules/shared-conventions.md` as a condensed reference and have each agent include a one-liner pointing to it. This is cleaner but adds another file to maintain.

### HIGH: Skill Auto-Invocation Conflicts

**Problem:** Several skills have overlapping or overly broad triggers:

1. **`r-code`** triggers on "any R code request" -- this fires on nearly every interaction, even when more specific skills (like `shiny-modules` or `reactive-programming`) would be more appropriate
2. **`reactive-programming`** and **`shiny-modules`** both cover reactive patterns and could fire simultaneously
3. Multiple table skills (`dt-table`, `reactable-table`, `gt-table`, `rhandsontable-table`) could all trigger on "create a table"

**Impact:** When multiple skills fire simultaneously, Claude gets a large chunk of instructions that may be partially irrelevant, diluting the useful context. In the worst case, conflicting advice from different skills causes inconsistent output.

**Fix:**
- Make `r-code` trigger more narrow: "Auto-invoked when writing standalone R functions or utility scripts. NOT invoked for Shiny-specific work (modules, reactives, server logic) -- those use dedicated Shiny skills."
- Add a note to table skills: "If the user hasn't specified a table package, default to DT for interactive tables and gt for static/publication tables. Ask the user if unclear."

### MEDIUM: Agent Model Selection

**Problem:** All 5 agents use `model: sonnet`. For some agents, this is appropriate. For others, the tasks require deeper reasoning.

**Analysis:**

| Agent | Task Complexity | Recommended Model |
|-------|----------------|-------------------|
| `shiny-feature-planner` | High -- requirements analysis, architecture decisions, parallelization planning | **Opus** (or Sonnet for cost savings) |
| `shiny-ux-arbiter` | Medium -- design decisions, CSS specifics | Sonnet (appropriate) |
| `shiny-r-architect` | High -- architecture decisions, R6 design, refactoring | **Opus** (worth the quality improvement) |
| `r-test-developer` | Medium -- structured test writing, pattern application | Sonnet (appropriate) |
| `r-code-reviewer` | High -- performance analysis, codebase impact assessment | **Opus** (reviews benefit from deeper analysis) |

**Fix:** Consider upgrading `shiny-feature-planner`, `shiny-r-architect`, and `r-code-reviewer` to `model: opus`. The feature planner and architect make decisions that cascade downstream -- getting them right is worth the compute cost.

### MEDIUM: No Enforced Agent Pipeline

**Problem:** The agents form an implicit workflow: planner -> UX -> architect -> tester -> reviewer. But nothing documents or enforces this sequence.

**Impact:** A user could:
- Jump straight to the architect without planning (skipping requirements)
- Ask the test developer before the code is written
- Skip the code review entirely

**Fix:** Add a section to the feature-planner agent that outputs a structured "Next Steps" with specific agent invocations. Example:
```
## Next Steps
1. Invoke `shiny-ux-arbiter` with the accepted requirements to produce a UI/UX spec
2. Invoke `shiny-r-architect` with the UI/UX spec to implement the feature
3. Invoke `r-test-developer` to write tests for the new code
4. Invoke `r-code-reviewer` for final quality review before commit
```

Also, add a `CLAUDE.md` at the project root that documents this workflow (see Part 3).

### MEDIUM: raw-shiny-app Skill Duplicates the shiny-app-structure Rule

**Problem:** The `raw-shiny-app` skill re-states the three-file layout, module patterns, directory structure, and package loading conventions that are already covered by:
- `shiny-app-structure` rule (loaded into every conversation)
- `shiny-modules` skill (loaded when working with modules)

**Impact:** When building a raw Shiny app, the user gets the same information from 3 sources. This is ~100 lines of wasted context.

**Fix:** Trim the `raw-shiny-app` skill to cover only what's unique to raw apps:
- When to use raw Shiny vs. a framework
- `R/` auto-sourcing behavior (Shiny 1.5+)
- Static assets in `www/`
- Configuration without a framework
- When to graduate to a framework
- Deployment via `rsconnect::deployApp()`

Remove the module pattern examples, directory layout, and package loading sections -- those are covered by rules and the modules skill.

### LOW: Memory Sections in Agent Prompts

**Problem:** Each agent includes ~30 lines of boilerplate for the Persistent Agent Memory system. This is identical across all 5 agents.

**Impact:** ~150 lines of identical boilerplate across agents. Not critical since this is auto-generated, but it adds to prompt length.

**Fix:** This is likely auto-generated by the Claude Code agent system and may not be editable. If it is, consider whether project-scope memory is actually needed for all agents. The feature-planner and architect benefit most from memory (tracking codebase knowledge). The test developer and reviewer could potentially use `memory: none`.

### LOW: Performance Skill is Very Long (~680 lines)

**Problem:** The `shiny-performance` skill is comprehensive but extremely long. When auto-invoked during performance work, it consumes a large chunk of the context window.

**Impact:** Most performance sessions focus on one specific area (e.g., reactive graph, caching, or async). Loading the entire skill for a focused question wastes context.

**Fix:** Consider splitting into separate skills:
- `shiny-profiling` -- profvis, reactlog, shiny.tictoc, shinyloadtest
- `shiny-caching` -- bindCache, memoise, cachem
- `shiny-async` -- ExtendedTask, future, promises
- Keep the anti-pattern quick reference and checklist in the main `shiny-performance` skill

---

## 3. Part 2: Suggested Additions

### New Rules

#### 1. `namespace-conflicts.md`

The `r-style` rule references a `namespace-conflicts` rule for the `package::function()` exception, but **this rule doesn't exist**. This is a broken reference.

**Content should include:**
```markdown
# Namespace Conflicts

When two loaded packages export the same function name, use `package::function()`
for the less frequently used one. Do NOT use `::` notation for non-conflicting functions.

## Known Conflicts

| Function | Packages | Default (unqualified) | Use `::` for |
|----------|----------|----------------------|--------------|
| `filter()` | dplyr, stats | dplyr | `stats::filter()` |
| `lag()` | dplyr, stats | dplyr | `stats::lag()` |
| `select()` | dplyr, MASS | dplyr | `MASS::select()` |
| `map()` | purrr, maps | purrr | `maps::map()` |
| `between()` | dplyr, data.table | dplyr | `data.table::between()` |
| `first()`, `last()` | dplyr, data.table | dplyr | `data.table::first()` |
| `intersect()`, `union()`, `setdiff()` | dplyr, base | dplyr | `base::intersect()` |
| `Position()` | ggplot2, base | base | `ggplot2::Position()` |

## Resolution Strategy

1. Load the more frequently used package LAST (it masks earlier ones)
2. Use `::` for the less frequently used package's function
3. If both are used heavily, consider `conflicted::conflict_prefer()`
```

#### 2. `git-conventions.md`

No git workflow conventions are documented. For a team environment, this matters.

**Content should include:**
- Branch naming: `feature/<name>`, `fix/<name>`, `refactor/<name>`
- Commit message format (conventional commits or team standard)
- When to commit: after each logical unit of work, never with broken tests
- What to include: code + tests + renv.lock in the same commit (reinforcing the renv rule)

### New Skills

#### 1. `bslib-layout` (HIGH PRIORITY)

**Why:** bslib is the modern layout system for Shiny (Bootstrap 5). It's becoming the default for new apps and is used by Posit Connect dashboards. Your inventory doc lists it but there's no skill for it.

**Should cover:**
- `page_sidebar()`, `page_navbar()`, `page_fillable()` -- the three main page types
- Cards: `card()`, `card_header()`, `card_body()`, `card_footer()`
- Value boxes: `value_box()` with icons from bsicons
- Layout: `layout_columns()`, `layout_column_wrap()`, `layout_sidebar()`
- Navsets: `navset_tab()`, `navset_card_tab()`, `nav_panel()`
- Theming: `bs_theme()`, custom Sass variables, real-time theme previewing
- Accordion: `accordion()`, `accordion_panel()`
- This is critical for day-1 productivity -- most modern Shiny apps use bslib

#### 2. `shiny-download-upload` (HIGH PRIORITY)

**Why:** File upload/download is one of the most common Shiny patterns and a frequent source of bugs (temp file paths, MIME types, reactive timing).

**Should cover:**
- `fileInput()` / `input$file` -- the datapath structure, handling multiple files
- `downloadButton()` / `downloadHandler()` -- content function, filename function
- CSV/Excel/PDF export patterns
- Progress indicators during file processing
- File size limits and validation
- Common pitfall: `input$file` is NULL on first load, returns a data frame of metadata

#### 3. `plotly-shiny` (MEDIUM PRIORITY)

**Why:** plotly is the most common interactive visualization library in Shiny. `ggplotly()` conversion and plotly event handling (click, hover, selection) are daily tasks.

**Should cover:**
- `plotlyOutput()` / `renderPlotly()` pattern
- `ggplotly()` conversion and its quirks (legend position, tooltip customization)
- Event data: `event_data("plotly_click")`, `event_data("plotly_selected")`
- `plotlyProxy()` for efficient updates without full re-render
- Performance: `toWebGL()` for large datasets
- Common pitfall: ggplotly tooltip customization requires `text` aesthetic

#### 4. `shiny-bookmarking` (LOW PRIORITY)

**Why:** State bookmarking enables shareable URLs, which is critical for collaborative clinical review dashboards.

**Should cover:**
- `enableBookmarking("url")` vs `enableBookmarking("server")`
- `bookmarkButton()` and `onBookmark()` / `onRestore()` callbacks
- Excluding inputs from bookmarking
- Module-aware bookmarking

#### 5. `shinydashboard-layout` (MEDIUM PRIORITY)

**Why:** Many existing pharma Shiny apps use shinydashboard or bs4Dash. You may need to maintain legacy apps on day 1.

**Should cover:**
- `dashboardPage()`, `dashboardHeader()`, `dashboardSidebar()`, `dashboardBody()`
- `box()`, `tabBox()`, `infoBox()`, `valueBox()`
- `sidebarMenu()` / `menuItem()` with `tabItems()` / `tabItem()`
- Dynamic sidebar and conditional menu items
- `bs4Dash` equivalents for Bootstrap 4 version

### New Agents

#### 1. `shiny-debugger` (RECOMMENDED)

**Why:** Debugging is where developers spend a disproportionate amount of time. A dedicated debugging agent would be invaluable for:
- Interpreting Shiny error messages and stack traces
- Diagnosing reactive graph issues (blank outputs, infinite loops, unexpected re-renders)
- Identifying namespace/ID mismatches between UI and server
- Troubleshooting deployment failures (missing packages, path issues, permission errors)
- Reading and interpreting reactlog output

**Trigger examples:**
- "My output is blank but there's no error"
- "I'm getting 'object of type closure is not subsettable'"
- "The app works locally but fails on Connect"
- "This observer seems to fire in a loop"

**Model:** Sonnet (debugging is pattern-matching more than deep reasoning)

---

## 4. Part 3: Other Enhancements

### Create a CLAUDE.md

You have no `CLAUDE.md` at the project root. This is the first thing Claude reads and it should orient every conversation. A CLAUDE.md would:

1. Describe the project purpose (Shiny developer preparation repo)
2. Document the agent pipeline workflow
3. List key directories and their purposes
4. State preferences that apply across all interactions

**Suggested content:**
```markdown
# shiny-prep

This repo is a preparation environment for R Shiny development.
It contains Claude Code tooling (agents, rules, skills), a RAG knowledge
base, and reference examples.

## Agent Workflow

For new features, follow this pipeline:
1. `shiny-feature-planner` -- requirements, clarification, implementation plan
2. `shiny-ux-arbiter` -- UI/UX design decisions
3. `shiny-r-architect` -- code implementation
4. `r-test-developer` -- test coverage
5. `r-code-reviewer` -- final quality gate

## Key Directories

- `.claude/` -- agents, rules, skills for Claude Code
- `examples/` -- reference implementations of common patterns
- `rag/` -- Python RAG server with MCP integration
- `docs/` -- documentation and inventories

## Preferences

- Pharma/clinical context: CDISC data (SDTM/ADaM), patient listings, safety dashboards
- Always prefer bslib for new layouts
- Default table package: DT for interactive, gt for static
- Use conventional commits for git messages
```

### Populate the RAG

The RAG infrastructure is solid but empty. Here's what to ingest, in priority order:

#### Tier 1 -- Ingest Immediately

1. **`docs/shiny-developer-inventory.qmd`** -- Your own comprehensive inventory. This gives the RAG a broad knowledge of the ecosystem.

2. **Package comparison guides** -- Create a `rag/sources/package-comparisons.md` covering:
   - DT vs reactable vs gt vs rhandsontable (when to use each)
   - bslib vs shinydashboard vs bs4Dash (layout frameworks)
   - golem vs rhino vs leprechaun (app frameworks)
   - future vs callr vs crew vs mirai (async backends)

3. **Common patterns cheatsheet** -- Create `rag/sources/common-patterns.md`:
   - File upload/download
   - Dynamic UI (renderUI, insertUI, removeUI)
   - Conditional panels and show/hide
   - Modal dialogs
   - Notifications and progress bars
   - Bookmarking
   - Multi-page apps (navbarPage patterns)

#### Tier 2 -- Build Over Time

4. **CDISC data reference** -- Create `rag/sources/cdisc-reference.md`:
   - SDTM domain overview (DM, AE, LB, VS, EX, CM, etc.)
   - ADaM dataset types (ADSL, ADAE, ADLB, ADTTE, etc.)
   - Standard variable naming conventions (USUBJID, AVAL, PARAMCD, etc.)
   - Common data joins and relationships

5. **Pharma Shiny patterns** -- Create `rag/sources/pharma-shiny-patterns.md`:
   - Patient profile module pattern
   - Adverse event listing module
   - Lab shift plot module
   - Kaplan-Meier plot module
   - Forest plot module
   - Subgroup filtering cascade

6. **Deployment playbooks** -- Create `rag/sources/deployment.md`:
   - Posit Connect deployment checklist
   - Docker deployment patterns
   - CI/CD with GitHub Actions for Shiny apps
   - Environment variable management
   - renv restore in CI

7. **Error/debugging reference** -- Create `rag/sources/shiny-errors.md`:
   - Common error messages and their causes
   - Reactive debugging techniques
   - Browser console debugging for Shiny
   - R session crash diagnosis

### Expand Examples Directory

Your async examples are great. Add these reference implementations:

#### Module Examples (HIGH PRIORITY)
```
examples/modules/
  01_basic_module/          # Minimal NS/moduleServer pattern
  02_module_communication/  # Returning reactives between modules
  03_shared_state_rv/       # reactiveValues shared across modules
  04_shared_state_r6/       # R6 object shared across modules
  05_nested_modules/        # Modules within modules
  06_dynamic_modules/       # insertUI/removeUI for dynamic module creation
```

#### Table Examples
```
examples/tables/
  01_dt_basic/              # DTOutput/renderDT with formatting
  02_dt_proxy/              # dataTableProxy for efficient updates
  03_dt_editable/           # Editable DT cells
  04_reactable_custom/      # reactable with custom cell renderers
  05_gt_publication/        # gt table with spanners, footnotes
  06_rhandsontable_edit/    # Editable spreadsheet with save/reset
```

#### Layout Examples
```
examples/layouts/
  01_bslib_sidebar/         # page_sidebar with cards
  02_bslib_navbar/          # page_navbar with multiple pages
  03_bslib_dashboard/       # Dashboard with value boxes and cards
  04_shinydashboard/        # Classic shinydashboard layout
```

#### Pharma Examples (once you know the team's patterns)
```
examples/pharma/
  01_patient_listing/       # Subject-level data table with filters
  02_ae_summary/            # Adverse events summary table
  03_lab_shift/             # Lab shift plot with baseline vs post-baseline
  04_km_plot/               # Kaplan-Meier survival plot
  05_forest_plot/           # Subgroup forest plot
```

**Note:** Each example should use the three-file layout and include a README.md explaining what pattern it demonstrates. These examples serve double duty: they're reference code you can copy from AND they can be ingested into the RAG for searchable retrieval.

### Create a `rag/sources/` Directory Structure

```
rag/
  sources/
    README.md                       # Ingest instructions
    shiny-developer-inventory.md    # Copy/convert from docs/
    package-comparisons.md          # DT vs reactable, golem vs rhino, etc.
    common-patterns.md              # Upload, download, modals, dynamic UI
    cdisc-reference.md              # SDTM/ADaM overview
    pharma-shiny-patterns.md        # Clinical dashboard module patterns
    deployment.md                   # Posit Connect, Docker, CI/CD
    shiny-errors.md                 # Error messages and debugging
  ingest.py
  mcp_server.py
  rag.db
```

### Consider a `hooks` Configuration

Claude Code hooks can automate repetitive checks. Useful hooks for this project:

1. **Post-edit hook for R files:** Run `lintr::lint()` on the file after edits
2. **Pre-commit reminder:** Check that `renv.lock` is up to date when R files change
3. **Test reminder:** After editing a `R/mod_*.R` or `R/utils_*.R` file, remind to run associated tests

### Missing Skill: `validate-need` Pattern

The `reactive-programming` skill mentions `validate(need(...))` briefly, but the `error-messages` rule only covers `stop()`/`warning()`/`message()`. The Shiny-specific error display pattern deserves explicit coverage:

```r
# User-facing validation (shows in output panel)
output$plot <- renderPlot({
  validate(
    need(input$group != "", "Please select a group."),
    need(nrow(data()) > 0, "No data matches your filters.")
  )
  plot(data())
})

# vs. tryCatch for unexpected errors
output$table <- renderTable({
  tryCatch(
    process_data(data()),
    error = function(e) {
      showNotification(paste("Error:", e$message), type = "error")
      NULL
    }
  )
})
```

This could be added to the `error-messages` rule or as a new skill `shiny-error-handling`.

---

## 5. Priority Action Plan

### Immediate (Before Day 1)

| # | Action | Impact | Effort |
|---|--------|--------|--------|
| 1 | **Fix r-code skill** -- align test template with testing rule (factory functions, correct path, remove `rm()`) | Prevents conflicting instructions | Low |
| 2 | **Create namespace-conflicts.md** rule -- the r-style rule references it but it doesn't exist | Fixes broken reference | Low |
| 3 | **Reduce agent duplication** -- replace full rule copies with brief references | Saves ~500 lines of redundant context | Medium |
| 4 | **Add bslib-layout skill** -- modern layout is used everywhere | Day-1 productivity | Medium |
| 5 | **Add shiny-download-upload skill** -- constant need in pharma apps | Day-1 productivity | Medium |
| 6 | **Create CLAUDE.md** -- orients every conversation | Foundation for everything else | Low |

### Short-Term (First 2 Weeks)

| # | Action | Impact | Effort |
|---|--------|--------|--------|
| 7 | **Ingest RAG content** -- start with inventory doc and package comparisons | Makes RAG useful | Medium |
| 8 | **Build module examples** -- basic module, communication patterns, R6 state | Reference code for real work | Medium |
| 9 | **Add plotly-shiny skill** | Common visualization need | Low |
| 10 | **Add shiny-debugger agent** | Saves time on debugging | Medium |
| 11 | **Narrow r-code skill trigger** | Reduces skill conflicts | Low |

### As-Needed (Build Over Time)

| # | Action | Impact | Effort |
|---|--------|--------|--------|
| 12 | Upgrade agent models (planner, architect, reviewer to Opus) | Better decisions | None (config change) |
| 13 | Build pharma-specific examples (patient listing, AE table, KM plot) | Domain-specific reference | High |
| 14 | Create CDISC reference for RAG | Pharma data knowledge | Medium |
| 15 | Add deployment skill | Production readiness | Medium |
| 16 | Split performance skill into sub-skills | Reduces context waste | Low |
| 17 | Add shinydashboard-layout skill | Legacy app maintenance | Low |
| 18 | Add shiny-bookmarking skill | Collaborative dashboards | Low |

---

## Appendix: Overall Assessment

**Strengths:**
- The agent pipeline concept (planner -> UX -> architect -> tester -> reviewer) is well-designed and mirrors a real development team
- Skills are thorough and well-structured with decision tables, canonical patterns, common pitfalls, and checklists
- The testing pyramid (unit -> testServer -> AppDriver) is correctly prioritized
- Framework coverage (raw, golem, rhino, leprechaun) is comprehensive
- The RAG infrastructure (hybrid search with RRF, FTS5, MCP integration) is production-quality
- The developer inventory doc is an excellent knowledge map

**Weaknesses:**
- Rule duplication across agents wastes context and creates maintenance burden
- The r-code skill has direct conflicts with the testing rule
- The RAG is empty -- it's infrastructure without content
- No CLAUDE.md to tie everything together
- Missing day-1 essentials: bslib layouts, file upload/download, namespace conflicts rule
- No debugging agent for the most time-consuming development activity
- Examples are async-only -- need module, table, and layout examples

**Bottom line:** The foundation is strong. The agent/skill architecture is thoughtful and the content quality is high. The main issues are redundancy, a few contradictions, and gaps in commonly-needed patterns. Fixing the top 6 items in the priority list will make this setup genuinely production-ready for day 1.
