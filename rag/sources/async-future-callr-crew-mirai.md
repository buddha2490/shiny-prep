# Async / Parallel / Distributed Backends for R & Shiny: future vs callr vs crew vs mirai

*A critical comparison guide — part of the R package comparison series for clinical/pharma Shiny development.*
*Accurate as of mid-2026.*

---

## 1. TL;DR

These five tools are **not direct competitors** — they live at different layers of the same stack, and the most common mistake is comparing them as if you pick exactly one. **promises** is the Shiny-facing *glue* (`then()`, `catch()`, `future_promise()`); **future** and **mirai** are *evaluation backends* that run R code somewhere other than the main session; **callr** is a low-level *process tool* that runs R in one fresh subprocess; **crew** is a higher-level *worker-pool controller* built on top of mirai for scale. As of 2026 the ecosystem has clearly shifted: **mirai** is the recommended high-performance backend and pairs naturally with Shiny's `ExtendedTask`; **future** remains the mature, general-purpose, backend-agnostic standard; **crew** is the engine behind modern `targets` and the right tool only when you genuinely need many auto-scaling or HPC workers; **callr** is the stable, foundational one-shot subprocess primitive that quietly sits under much of the others. **Default recommendation for a clinical Shiny app: promises + mirai via `ExtendedTask`.**

| Tool | Layer | Best for | Avoid when | Shiny fit |
|------|-------|----------|------------|-----------|
| **promises** | Promise glue | Wiring any async result back into Shiny outputs/reactives without blocking | You have no async backend behind it (it computes nothing itself) | Essential — the only sanctioned bridge into the reactive graph |
| **future** | Backend | General-purpose async, mature code, backend-agnostic libraries | You want lowest overhead and explicit dependency control on a hot path | Good (via `future_promise()` + `ExtendedTask`) |
| **callr** | Process tool | One-shot "run this R in a clean process" (builds, isolation, crash containment) | You need a persistent pool, low per-task overhead, or many tasks | Indirect — usually through future/ExtendedTask, not raw |
| **mirai** | Backend | High-throughput, low-overhead async; persistent daemons; clinical dashboards | A single trivial subprocess where setup isn't worth it | Excellent — first-class `as.promise()` + `ExtendedTask` |
| **crew** | Worker pool | Many tasks, auto-scaling, HPC/cluster, targets pipelines | A handful of tasks on one machine (overkill, operational weight) | Workable but heavier than raw mirai for typical apps |

---

## 2. The contenders

**promises** — The async *contract*, not an engine. A promise is a placeholder for a value that will arrive later; you attach continuations with `then(onFulfilled, onRejected)`, `catch()`, and `finally()`, all of which are **non-blocking** and return immediately. promises computes nothing on its own — it wraps the result of a backend (a `future`, a `mirai`) and lets Shiny resume work when that result resolves. It also provides combinators (`promise_all()`, `promise_race()`) and the `future_promise()` helper. In Shiny this is the only correct way to feed an async result back into an output or reactive without freezing the event loop.

**future** — The futureverse standard. `future({ ... })` captures an expression and evaluates it according to a `plan()` you set globally: `sequential`, `multisession` (background R sessions), `multicore` (forks, not on Windows), `cluster`, or a backend package's plan. Its signature feature — automatically detecting and shipping global variables to the worker — is also its signature footgun (see §3). Mature, enormous ecosystem (`furrr`, `future.apply`, `doFuture`), and backend-agnostic by design.

**callr** — The "run R in a fresh process" primitive. `callr::r()` runs a function in a brand-new R subprocess and returns the result; `r_bg()` runs it in the background returning a process handle. It is deliberately low-level and *one-shot* — no pool, no scheduler, fresh process per call. It is foundational: `future.callr`, parts of testing/build tooling, and many packages spawn isolated R via callr. Rock-solid for isolation and crash containment, but the per-call process spawn cost is real.

**mirai** — Minimalist, fast async built on NNG/nanonext. `mirai({ ... })` returns immediately with a `mirai` object resolving at `$data`; `daemons(n)` sets persistent background processes so you pay process startup once, not per task. `mirai_map()` does parallel map with partial-failure recovery; `dispatcher = TRUE` (default) gives FIFO scheduling, `stop_mirai()` cancellation, `.timeout`, and memory backpressure. Dependencies are passed **explicitly** via `...`/`.args` (no global-scanning magic). First-class Shiny integration: `as.promise.mirai` and `try_mirai()` for event-loop contexts. This is the recommended modern backend.

**crew** — A scalable controller/worker framework built **on top of mirai**. You create a controller (`crew_controller_local(workers = N)`), `push()` tasks, and `pop()`/collect results; crew handles **auto-scaling** (launch workers on demand, retire idle ones), retries, and worker lifecycle. `crew.cluster` extends it to SLURM/SGE/PBS/LSF HPC schedulers. crew is the execution engine behind modern `targets`. It is the heaviest option operationally and is meant for *fleets* of workers, not a couple of background tasks.

---

## 3. Dimension-by-dimension comparison

### Programming model & API ergonomics

| | Model | Ergonomics |
|--|-------|-----------|
| promises | Continuation-passing (`then`/`catch`) | Clean for one hop; deep chains get nested. `%...>%` pipe sugar exists. |
| future | "Implicit future" — write near-normal code, globals auto-captured | Lowest friction to *write*; highest friction to *debug* when capture goes wrong |
| callr | Imperative — call a function, get a result/handle | Simple and explicit, but you build polling/lifecycle yourself |
| mirai | Explicit expression + explicit args | Slightly more verbose; far fewer surprises. `mirai_map()` is excellent for fan-out |
| crew | Controller object with `push`/`pop`/`collect` | Stateful, more ceremony; pays off only at scale |

future optimizes for *looking like synchronous code*. mirai optimizes for *being explicit about what crosses the process boundary*. In a clinical codebase that has to be auditable, mirai's explicitness is usually the right trade.

### Performance & overhead

- **callr** spawns a fresh R process *every call* — hundreds of milliseconds to seconds of overhead. Fine once; ruinous in a loop.
- **future** with `plan(multisession)` keeps a small reusable pool, but serialization of auto-captured globals can be surprisingly heavy (it may ship far more than you intended).
- **mirai** is the throughput leader: NNG/nanonext transport, persistent `daemons()` so startup is amortized, and minimal serialization because you pass *only* what you name. For many small tasks the gap over future is substantial.
- **crew** adds controller/scheduling overhead per task but is built to keep many workers saturated; its overhead is a rounding error when each task is genuinely long.

### Scalability (single machine → many cores → HPC/cluster)

| | One core | Many cores (1 machine) | Multi-machine / HPC |
|--|----------|------------------------|---------------------|
| callr | one process | DIY (manage handles) | No |
| future | `sequential` | `multisession`/`multicore` | `cluster`, `future.batchtools` |
| mirai | `daemons(0)` (inline) | `daemons(n)` | `daemons(url=...)`, `ssh_config()`/`cluster_config()`, TLS |
| crew | trivial | `crew_controller_local()` auto-scaling | `crew.cluster` (SLURM/SGE/PBS/LSF) |

mirai scales smoothly from local daemons to TCP/TLS-distributed daemons with the *same* API. crew sits one level higher: when you need elastic worker fleets, retries, and HPC submission without hand-rolling it, crew (on mirai) is the answer.

### Shiny integration

The non-negotiable rule: **never block the Shiny event loop.** A long synchronous computation in `server` freezes *every* connected user's session, not just the one who triggered it.

- **promises** is the bridge. Return a promise from a `render*` or use it inside an `observe`, and Shiny resumes when it resolves.
- **`ExtendedTask`** (Shiny ≥ 1.8) is the modern pattern: it owns an async task's lifecycle, exposes `$status()`/`$result()`, and pairs with `bslib::input_task_button()` + `bind_task_button()` so the button reflects busy/ready state. `ExtendedTask$new()` takes a function that returns a **promise** — so it sits on top of any backend.
- **mirai** plugs in via `as.promise()` — and crucially `try_mirai()` returns `NULL` immediately instead of blocking when the dispatcher's memory queue is full, which is exactly what an event-loop context needs.
- **future** plugs in via `future_promise()`, which (unlike a bare `future()` in a promise) avoids the trap where all worker slots get reserved by one session before any work runs (see the `future_promise_queue` behavior — `future_promise()` schedules work only when a worker is actually free).
- **Per-session vs cross-session workers:** a worker pool is a *shared, app-level* resource. Set up `daemons()`/`plan()`/a crew controller **once in `global.R`**, not per session — otherwise N users spawn N pools and you exhaust the machine.

```r
# ExtendedTask + mirai — the recommended clinical-dashboard pattern.
# global.R:
library(mirai)
daemons(4)                     # persistent pool, set ONCE, app-wide

# server.R (inside server function):
km_task <- ExtendedTask$new(function(adtte) {
  # Dependencies passed EXPLICITLY via `...` — no global capture.
  mirai(
    {
      fit <- survival::survfit(survival::Surv(AVAL, 1 - CNSR) ~ TRT01P, data = adtte)
      broom::tidy(fit)
    },
    adtte = adtte
  )                            # a mirai is coercible to a promise -> ExtendedTask accepts it
}) %>%
  bind_task_button("run_km")

observeEvent(input$run_km, {
  km_task$invoke(filtered_adtte())   # snapshot reactive value, pass it in
})

output$km_table <- renderTable({
  km_task$result()             # resolves when the daemon finishes; UI stays live
})
```

```r
# future_promise — general async without ExtendedTask.
# global.R:
library(future); library(promises)
plan(multisession, workers = 4)

# server.R:
output$summary <- renderText({
  future_promise({
    Sys.sleep(3); paste("rows:", nrow(big_adam_join))
  }, seed = TRUE) %...>% identity()
})
```

### Error handling & cancellation

- **promises**: errors propagate down the chain to the nearest `onRejected`/`catch()`. Watch the classic trap — a `catch()` that *returns* instead of re-throwing turns failure into success; put error handling last.
- **future**: errors surface when the future is resolved (or via the promise's rejection path); cancellation of an in-flight future is not generally supported.
- **callr**: subprocess errors are re-raised in the caller; you kill via the process handle.
- **mirai**: best-in-class introspection. A failed task resolves to a `miraiError` (class `errorValue`) carrying `$stack.trace` and `$condition.class`; test with `is_mirai_error()` / `is_error_value()`. `stop_mirai()` cancels (requires dispatcher), `.timeout` enforces a deadline, and `mirai_map()` returns errors per-element so you can **re-run only the failures** — invaluable for a long batch of patient-level computations where one subject's data is malformed.
- **crew**: built-in retries and per-task error capture at the controller level.

### Dependency / variable passing — the #1 source of async bugs

This deserves its own callout.

- **future's globals problem:** `future()` *guesses* which variables your expression needs and ships them automatically. When it guesses wrong you get either a cryptic "object not found" on the worker, or — worse — it silently serializes a giant object (a whole ADaM data frame, a DB connection, an entire environment) you never meant to send, tanking performance. The fix is manual (`future(..., globals = list(...))`), at which point you've lost the "looks synchronous" benefit anyway.
- **mirai's explicit model:** the expression runs in a **clean environment** — it sees *nothing* except what you pass. Objects in `...` land in the worker's global env (use this for helper functions / values that other functions look up); objects in `.args` stay local to the evaluation. Packages must be namespaced (`survival::survfit()`) or loaded inside the expression, or pre-loaded on all daemons with `everywhere()`. More typing, zero guessing — and in a validated clinical context, *knowing exactly what crossed the boundary* is a feature, not a chore.

### Maturity & momentum

future is the most mature and most depended-upon; it isn't going anywhere. **mirai** has the momentum: it's now R-core-adjacent infrastructure (it backs the modern `parallel` socket cluster work), the recommended high-performance backend, and the foundation under crew and therefore targets. callr is stable and foundational — boring in the best way. crew is actively developed and the standard for scalable targets/HPC pipelines.

---

## 4. Decision guide

**promises**
- *Use when:* you need to deliver any async result into a Shiny output/reactive. Always, as the glue.
- *Don't use when:* you mistake it for a compute engine — it needs a backend behind it.

**future**
- *Use when:* you want mature, backend-agnostic async; you depend on `furrr`/`future.apply`/`doFuture`; or you're maintaining existing future-based code.
- *Don't use when:* you're on a hot path where the globals-capture overhead or ambiguity bites, or you want the lowest-overhead modern backend — reach for mirai.

**callr**
- *Use when:* you need *one* clean R subprocess for isolation or crash containment (a build step, a risky parse, running R inside a non-reactive script).
- *Don't use when:* you have many tasks or need a persistent pool — per-call process spawn cost will dominate. Use mirai daemons instead.

**mirai**
- *Use when:* you want fast, low-overhead async with persistent daemons; a responsive Shiny dashboard via `ExtendedTask`; explicit, auditable dependency passing; per-task cancellation/timeouts; or smooth local→distributed scaling.
- *Don't use when:* a single trivial one-shot subprocess where setting up daemons isn't worth it (callr is simpler), or you specifically need a backend-agnostic API a downstream package demands (future).

**crew**
- *Use when:* you need many auto-scaling workers, retries, HPC/cluster submission (`crew.cluster`), or you're driving a `targets` pipeline.
- *Don't use when:* a typical Shiny app with a handful of concurrent long tasks — raw mirai daemons are lighter and simpler; crew's controller machinery is overkill.

---

## 5. Pharma / clinical context

Clinical Shiny apps routinely trigger computations that are *slow but not infinite*: Kaplan-Meier / Cox survival fits, bootstrapped confidence intervals, permutation tests, large ADaM joins, and on-the-fly subgroup recomputation. Done synchronously, each one freezes the dashboard for **every reviewer connected to the app** — unacceptable when a safety team is reviewing listings concurrently.

**The default clinical pattern:** `ExtendedTask` + mirai daemons. The reviewer clicks "Run survival analysis," the button (via `input_task_button` + `bind_task_button`) shows busy, the computation runs on a daemon, and the rest of the dashboard — filters, listings, other tabs — stays fully interactive. When the fit completes, the promise resolves and the KM table/plot renders. No other user's session is touched.

**Why mirai's explicit args matter here specifically:** in a validated environment you must be able to state precisely what data and code executed in the worker. mirai's clean-environment model means the answer is exactly the named `...`/`.args` — no accidentally-serialized global, no surprise dependency. That auditability beats future's "ship whatever I guessed" model for regulatory traceability.

**Reproducibility:** seed control belongs in the backend. `daemons(seed = ...)` gives mirai per-task L'Ecuyer-CMRG streams that are stable regardless of daemon count; `future(..., seed = TRUE)` does the equivalent. Either way, set the seed explicitly so a bootstrap result is reproducible across runs and across worker counts.

**Partial-failure recovery:** for a batch over many subjects/sites (e.g., `mirai_map()` over a list of analysis specs), mirai returns errors per element so you re-run only the malformed ones — rather than losing the whole batch to one bad record.

**When distributed/HPC (crew) is justified vs overkill:** A single dashboard serving a review team almost never needs crew — a handful of local mirai daemons handles concurrent long tasks fine. crew (and `crew.cluster`) earns its keep when the *work itself* is large-scale: simulation studies, sensitivity analyses across hundreds of parameterizations, or a `targets` pipeline regenerating TLFs across an entire study on a SLURM cluster. Putting a SLURM controller behind an interactive dashboard that runs three KM fits is operational complexity with no payoff — and a validation burden you don't want.

---

## 6. Interop & migration notes

These tools **compose**; they are partly complementary, not purely competing. The mental model:

```
            ┌─────────────────────────────────────────────┐
  Shiny ◄── │  promises  (then / catch / future_promise)   │   ← the glue, on top of everything
            └───────────────┬──────────────────┬───────────┘
                            │                  │
                    ┌───────▼──────┐    ┌──────▼───────┐
                    │   future     │    │    mirai     │       ← evaluation backends
                    └───────┬──────┘    └──────┬───────┘
                            │                  │
                    ┌───────▼──────┐    ┌──────▼───────┐
                    │ future.callr │    │    crew      │       ← built on top of the backend
                    │   (→ callr)  │    │ (→ mirai)    │
                    └──────────────┘    └──────────────┘
```

- **promises sits on top of all of them.** `promises::as.promise()` is an S3 generic; mirai ships `as.promise.mirai` / `as.promise.mirai_map`, and promises itself converts `future::Future` objects. So whatever backend you choose, the Shiny-facing code is the same `then()`/`ExtendedTask` shape.
- **future → mirai migration.** future can *use* mirai as its backend via `plan(mirai_multisession)` (from the `mirai`/futureverse glue), letting existing `future()`/`furrr` code run on mirai's faster transport with no rewrite. Teams migrate for the lower overhead, the explicit dependency model, and per-task cancellation/timeout. A full rewrite to native `mirai()` is only worth it on hot paths or where you want the explicit-args auditability.
- **crew is built on mirai.** Choosing crew means you're already on mirai underneath; it adds the controller, auto-scaling, retries, and HPC launchers. Modern `targets` uses crew as its parallel engine.
- **callr shows up inside the others.** `future.callr` is a future backend that spawns callr processes; build/test tooling uses callr for isolation. You rarely call callr directly in a Shiny app, but it's quietly load-bearing.

The practical upshot: pick your **backend** (mirai by default, future if mature/agnostic code demands it), pick your **scale tool only if you need one** (crew), and let **promises + ExtendedTask** be the constant Shiny interface across all of them.

---

## 7. Bottom line

**Recommendation hierarchy for this environment:**

1. **Default for Shiny:** `promises` + **mirai** via **`ExtendedTask`** and `input_task_button`. Set `daemons()` once in `global.R`. Fast, explicit, auditable, keeps every reviewer's session responsive. This is the modern, recommended path.
2. **General async / existing code:** **future** with `future_promise()` — mature, backend-agnostic, the right call when you depend on the futureverse or are maintaining future-based code. Consider `plan(mirai_multisession)` to get mirai's speed without a rewrite.
3. **Scale / HPC / pipelines:** **crew** (on mirai) when you genuinely need auto-scaling worker fleets or cluster submission — and `crew.cluster` for SLURM/SGE/PBS/LSF. Don't reach for it for a few interactive tasks.
4. **One-shot subprocess:** **callr** when you just need a single clean R process for isolation or crash containment. Not for pools, not for many tasks.

And the framing to keep: **promises is always present** (the glue), you choose **one backend** (mirai or future), and you add a **scale tool only when the workload demands it** (crew). They are layers, not rivals.

---

### See also

Working, runnable reference apps for every pattern above live in this repo under `examples/01. async/`:

- `01_promises/` — bare `promises` (`then`/`catch`) wiring
- `02_future_promise/` — `future_promise()` without slot-starvation
- `03_future_callr/` — future on a callr backend
- `04_callr/` — raw one-shot background R process
- `05_extended_task/` — `ExtendedTask` + `input_task_button`
- `06_crew/` — crew controller / worker pool
- `07_mirai/` — `mirai()` + `daemons()` + promise integration

*(Note: those example apps use a single-file `app.R` layout for portability; new project apps in this repo follow the three-file `global.R` / `ui.R` / `server.R` convention.)*
