# Production Shiny App Frameworks: golem vs rhino vs leprechaun (and when raw Shiny beats them all)

> Part of the R package comparison series for pharma/clinical Shiny development.
> Accurate as of 2026. Critical guide — every strength is paired with its cost.

## 1. TL;DR

There is no universally correct framework — only the right amount of ceremony for the job. **Raw three-file Shiny (`global.R` / `ui.R` / `server.R`) is this project's default and beats all three frameworks for the majority of apps**: prototypes, single-purpose listings, exploratory dashboards, and anything a small team will ship in weeks. Reach for a framework only when an app is large enough, long-lived enough, or regulated enough that structure pays for the overhead it imposes. When you cross that line in a **validated/GxP clinical context, `golem` is the strongest choice** because its R-package foundation gives you `R CMD check`, `testthat`, roxygen documentation, and `DESCRIPTION`-pinned dependencies — the artifacts validation teams already understand. `rhino` offers the most disciplined structure but bets everything on `box::use()` and a Node-based asset pipeline that is hard to validate and hard to leave. `leprechaun` is the lightweight escape hatch: golem-like scaffolding that generates code you own with **no runtime framework dependency**.

| Framework | Underlying model | Best for | Avoid when | Key dependency / tooling | Learning curve |
|---|---|---|---|---|---|
| **Raw 3-file** | `global.R`/`ui.R`/`server.R`, sourced modules | Prototypes, small–mid apps, most clinical listings | App grows past ~15–20 modules; multi-team; needs formal validation artifacts | shiny + renv only | Low |
| **golem** | App *is* an R package; modules are functions; `run_app()` | Large, long-lived, validated/regulated apps; teams fluent in package dev | Quick prototypes; team unfamiliar with `R CMD check`/roxygen | golem (runtime dep), devtools, usethis, testthat | Medium–High |
| **rhino** | `box::use()` imports + strict `app/view` ⁄ `app/logic` split + Sass/JS build | Large apps by teams wanting enforced architecture + heavy custom CSS/JS | Validated pipelines (Node build step); R-package deliverables; small apps | rhino (runtime dep), box, config, Node/esbuild/sass | High |
| **leprechaun** | Generates owned source + light build step; golem-like layout | Mid apps wanting structure without a runtime framework dep | Teams wanting an active vendor + large ecosystem; pure prototypes | leprechaun (build-time only), esbuild/sass optional | Medium |

## 2. The contenders

**Raw three-file Shiny (the baseline to beat).** Plain `global.R`, `ui.R`, `server.R`, with modules sourced from `R/mod_*.R` and helpers from `R/utils_*.R`. Zero framework dependency, zero build step, instant to start, and universally understood by anyone who knows Shiny. The trade-off: structure is convention, not enforcement. Nothing stops a 4,000-line `server.R`, nothing generates tests or docs, and dependency tracking is whatever `renv` infers from `library()` calls. This is **the project's default**, and most apps never need more.

**golem (ThinkR / Posit ecosystem).** The mature, dominant production framework. A golem app *is* an R package: a `DESCRIPTION` declares dependencies, modules are package functions, `dev/` scripts drive scaffolding, `golem_utils_*` provide helpers, and the app launches via `run_app()` with `golem-config.yml` for environments. You get the entire R-package toolchain — `R CMD check`, roxygen, `testthat`, `usethis` — for free. The cost: every change runs through package machinery (document, load_all, check), and `golem` itself becomes a runtime dependency.

**rhino (Appsilon).** The most *opinionated* framework. It mandates `box::use()` for all imports (explicit, namespaced, no global sourcing), enforces a strict separation between `app/view` (UI/server modules) and `app/logic` (pure business functions), and ships a Node-based asset pipeline (esbuild for JS, Dart Sass for styles) plus baked-in linting (`lintr`, `styler`) and end-to-end testing via Cypress. It bundles `renv` + `box` + `config`. The structure is excellent; the cost is a steep learning curve, a Node toolchain in your build, and deep lock-in to `box::use()`.

**leprechaun (John Coene).** A deliberately lightweight golem alternative. It scaffolds a package-shaped app but **generates code you own outright** — the key philosophical difference: there is *no runtime `leprechaun` dependency* in the deployed app. Features (modules, JS/CSS bundling, inputs/outputs, alerts) are added à la carte by code generators, and an optional build step compiles assets. Much smaller footprint than golem, but a smaller ecosystem and a less active maintenance cadence.

## 3. Dimension-by-dimension comparison

### Project structure & scaffolding

```
# raw three-file               # golem (R package)            # rhino                          # leprechaun
my-app/                        my-app/                        my-app/                          my-app/
  global.R                       DESCRIPTION                    app/                             DESCRIPTION
  ui.R                           NAMESPACE                        main.R                         R/
  server.R                       R/                               logic/                           app_*.R (generated)
  R/                               app_ui.R                       view/                          inst/
    mod_*.R                        app_server.R                   static/                        srcjs/  scss/
    utils_*.R                      run_app.R                    config.yml                       dev/
  www/                             mod_*.R                      rhino.yml                        run.R
                                 inst/app/www/                  renv.lock                        renv.lock
                                 dev/ run_dev.R
```

- **Raw**: nothing to scaffold; you create three files. Fastest start, no guardrails.
- **golem**: `golem::create_golem()` then `dev/01_start.R` → `02_dev.R` → `03_deploy.R`. Heavy but well-trodden.
- **rhino**: `rhino::init()` produces a fixed tree you are not meant to deviate from. Most prescriptive.
- **leprechaun**: `leprechaun::scaffold()` then `leprechaun::add_*()` generators. Package-shaped like golem, but you own the output.

### Modularity model

| | Mechanism | Pros | Cons |
|---|---|---|---|
| Raw | `source()` + `NS()`/`moduleServer()` | Simple, no learning curve | Implicit globals; load order matters; no namespacing of *functions* |
| golem | Package functions (modules exported/internal) | `@importFrom`, `devtools::load_all()`, find-references all work | Must `document()`; package mental model required |
| rhino | `box::use(app/logic/foo)` | Explicit imports, true encapsulation, no accidental globals | `box` syntax unfamiliar; verbose; lock-in |
| leprechaun | Generated module functions in `R/` | Owned code, package-style references | Generators can drift from hand edits |

`box::use()` is rhino's defining bet. It is genuinely cleaner than `source()` — every dependency is explicit and namespaced — but it is a *non-standard import system* that most R developers and most validation reviewers have never seen, and you cannot easily peel it out later.

### Dependency management & runtime footprint

This is the sharpest practical divider.

- **Raw**: depends only on what you `library()`; `renv` infers it. Smallest possible footprint.
- **golem**: adds `golem` as a **runtime dependency** of the deployed app, plus the dev toolchain (build-time only). Modest but real.
- **rhino**: adds `rhino`, `box`, and `config` as **runtime dependencies**, *plus a Node.js toolchain at build time*. Heaviest footprint; the Node layer is a separate supply chain to manage and validate.
- **leprechaun**: **no runtime framework dependency** — generated code stands alone. This is its single biggest selling point for footprint-sensitive or validated deployments.

All four should pin everything via `renv.lock`, committed with the code (project rule). golem and leprechaun additionally encode runtime deps in `DESCRIPTION`, which enables `renv::snapshot(type = "explicit")` for a cleaner lockfile.

### Asset pipeline (Sass / JS)

- **Raw**: drop static `www/custom.css` and `www/script.js`; no compilation. For Sass, use `{sass}`/`bslib` at runtime. Simple, no build step.
- **golem**: `golem::add_css_file()` / `add_js_file()` place assets in `inst/app/www/`; optionally compile Sass yourself. Light.
- **rhino**: full Node pipeline — Dart Sass + esbuild bundle and minify `app/styles` and `app/js`. Powerful for heavy custom front-ends, but introduces `node_modules`, a build artifact, and a non-R supply chain that validated environments must account for.
- **leprechaun**: optional esbuild/sass build via `inst/` sources; you opt in only if you need it.

If your app has substantial bespoke JS/CSS, rhino's pipeline is best-in-class. If it doesn't — and most clinical listings/dashboards don't — that pipeline is pure overhead.

### Testing integration

- **Raw**: `tests/testthat/` for unit + `testServer()`, `tests/shinytest2/` for `AppDriver`. Works, but you wire it up by hand (project rule already mandates this layout).
- **golem**: best-in-class. Because it's a package, `testthat`, `usethis::use_test()`, coverage, and `R CMD check`'s test runner all work natively. Strongest fit for a documented, repeatable test record.
- **rhino**: `testthat` for R logic plus **Cypress** for E2E. Cypress is excellent but is *another Node tool* and a second testing paradigm for the team to learn and validate.
- **leprechaun**: `testthat` works (package-shaped); you assemble E2E (e.g. `shinytest2`) yourself.

### CI/CD & deployment

| Target | Raw | golem | rhino | leprechaun |
|---|---|---|---|---|
| Posit Connect | `rsconnect::deployApp()` | `golem::add_rconnect*` + manifest | supported; needs Node at build | manifest from package |
| Docker | hand-written | `golem::add_dockerfile()` | rhino docs provide Dockerfile (multi-stage w/ Node) | hand-written / light |
| shinyapps.io | `deployApp()` | package deploy | supported | package deploy |

golem has the most polished deployment helpers (Dockerfile + Connect manifest generators). rhino deploys fine but every image must build the Node assets, adding time and a second toolchain to the deployment supply chain. Raw and leprechaun produce the leanest images.

### Learning curve & team onboarding

- **Raw**: anyone who knows Shiny is productive immediately. Lowest.
- **golem**: requires R-package fluency (`DESCRIPTION`, roxygen, `load_all`, `document`, `check`). Medium–high, but the skills transfer to all R development.
- **rhino**: highest. `box::use()` + view/logic discipline + Node pipeline + Cypress is a lot of *rhino-specific and non-R* knowledge that doesn't transfer elsewhere.
- **leprechaun**: medium. Package-shaped but lighter; generators ease entry, though you must understand the generated code you now own.

### Opinionatedness vs flexibility

Raw (most flexible, least guidance) → leprechaun → golem → **rhino (most opinionated, least flexible)**. More opinion means more consistency across a large team and less bikeshedding — but also more friction when your app doesn't fit the mold. rhino actively resists deviation; that's a feature for big teams and a liability for everyone else.

### Ecosystem maturity & maintenance

- **golem**: most mature, widest adoption, strong books/tutorials, active maintenance, large community. Safest long-term bet.
- **rhino**: actively developed by Appsilon, good docs, growing adoption — but a single-vendor framework with a narrower base.
- **leprechaun**: stable and clever, but a smaller community and a less active cadence; treat as low-churn rather than fast-moving.
- **Raw**: "maintained" by Shiny itself — the most durable foundation of all.

## 4. Decision guide

**Raw three-file Shiny**
- *Use when*: prototyping; the app is small-to-mid (a handful of modules); a small team; short-to-medium lifespan; no formal validation deliverable required. **This is the default — start here.**
- *Don't use when*: the app has grown past ~15–20 modules with tangled load-order dependencies; multiple teams contribute; or you need package-grade validation artifacts (`R CMD check`, documented exports).

**golem**
- *Use when*: the app is large, long-lived, and/or must be **formally validated**; the team is comfortable with R-package development; you want the full `testthat` + roxygen + `R CMD check` toolchain as your evidence trail.
- *Don't use when*: you're prototyping or building something small (the package ceremony will outweigh the app); or the team has no appetite for `document()`/`load_all()`/`check()` rhythms.

**rhino**
- *Use when*: a large app, built by a team that *wants* enforced architecture, with substantial custom JS/CSS that benefits from a real build pipeline, and where a Node toolchain is acceptable.
- *Don't use when*: you need an R-package deliverable; you're in a strictly validated pipeline where a Node build step is hard to qualify; the app is small; or you want to avoid `box::use()` lock-in.

**leprechaun**
- *Use when*: you want golem-like structure and testing without a runtime framework dependency or heavy ceremony — a mid-size app where footprint and code ownership matter.
- *Don't use when*: you need a large active ecosystem and vendor support; or you're just prototyping (raw is lighter still).

## 5. Pharma / clinical context

In a GxP/validated environment the deliverable is not just a working app — it's **evidence the app does what it's specified to do, reproducibly, with a documented change history**. That reframes the whole comparison.

- **Validation & reproducibility — golem's home turf.** A golem app is an R package, so the validation team gets familiar, auditable artifacts: a `DESCRIPTION` enumerating dependencies, roxygen-documented functions, a `testthat` suite runnable via `R CMD check`, and `NAMESPACE`-controlled exports. These map cleanly onto IQ/OQ/PQ-style expectations and onto the kind of documented unit/integration testing this project's testing rules already require. **For a validated clinical app, golem is the recommended framework.**
- **Reproducible environment.** Every option must commit `renv.lock` alongside the code (project rule). golem and leprechaun let you drive that lockfile from `DESCRIPTION` (`renv::snapshot(type = "explicit")`), keeping it tight; raw uses implicit snapshotting; rhino pins R deps via `renv` but its **Node/esbuild/sass supply chain sits outside `renv`** and must be qualified separately — a real burden in a regulated build.
- **Regulated deployment to Posit Connect.** All four deploy to Connect, the common enterprise pharma target. golem's manifest/Dockerfile generators reduce hand-built, error-prone deployment steps — fewer manual steps means a shorter validation surface. rhino deploys fine but each build must compile Node assets, adding a step to qualify.
- **Team size & app longevity.** Clinical apps often outlive their original authors (studies run for years; submission tools get revisited at filing). Structure that survives author turnover matters. golem's package conventions are the most transferable and the best documented; rhino's discipline also survives turnover but only if the *whole* team learns rhino. Raw apps risk decaying into an unmaintainable `server.R` over a multi-year life.
- **The honest caveat.** Most clinical *deliverables* are not enterprise platforms — they're a patient listing, a safety dashboard, a single review tool. For those, a clean raw three-file app with a disciplined `tests/` directory and a committed `renv.lock` is fully validatable and far cheaper to build and review. **Don't adopt golem to validate a 3-module listing; adopt it when the app is genuinely a long-lived platform.**

**Verdict for GxP:** golem when it's a real platform; raw three-file (with rigorous tests + renv) when it's a focused tool. Avoid rhino in strictly validated pipelines unless the Node toolchain is already qualified in your organization.

## 6. Interop & migration notes

- **Raw → golem (package-ify).** The most common and lowest-friction migration. Sourced `mod_*.R` functions become package functions, `library()` calls move to `DESCRIPTION`, and `app_ui`/`app_server`/`run_app` wrap your existing `ui`/`server`. Module *internals* often survive untouched. Do this when an app outgrows raw — not preemptively.
- **golem ↔ leprechaun similarity.** Both are package-shaped with `mod_*` functions, so moving between them is largely about scaffolding/build helpers, not rewriting reactive logic. Going golem → leprechaun mainly means dropping the `golem` runtime dependency and replacing its helpers; the reverse adds them back.
- **rhino's `box::use()` lock-in.** This is the costliest to enter *and* exit. Every file uses `box::use()` imports and the view/logic split; unwinding it means rewriting the import system across the codebase and dismantling the Node pipeline. Choose rhino deliberately and for the long haul, or not at all.
- **Cost of switching mid-project.** Switching frameworks mid-build is expensive in all directions and should be rare. The cheap, sanctioned path is **raw → golem when (and only when) the app earns it**. Treat rhino and the framework choice generally as an up-front decision, not a mid-stream pivot.

## 7. Bottom line

Recommendation hierarchy, in order of how often it should apply:

1. **Raw three-file Shiny — the default.** Use it for prototypes, small-to-mid apps, and most focused clinical tools (listings, single dashboards). Keep `tests/testthat` + `tests/shinytest2` disciplined and commit `renv.lock`. Most apps should never leave this tier.
2. **golem — when the app becomes a platform or must be formally validated.** Large, long-lived, multi-author, or GxP apps benefit from the R-package toolchain (`R CMD check`, roxygen, `testthat`, `DESCRIPTION`-pinned deps). This is the project's recommended framework once raw stops scaling.
3. **leprechaun — when you want golem-like structure without a runtime framework dependency.** A pragmatic middle tier for footprint-sensitive mid-size apps where you want to own the generated code. Smaller ecosystem is the trade-off.
4. **rhino — only for large apps by teams that want enforced architecture and have heavy custom JS/CSS, where a Node build step is acceptable.** Best-in-class structure and asset pipeline, but the steepest curve, the heaviest footprint, `box::use()` lock-in, and the poorest fit for strictly validated, R-package-deliverable pharma workflows.

When in doubt, **start raw and earn your way up** — adding a framework is reversible-in-theory but expensive-in-practice, while the cost of *not* having added one to a small app is essentially zero.
