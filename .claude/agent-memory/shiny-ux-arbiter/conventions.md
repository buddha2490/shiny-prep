---
name: ux-conventions
description: House CSS variables, theme defaults, and component preferences established across reference apps
type: convention
updated: 2026-06-19
---

## Theme baseline

All reference apps use `bslib::bs_theme(version = 5)` as the floor. Bootswatch presets are used
when the app has a strong visual identity requirement (e.g., shinychat example uses "flatly"
with overrides). Never use Bootstrap 3/4 components (shinydashboard) alongside bslib Bootstrap 5.

## Page structure

- Three-file layout: `global.R`, `ui.R`, `server.R`. Never `app.R`.
- Multi-tab apps use `page_navbar()` with `nav_panel()` items (never `tabPanel()`).
- `ui` variable assigned in `ui.R` — no `shinyApp()` call.
- All `library()` calls in `global.R` only.

## Component preferences

- Tables: DT for interactive, gt for publication-quality static output.
- Status indicators: `value_box()` with bsicons icons — never custom HTML badges unless the
  bslib primitive doesn't cover the use case (inline status pills are the exception).
- Fill behavior: chat windows and full-viewport content go inside `page_navbar(fillable = TRUE)`
  or inside a `card()` with `fill = TRUE`. Non-fill content (buttons, controls) use
  `layout_columns(fill = FALSE)`.

## CSS conventions

- All custom CSS lives in `www/custom.css`, referenced via `tags$link()` in `ui.R`.
- Never inline styles in `ui.R` unless it is a trivial single-property width/height.
- CSS custom properties (variables) defined on `:root` for palette consistency.
- Project CSS variable naming: `--sc-*` prefix for shinychat example app.

## Navbar patterns

- `nav_spacer()` before utility items to push them right.
- `nav_item()` wrapping `tags$a()` or `tags$span()` for non-panel items.
- Tab titles use sentence case, no all-caps.

## Status badge pattern (streaming/idle)

Streaming/Idle badges implemented as a `tags$span` with class `status-badge` plus
`status-streaming` or `status-idle` modifier. Positioned inside `card_header()` using
flexbox (`d-flex justify-content-between align-items-center`). Green pulsing dot for
streaming, muted grey for idle. See [[shinychat-app]] for full CSS.
