# shiny-prep — Day-One Readiness Review (v2)

**Date:** 2026-06-18
**Reviewer:** Claude (4-agent parallel deep-dive: RAG · rules+agents · skills · examples, each cross-checked against the live RAG)
**Scope:** Full repo — `rag/`, `.claude/` (rules, agents, skills), `examples/`, and the wiring that ties them together.

> ⚠️ **Read this first:** `.gitignore` contains a single line — `docs/*`. The **entire `docs/` folder is gitignored**, which is why the v1 report (`docs/shiny-dev-claude.md`) and the readable `docs/comparisons/` series (now an empty directory) are gone from version control. **This report is also being written into the ignored folder.** Fixing `.gitignore` is item #1 in the backlog below, because right now any documentation you write here is silently untracked and can vanish.

---

## 1. Executive Summary

**Verdict: This is a genuinely strong, above-bar foundation — but it is not yet "day-one complete," and the gaps cluster in one telling place: the pharma/clinical domain the repo exists to serve.**

The craftsmanship of what's built is high. The 21 skills are concrete, code-driven, and (verified) consistent with the authoritative docs in the RAG. The 8 rules are opinionated and internally coherent, with a standout error-handling/logging/error-messages trio. The 4 example apps are idiomatic, runnable, rule-compliant, and genuinely AI-readable. The RAG retrieval algorithm (hybrid vector + FTS5 + reciprocal rank fusion) returns relevant, complete chunks for everything it actually contains. If you measure quality-of-what-exists, this is an **A‑.**

But three systemic issues hold it back from day-one readiness:

1. **The pharma domain is absent across every layer.** No CDISC rule, no CDISC skill, no CDISC RAG source, no end-to-end clinical example. The repo's modules *use* `adsl`/`adae`/`adlb` data and the logging rule *assumes* `USUBJID`/`PARAMCD` conventions, but nothing actually governs reading, joining, validating, or labeling CDISC data. This is the single biggest gap relative to the job.
2. **The marquee assets are invisible to the agents.** Zero of the 6 agents reference the RAG MCP (`mcp__shiny-rag__rag_search`) or the `.claude/skills/` directory. The project's two best assets — a 1,478-chunk knowledge base and 21 skills — are never surfaced to the agents that would benefit most (architect, debugger, ux-arbiter, reviewer).
3. **Reproducibility is fragile.** No Python dependency manifest for the RAG server, hardcoded absolute paths in `.mcp.json`, a `.vscode/.mcp.json` that points at a *different project entirely*, and `renv` is referenced everywhere but **never initialized** (no `renv.lock`, no `renv/`). On a fresh clone or a second machine, the RAG server won't start and the lockfile the rules demand doesn't exist.

None of these are quality problems with the existing material. They are *coverage* and *wiring* problems. The backlog in §6 is ordered to close them.

**Overall scores by subsystem:**

| Subsystem | Quality of what exists | Coverage / completeness | Day-one ready? |
|---|---|---|---|
| RAG pipeline (code) | A- | — | Reproducibility issues |
| RAG sources | A (retrieval) | C (core shiny + pharma absent) | No |
| Rules | A | B- (pharma/git/validation rules missing) | Mostly |
| Agents | A- | B (no RAG/skills wiring; pipeline gaps) | Mostly |
| Skills | A (18/21 exemplary) | B+ (CDISC/deploy/DB gaps) | Mostly |
| Examples | A | C+ (no assembled pharma app) | Partially |
| CLAUDE.md / wiring | C | — | No (stale + omissions) |

---

## 2. Cross-Cutting Themes (the findings that showed up in 3+ reviews)

These are the highest-leverage issues because they recur across subsystems.

### 2.1 The pharma/CDISC vacuum (appeared in all 4 reviews)
The repo is explicitly CDISC (SDTM/ADaM) per `CLAUDE.md:38`, yet:
- **No rule** defines CDISC data handling (`USUBJID` keys, `haven`/`labelled` factor+label handling, `.xpt` ingestion, `NA`/blank/`.` missing conventions, controlled terminology) — even though `logging.md` already references `USUBJID`/`PARAMCD` as if such conventions exist.
- **No skill** fires on a request like *"load the ADaM datasets and join ADSL to ADAE"* — the closest match is `raw-shiny-app`, which won't trigger on a data task.
- **No RAG source** for `teal`, `teal.modules.clinical`, `admiral`, `rtables`, `safetyGraphics`, `pharmaverseadam` — they exist only as a 6-row table in an orphaned (now-deleted) inventory doc.
- **No example** assembles a clinical app end-to-end (the keystone day-one deliverable).

This is the clearest pattern in the whole review: the domain-specific work is exactly the work with no support.

### 2.2 Agents don't use the RAG or skills (rules+agents review, confirmed by grep)
All 6 agents say "consult `.claude/rules/`" but **none** say "search the RAG before asserting a technical fact" or "the relevant skill governs this pattern." The architect never points to `r6-shiny`/`raw-shiny-app`/`shiny-modules`; the ux-arbiter owns bslib/CSS decisions but never consults the 128-chunk bslib docs or `bslib-layout` skill; the test-developer never references the `shiny-testing` skill or the 132-chunk shinytest2 source. One-line additions to each agent prompt would fix this.

### 2.3 Deployment / ops is empty at every layer
No deployment rule, no deployment agent (the debugger *diagnoses* deploy failures but nothing *performs* deployment), no deployment skill (it's scattered as subsections inside the framework skills), no deployment example, and no RAG source on Posit Connect / `rsconnect` / manifests / Docker / validation. For a regulated pharma job, the *validated deployment* story is day-one relevant and wholly missing.

### 2.4 Reproducibility & wiring rot
- **No Python manifest** (`requirements.txt`/`pyproject.toml`) — RAG deps (`sentence-transformers`, `numpy`, `mcp`, `PyMuPDF`) live only inside the committed `.venv`, which is built on bleeding-edge **Python 3.14** (immature torch/sentence-transformers wheels). Not reproducible on another machine — the exact gap the `renv` rules exist to prevent, but on the Python side.
- **`.mcp.json` hardcodes absolute paths**; **`.vscode/.mcp.json` registers a different project** (`npm-rag-v1`), so VS Code users get no shiny-rag at all.
- **`renv` is never initialized.** `.Rprofile` references it, every renv rule assumes it, and the planner/debugger agents tell Claude to "check `renv.lock`" — but there is no `renv.lock` and no `renv/` directory. Per project memory, `Rscript --no-init-file` is currently needed to avoid the `.Rprofile` renv error.

### 2.5 CLAUDE.md is stale (the front door is wrong)
`CLAUDE.md` is the one file every agent reads, and it's out of date:
- `:25` references `examples/async/` — the real path is `examples/01. async/` (**broken**).
- `:21` says "5 specialized agents" — there are **6** (`shiny-debugger` is undocumented in both the comment and the workflow section).
- It never mentions `.claude/skills/`, the RAG MCP tool, or `.claude/agent-memory/` — so an agent reading only CLAUDE.md never learns the RAG or skills exist (compounds 2.2).
- The "Key Directories" map omits `examples/02–04` and the `docs/comparisons/` series.

---

## 3. Subsystem Assessments

### 3.1 RAG Knowledge Base

**Pipeline code (`ingest.py`, `mcp_server.py`, `pdf_to_markdown.py`): clean and sound, with real fragilities.**
- Architecture is good: PDF → markdown → chunk (one H2 per exported function, ~300 tokens, code-fence-aware) → embed (all-MiniLM-L6-v2, normalized) → SQLite + FTS5 → hybrid search over MCP. The Python is readable and well-commented; `Path(__file__).parent` keeps the scripts themselves path-clean.
- **Vector search is brute-force** (`mcp_server.py:70-93`): every query deserializes all 1,478 embeddings and computes cosine in a Python loop. Fine at this scale (sub-second), degrades linearly — flag before the corpus passes ~10k chunks; `sqlite-vec` would fix it.
- **Stale-chunk accumulation** (`ingest.py:242-271`): dedup is by `content_hash` UNIQUE, so editing a source and re-ingesting *adds* new chunks and *leaves the old ones* — stale content competes in retrieval. No `--reset`/`--replace-source` path. **Live evidence:** `shiny-developer-inventory.qmd` contributes 29 chunks that still rank #1 on many queries, but **its source file is deleted** (it lived in the now-ignored `docs/`). Those chunks are orphaned and unrefreshable.
- **Parser bug:** `bs4Dash.md` front matter is `version: "of"` — the `Version\s+(\S+)` regex (`pdf_to_markdown.py:51`) grabbed the wrong token. Version metadata is not fully trustworthy (though plotly 4.12.0, bslib 0.11.0, shinytest2 0.5.1, renv 1.2.3, shinydashboard 0.7.3 all parsed correctly).
- Minor: shared single SQLite connection (`check_same_thread` risk), redundant norm recomputation, header breadcrumb printed twice in results.

**Retrieval quality (live-tested): excellent for what's ingested, blind to what isn't.**

| Query | Verdict |
|---|---|
| plotlyProxy update a trace | Good (present, ranking slightly off) |
| bslib value box | Excellent |
| testServer reactive testing | Shallow — no real `testServer()` doc, only inventory bullets |
| renv snapshot/restore | Excellent |
| log4r appender setup | Excellent |
| CDISC admiral / teal module | **Poor** — only the 6-row inventory table |
| deploy Posit Connect manifest | **Fail** — only tangential hits |

**Source coverage holes, ranked:**
1. **Core `shiny` itself is not ingested** — the knowledge base is named for a package it doesn't contain. Reactivity/modules/`req`/`validate`/`downloadHandler` exist only as inventory bullets. Highest-impact RAG fix.
2. **Pharma stack** (`teal`, `admiral`, `rtables`, `safetyGraphics`) — absent as real docs.
3. **Deployment/ops** — absent.
4. **gt and DT reference docs** — only the comparison guide exists; the repo's "DT interactive / gt static" default has no API backing.
5. **ggplot2** — the default static engine for clinical figures (KM, forest, boxplots) has zero coverage.
6. **Performance/debug tooling** (`reactlog`, `profvis`, `bindCache`/`memoise`) — skill-covered, not RAG-covered.

> **Imbalance note:** the LLM-tooling cluster (ellmer/btw/shinychat/querychat/ragnar/mcptools/vitals ≈ 357 chunks, ~24% of the corpus) is heavily over-represented for a clinical Shiny dev's day-one needs, while core shiny and the pharma stack sit at zero.

### 3.2 Rules

**Quality: high and internally consistent.** No hard contradictions. The `%>%` pipe, three-file/never-`app.R`, and `library()`-unqualified-vs-`::`-qualify boundaries are all clean and mutually reinforcing. Technical claims spot-checked against the RAG (renv snapshot types, log4r appenders/layout) are accurate. The error-handling/logging/error-messages trio (wording vs. control-flow vs. the log) is the best-designed part of `.claude/`.

**Missing rules, ranked:**
1. **CDISC / clinical-data rule** (highest) — see §2.1.
2. **Git / branch / PR / commit-convention rule** — only the lockfile-with-code rule exists; nothing on branching, commit format, or PR structure. Matters for regulated traceability.
3. **Validation / GxP / 21 CFR Part 11 rule** — requirements traceability, qualified releases, audit trails. Absent.
4. **Accessibility / Section 508 / WCAG rule** — currently lives *only* inside the ux-arbiter agent's prompt; not a rule, so the reviewer doesn't enforce it.
5. **Security / secrets rule** — `shiny-app-structure.md:14` says DB connections go in `global.R` with no secrets caveat; nothing covers `.Renviron`, env-var credentials, or SQL input sanitization.

Minor friction: framework skills (golem/leprechaun/rhino) use `app.R`-style entry points that sit in tension with the "never app.R" rule — needs an explicit "frameworks are the exception" note (see 3.4).

### 3.3 Agents

**Quality: strong prompts, coherent 5-step pipeline (planner → ux → architect → test → review), with the debugger as a 6th on-demand diagnostic.** The debugger has the best system prompt of the six.

**Systemic gaps:**
- **No agent references the RAG or skills** (§2.2) — the top finding.
- **Handoffs are prose-only:** the pipeline lives in CLAUDE.md, not in the agents — nothing tells the architect to invoke the test-developer or reviewer next.
- **Agents reference `renv.lock`** (planner `:38`, debugger `:16`) which doesn't exist yet (§2.4).
- **Architect mandates roxygen `@export` on every function** (`:41,:101`) — a *package* convention, slightly odd for raw three-file apps.
- **Inconsistent agent-memory schema:** the debugger uses a richer typed scheme (user/feedback/project/reference) than the other five.

**Missing agents, ranked:** (1) Deployment/DevOps, (2) CDISC/data-engineering, (3) Accessibility/508 auditor, (4) optional Documentation/roxygen.

### 3.4 Skills

**Quality: 18 of 21 are exemplary** — concrete, code-driven, and verified consistent with the RAG (bslib, mirai, shinytest2, plotly, dt, log4r-via-error-handling all checked, zero drift). `plotly-shiny`, `shiny-performance`, `shiny-modules`, and `bslib-layout` are best-in-class.

**Real problems:**
- **`r-package` is the weak link** — it's a verbatim third-party skill whose frontmatter `name: r-package-development` mismatches its directory (`r-package`), which can confuse invocation, and it **mandates `|>` and bans `%>%`** (`:45`), directly contradicting `r-style.md`/CLAUDE.md. It also pushes `air format`, `expect_snapshot(error=TRUE)`, and pkgdown conventions that don't fit the house style.
- **`gt-table` uses deprecated `fmt_missing()`** (`:66,:193`) — should be `sub_missing()`.
- **`r-code` internal path inconsistency** (`:22` says `tests/test-*.R`, should be `tests/testthat/test-*.R`).
- **Framework skills (golem/leprechaun/rhino) don't acknowledge the app.R exception** — they generate `app.R`/`run_app.R` with no note that the "never app.R" rule applies to *raw* apps. (`raw-shiny-app`, `shiny-bookmarking`, `shinydashboard-layout` model the right behavior by explicitly honoring the rule.)
- **`r6-shiny` closes with `shinyApp(ui, server)`** (`:185`) instead of assigned `ui`/`server` — minor house-style slip.

**Missing skills, ranked:** (1) CDISC/ADaM data handling, (2) Deployment/Posit Connect/renv, (3) DBI/pool database (currently buried in `shiny-performance`), (4) reactlog/debugging skill, (5) sass/theming + JS/htmlwidgets, (6) accessibility/508.

**Overlap:** `reactive-programming ↔ shiny-modules ↔ shiny-performance` share the reactive-graph mental model — benign, each framed for its own task.

### 3.5 Examples

**Quality: high — idiomatic, correct, runnable, rule-compliant, genuinely AI-readable** with strong teaching comments and README pattern catalogs/decision trees.
- **`01. async/`** (7 single-`app.R` pattern isolators): the app.R use is **correctly acknowledged** as a deliberate brevity exception in the top-level README and every file header — not a violation.
- **`02. plotly/`**: most feature-dense; scattergl/downsampling/plotlyProxy all match the documented API; reusable theme helper is a real asset.
- **`03. modules/`**: textbook NS/moduleServer across 6 patterns incl. the R6 reactiveVal bridge and the dynamic-module `local()` closure fix.
- **`04. error-handling/`**: **faithfully implements** the rules/skill it backs — catalog codes, incident ids, `with_error_handling()`, never-throwing `get_logger()`, `LOG_LEVEL` threshold, `shiny.sanitize.errors`, FATAL safety net, async `task$result()`-inside-wrapper, no-PHI. Tests are real and behavior-focused.

**Issues found:**
- **`03. modules/README.md:172` and rule #7 (`:307`) say to use `session$ns()` for nested server calls — the code correctly uses the SHORT id and warns that `session$ns()` would double-namespace.** This README/code contradiction is the **highest-value example fix**: an AI copying the summary rule would introduce a real double-namespacing bug.
- **`04/R/mod_async_task.R:45` uses `|>`** instead of `%>%` — the only pipe violation in all of `examples/` (the RAG's own snippet for this pattern uses `%>%`).
- Minor: examples 02/03 read `input$*` into computations without `req()` guards while 04 is rigorous — inconsistent; `gwas_data.csv` (10M rows) is committed rather than regenerated from its script.

**Missing examples, ranked:** (1) **full CDISC safety/patient-listing app** composing modules + DT/gt + bslib + the error-handling helpers (the keystone), (2) DT+gt tables example, (3) bslib-layout dashboard example, (4) shinytest2/AppDriver E2E example, (5) pool/database example, (6) deployment example.

---

## 4. What's Genuinely Excellent (keep / replicate)

So the backlog doesn't read as all-negative — these are the parts to model new work on:
- The **error-handling/logging framework** (rules + skill + `examples/04`) is the gold standard in the repo: a rule trio with clean separation, a worked reference app, and real behavior-tests. Use it as the template for the CDISC and deployment subsystems.
- The **`plotly-shiny` skill and `examples/02`** — pattern tables with "where in code," when-to/when-NOT-to sections, performance decision trees.
- The **RAG retrieval quality** for ingested topics — hybrid search + RRF returns relevant, complete chunks. The algorithm is right; it just needs more (and the right) sources.
- The **skills' RAG-consistency** — verified zero drift across six spot-checks. The skills are trustworthy against authoritative docs.

---

## 5. Does it meet a high enough standard to work with on day one?

**Yes for general Shiny work; not yet for the pharma specifics or for a clean fresh-machine setup.**

- If your day-one tasks are general Shiny (layouts, modules, tables, plotly, async, error-handling, testing), the skills + RAG + examples will make Claude productive immediately. That work is well-supported and high quality.
- If your day-one tasks are **clinical-specific** (load/join ADaM, build a safety dashboard, a patient listing, validated deployment), the support drops to near-zero and Claude will be working from general knowledge, not your curated assets.
- The **wiring must be fixed before you rely on it on a work machine**: initialize renv, add the Python manifest, fix both `.mcp.json` files, and fix `.gitignore` — otherwise the RAG won't start and the lockfile the rules assume won't exist.

Net: a strong foundation that needs a focused pharma layer and a reproducibility pass to be truly day-one complete.

---

## 6. Prioritized Backlog (tackle piecemeal)

Ordered by leverage. **P0 = do before relying on the repo; P1 = closes the pharma gap; P2 = polish.**
Effort: **S** = <30 min, **M** = ~half-day, **L** = multi-day.

### P0 — Wiring & reproducibility (do first; fast, high-impact)
1. **Fix `.gitignore`** (S) — `docs/*` ignores the whole folder. Narrow it (e.g. ignore only `docs/pdf/`) so reports + comparisons are tracked. *Recover the lost v1 doc and `docs/comparisons/` series if they exist elsewhere.*
2. **Fix `.vscode/.mcp.json`** (S) — it registers `npm-rag-v1`, not shiny-rag. Copy the correct server block from `.mcp.json`.
3. **Add a Python manifest for the RAG** (S–M) — `requirements.txt`/`pyproject.toml` pinning `sentence-transformers`, `numpy`, `mcp`, `PyMuPDF`; pin to stable Python 3.11/3.12 (off 3.14). Add `rag/.venv/`, `rag/__pycache__/`, `rag/*.db-wal`, `rag/*.db-shm` to `.gitignore`.
4. **Initialize renv** (M) — `renv::init()` so the `renv.lock` the rules and agents assume actually exists; resolves the `--no-init-file` workaround.
5. **Update CLAUDE.md** (S) — fix `examples/async/` → `examples/01. async/`; "5 agents" → 6 (+document the debugger); add `.claude/skills/`, the RAG MCP tool, and `.claude/agent-memory/` to the directory map and workflow.
6. **Wire the RAG + skills into every agent** (S–M) — add to each agent prompt: "Before asserting a technical fact or choosing a package API, search `mcp__shiny-rag__rag_search`; consult the relevant `.claude/skills/` file for package patterns." Highest-leverage agent fix.

### P1 — Close the pharma gap (the reason the repo exists)
7. **Ingest core `shiny` reference docs into the RAG** (M) — the knowledge base is named for a package it doesn't contain.
8. **Add a CDISC / clinical-data rule** (M) — `USUBJID` keys, `haven`/`labelled` factor+label handling, `.xpt` ingestion, missing-data conventions, controlled terminology. Defines the conventions `logging.md` already assumes.
9. **Add a CDISC / ADaM data-handling skill** (M) — fires on "load/join ADaM" tasks; covers admiral/metacore/metatools, `PARAMCD`/`AVISIT` pivots.
10. **Ingest the pharma stack into the RAG** (M) — `teal`(+`teal.modules.clinical`), `admiral`, `rtables`, `safetyGraphics`.
11. **Build the keystone example: a full CDISC safety/patient-listing app** (L) — ADSL/ADAE/ADLB → bslib `page_navbar` with demographics, AE DT tables, a safety value-box row, patient drill-down, using the `examples/04` error-handling helpers. The closest proxy for the real job.
12. **Ingest gt + DT (+ ggplot2) reference docs** (M) — back the stated "DT interactive / gt static" default with real API docs.

### P1 — Deployment (currently empty at every layer)
13. **Add a deployment rule + skill + a deployment example** (M–L) — `rsconnect` manifests, `renv.lock` restore, Connect vs shinyapps.io vs Shiny Server, env-var secrets, validation evidence. Consider a **Deployment/DevOps agent** to complement the debugger's diagnose-only coverage.
14. **Ingest a deployment/ops source into the RAG** (M).

### P1 — Missing rules & agents
15. **Add Git/PR, Validation/GxP, Accessibility/508, and Security/secrets rules** (M total) — promote accessibility from a ux-arbiter aside to an enforced rule, and have the reviewer check it.
16. **Add a CDISC/data-engineering agent** (M) — pairs with #8/#9.

### P2 — Targeted fixes (fast, mechanical)
17. **`examples/03. modules/README.md:172` & rule #7 (`:307`)** (S) — change `session$ns()` → SHORT id to match the (correct) code. Prevents an AI from copying a double-namespacing bug.
18. **`r-package` skill** (S) — reconcile frontmatter `name` to `r-package`; add an override note that for *this project* `%>%` and `expect_error()` apply (or re-author).
19. **Framework skills** (S) — add the one-line "app.R exception applies to raw apps; frameworks use their own entry point" note to golem/leprechaun/rhino.
20. **`gt-table:66,:193`** (S) — `fmt_missing()` → `sub_missing()`.
21. **`r-code:22`** (S) — `tests/test-*.R` → `tests/testthat/test-*.R`.
22. **`examples/04/R/mod_async_task.R:45`** (S) — `|>` → `%>%`.
23. **RAG hygiene** (M) — add a `--reset`/`--replace-source` path to `ingest.py`; purge the 29 orphaned `shiny-developer-inventory.qmd` chunks (or restore the source); fix the `bs4Dash` `version: "of"` parser bug.

### P2 — Lower-priority enhancements
24. Add DBI/pool, reactlog/debugging, and sass/theming skills (content currently buried elsewhere).
25. Add a shinytest2/AppDriver E2E example and a pool/database example.
26. `sqlite-vec` index for vector search before the corpus passes ~10k chunks; stop double-printing the header breadcrumb; unify the agent-memory schema across the fleet.

---

## 7. Suggested First Session

If you want a fast, satisfying first pass that de-risks everything else: **do all of P0 (#1–6) in one sitting** — it's mostly small, fixes the fresh-machine reproducibility, makes the agents actually use the RAG/skills, and corrects the stale front door. Then pick up the pharma layer (P1) one item at a time, starting with #7 (ingest core shiny) and #8 (CDISC rule), since #11 (the keystone app) depends on both.
