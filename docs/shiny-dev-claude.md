# Shiny Developer Claude Setup — Remaining To-Do

**Original audit:** 2026-06-17 · **This revision:** 2026-06-20 (quick wins done)
**Scope:** Residual backlog only. The original full audit has been pruned —
everything already built has been removed. For the current readiness review and
the actively-tracked numbered backlog, see `docs/shiny-dev-claude-v2.md`.

---

## What's already done (no longer tracked here)

The bulk of the 2026-06-17 audit is complete. Removed from this doc because they
shipped:

- **r-code / testing conflict** — resolved. `r-code` now uses `tests/testthat/`,
  factory functions, conditional `source()`, and no `rm(list = ls())`.
- **Agent rule duplication** — resolved. All 6 agents now reference
  `.claude/rules/` with a brief statement instead of inlining the rules.
- **CLAUDE.md** — created (project purpose, pipeline, directories, conventions).
- **namespace-conflicts.md rule** — created (fixed the broken `r-style` reference).
- **Enforced pipeline** — documented in CLAUDE.md (planner → UX → architect →
  tester → reviewer, plus on-demand shiny-debugger).
- **RAG populated** — ~34 sources / ~5,100 chunks: core shiny, bslib/bs4Dash/
  shinydashboard, plotly, DT/gt/reactable, ggplot2, teal/admiral/rtables, async
  stack, log4r, renv, R6, shinytest2, ellmer/shinychat, the package-comparison
  series, and the CDISC SDTM/ADaM IGs.
- **New skills** — bslib-layout, shiny-download-upload, plotly-shiny,
  shiny-bookmarking, shinydashboard-layout, shiny-error-handling,
  cdisc-data-validation (8 skills added; now 23 total).
- **shiny-debugger agent** — added (now 6 agents).
- **New rules** — error-handling, logging, cdisc-conventions, pharmaRTF-patterns.
- **Examples** — modules (`03.`), plotly (`02.`), error-handling (`04.`),
  shinychat (`05.`) all built, on top of the original async set (`01.`).
- **renv** — initialized; lockfile committed; `.gitignore` hygiene done.

### Done 2026-06-20 (quick wins)

- **Agent model upgrade** — `shiny-feature-planner`, `shiny-r-architect`, and
  `r-code-reviewer` set to `model: opus`; the other three stay `sonnet`.
- **`r-code` trigger reworded** — now framed as the always-on workflow/structure
  backbone that defers Shiny domain patterns (modules, reactives, tables, layout)
  to the dedicated skills, which take precedence. Body updated to match.
- **`git-conventions.md` rule created** — full PR workflow + Conventional Commits
  + atomic commits (code+tests+`renv.lock`); Claude may auto-commit verified
  logical units but never auto-pushes. Cross-links renv/logging/Acceptance Gate.

---

## Remaining To-Do

### A. Optimization / cleanup

| # | Action | Status | Impact | Effort |
|---|--------|--------|--------|--------|
| 2 | **Split `shiny-performance` skill** — was 683 lines, loaded whole on any perf question. Split into `shiny-profiling` (profvis/reactlog/tictoc/loadtest), `shiny-caching` (bindCache/memoise/cachem), `shiny-async` (ExtendedTask/future). Parent slimmed to 404 lines, kept as the perf-review entry point (workflow, ROI order, reactive-graph + data-layer + UI/memory optimization, anti-pattern quick reference, checklist) with a deep-dive map to the three children. Agent skill-lists updated. | ✅ Done 2026-06-20 | Less context waste | Low |
| 3 | **Trim `raw-shiny-app` skill** — was 274 lines; re-stated the three-file layout, the `NS()`/`moduleServer()` pattern, package loading, and testing already owned by `shiny-app-structure`, `shiny-modules`, `r-style`, and `shiny-testing`. Trimmed to 164 lines: those sections replaced by a pointer table; kept only the raw-specific material (when to use vs. a framework, `R/` auto-sourcing, `www/`, config-without-framework, startup preflight, `rsconnect::deployApp()`, when to graduate). | ✅ Done 2026-06-20 | Less context waste | Low |

### C. Automation

| # | Action | Status | Impact | Effort |
|---|--------|--------|--------|--------|
| 6 | **Add a hooks configuration** — committed hook scripts in `.claude/hooks/`, activated per-machine via the gitignored `.claude/settings.local.json` (all inform mode; flip the final `jq` line to `decision:"block"` to enforce). (C) `test-reminder.sh` — PostToolUse on `R/mod_*`/`utils_*`/`fct_*` edits, feeds back the conventional testthat path + a full-suite reminder. (B) `renv-status.sh` — Stop hook, runs `renv::status()` (guarded: only when an `.R` file is newer than `renv.lock`) and nudges to `renv::snapshot()` on drift. (A) lint — `lint-record.sh` (PostToolUse) queues edited `.R` files; `lint-r.sh` (Stop) lints exactly that per-turn set in one R process and reports per the repo `.lintr`. Config is a curated, rule-aligned linter set; `object_name_linter` allows snake_case **and** UPPERCASE so CDISC vars (USUBJID/AVAL/SAFFL) pass; `lintr` pinned in `renv.lock` via the `tools/dev_dependencies.R` stub (keeps `renv::status()` clean). | ✅ Done 2026-06-20 | Automated checks | Medium |

### D. Examples (reference code + RAG-ingestible)

| # | Action | Status | Impact | Effort |
|---|--------|--------|--------|--------|
| 7 | **Table examples** — DT (proxy + editable), reactable (custom cell renderers), gt (publication: spanners/footnotes), rhandsontable (editable w/ save/reset). The table *skills* exist; worked apps do not. | Not started | Reference code | Medium |
| 8 | **Layout examples** — bslib `page_sidebar` w/ cards, bslib `page_navbar`, bslib dashboard w/ value boxes, classic shinydashboard. | Not started | Reference code | Medium |
| 9 | **Pharma keystone clinical app** — the v2 backlog #11 item. A realistic three-file app exercising patient listing, AE summary, lab shift plot, KM plot, and a forest plot on synthetic CDISC data. Doubles as the source for the pharma-pattern RAG doc (#12 below). | Not started | Domain reference | High |

### E. RAG content (remaining sources)

| # | Action | Status | Impact | Effort |
|---|--------|--------|--------|--------|
| 10 | **`deployment.md`** — Posit Connect checklist, Docker patterns, GitHub Actions CI for Shiny, env-var management, `renv::restore()` in CI. | Not started | Production readiness | Medium |
| 11 | **`shiny-errors.md`** — common error messages and their causes, reactive debugging techniques, browser-console debugging, R session-crash diagnosis. (Complements the shiny-debugger agent.) | Not started | Faster debugging | Medium |
| 12 | **`pharma-shiny-patterns.md`** — clinical module patterns (patient profile, AE listing, lab shift, KM, forest, subgroup cascade). Best derived from the keystone app (#9). | Not started | Pharma knowledge | Medium |
| 13 | **`safetyGraphics`** — the one pharma-stack package still un-ingested (teal / admiral / rtables are already in). | Not started | Pharma stack completeness | Low |

---

## Suggested order

1. ~~**Quick wins:** model config, git rule, r-code trigger.~~ — done 2026-06-20.
2. ~~**Context hygiene:** #2 and #3 (split/trim the oversized skills).~~ — done 2026-06-20.
3. ~~**Automation:** #6 (hooks) — pays off on every subsequent edit.~~ — done 2026-06-20.
4. **The big build:** #9 (keystone app), which then feeds #12, alongside #7/#8.
5. **RAG fill-in:** #10, #11, #13 as time allows.
