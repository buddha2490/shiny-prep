---
name: icon-package-conflicts
description: shiny::icon() uses Font Awesome names; bsicons::bs_icon() uses Bootstrap Icons names — they are not interchangeable
type: pitfall
updated: 2026-06-19
---

Two distinct icon systems are used in this project. Their names are **not interchangeable**.

| Function | Library | Example correct name |
|---|---|---|
| `shiny::icon("rotate-left")` | Font Awesome 6 | `rotate-left`, `trash`, `plus` |
| `bsicons::bs_icon("arrow-counterclockwise")` | Bootstrap Icons | `arrow-counterclockwise`, `chat-dots-fill`, `sliders` |

**Known trap:** `icon("arrow-counterclockwise")` (Font Awesome) produces a runtime warning "does not correspond to a known icon" and renders nothing. The name `arrow-counterclockwise` is valid in Bootstrap Icons only. The Font Awesome equivalent is `rotate-left`.

**Found and fixed in:** `examples/05. shinychat/R/mod_control_panel.R` line 116 (2026-06-19). Changed `icon("arrow-counterclockwise")` → `bsicons::bs_icon("arrow-counterclockwise")` to match the bsicons icon system used throughout the app.

**Enforcement rule:** in any app that loads `bsicons`, prefer `bsicons::bs_icon()` consistently. Use `shiny::icon()` only when Font Awesome is the explicit choice (e.g., `shinydashboard` which bundles FA). Mixed usage is an error surface.
