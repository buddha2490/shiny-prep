# CSS Styling

How custom CSS is written, organized, and loaded in Shiny apps in this project. For layout decisions (which bslib page type, cards vs. columns), see the `bslib-layout` skill. For theming (`bs_theme()`), see the UX arbiter's conventions.

## Rule 1 — External file by default

All custom CSS lives in `www/custom.css`, loaded in `ui.R` via `tags$link()`:

```r
# ui.R
ui <- page_navbar(
  ...
  header = tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "custom.css")
  ),
  ...
)
```

One CSS file per app. Do not scatter styles across multiple `.css` files unless the app is large enough to justify it (5+ modules with distinct visual treatments). Never use `includeCSS()` — it inlines the CSS into the HTML `<head>`, which defeats browser caching and clutters View Source.

## Rule 2 — When inline styles are acceptable

Inline `style=` attributes are allowed in **two** situations:

1. **Dynamic/computed values** — the style depends on R data and cannot be expressed in a static file (e.g., a percent-bar width, a conditional color in a cell renderer):

```r
htmltools::div(style = sprintf("width:%.0f%%;background:%s;", 100 * pct, fill))
```

2. **Trivial one-property overrides** — a single `width`, `height`, or `max-height` on a specific element where creating a class would be overhead for no reuse.

Everything else belongs in `www/custom.css`. If you find yourself writing more than one CSS property inline, move it to the stylesheet and use a class.

## Rule 3 — Bootstrap utility classes before custom CSS

bslib ships Bootstrap 5. Before writing a custom CSS rule, check whether a Bootstrap utility class already does the job. Common ones:

| Need | Utility class |
|------|--------------|
| Spacing (margin/padding) | `m-*`, `p-*`, `mt-3`, `px-2`, `gap-2` |
| Flexbox layout | `d-flex`, `justify-content-between`, `align-items-center` |
| Text alignment/size | `text-start`, `text-center`, `text-end`, `small`, `fs-5` |
| Colors | `text-primary`, `text-muted`, `bg-light`, `bg-success` |
| Borders/rounding | `border`, `rounded`, `shadow-sm` |
| Visibility/display | `d-none`, `d-md-block`, `visually-hidden` |

Apply them with `class = "..."` in R:

```r
tags$div(
  class = "d-flex justify-content-between align-items-center mt-3",
  tags$span(class = "text-muted small", "Last updated: ..."),
  actionButton(ns("refresh"), "Refresh", class = "btn-sm btn-outline-primary")
)
```

## Rule 4 — CSS custom properties for palette consistency

Define reusable colors as CSS custom properties on `:root` at the top of `www/custom.css`. Reference them throughout the file. This keeps hex values out of individual rules and makes palette changes a one-line edit.

```css
:root {
  --app-accent:   #18BC9C;
  --app-bg-muted: #f8f9fa;
  --app-border:   #dee2e6;
}

.summary-card {
  border-left: 4px solid var(--app-accent);
  background: var(--app-bg-muted);
}
```

Use a short, app-specific prefix (`--app-*`, `--sc-*`, etc.) to avoid collisions with Bootstrap's own custom properties.

## Rule 5 — File structure and comments

Organize `www/custom.css` with section headers. Group rules by purpose, not by the file they support.

```css
/* =============================================================================
   custom.css — <app name>
   Purpose: <one-line summary>
   ============================================================================= */

/* --- CSS custom properties -------------------------------------------------- */
:root { ... }

/* --- Layout overrides ------------------------------------------------------- */

/* --- Component styles ------------------------------------------------------- */

/* --- Status indicators / animations ----------------------------------------- */

/* --- Responsive overrides --------------------------------------------------- */
@media (max-width: 768px) { ... }
```

## Rule 6 — Namespace-aware selectors for modules

When targeting a module output with a CSS ID selector, use the **fully-namespaced** ID — the one that appears in the rendered HTML — not the bare ID from the R code.

If R code has `DT::DTOutput(ns("my_table"))` inside a module with id `"ae_listing"`, the rendered HTML element gets `id="ae_listing-my_table"`. The CSS selector must be `#ae_listing-my_table`, not `#my_table`.

```css
/* ns("my_table") in mod_ae_listing_server → "ae_listing-my_table" */
#ae_listing-my_table .dataTable td {
  font-size: 0.85rem;
}
```

Always add a comment citing the R source so future editors know why the ID has a prefix. Prefer class selectors over ID selectors when the same style applies to multiple module instances.

## Rule 7 — Use `!important` sparingly

`!important` is sometimes necessary to override Bootstrap or Shiny defaults that resist normal specificity. When you use it, add a comment explaining *why*:

```css
/* Override bslib card body padding so chat_ui() fills flush to edges */
.chat-card-body {
  padding: 0 !important;
}
```

If you find yourself using `!important` on more than 2-3 rules, the approach is wrong — increase selector specificity or use `bs_theme()` / `bs_add_rules()` instead.

## Rule 8 — `bs_theme()` and `bs_add_rules()` for theme-level changes

For changes that affect the whole app — primary color, font family, border radius, navbar background — use `bs_theme()` in `ui.R`, not CSS overrides:

```r
app_theme <- bs_theme(
  version    = 5,
  bootswatch = "flatly",
  primary    = "#2C3E50",
  success    = "#18BC9C",
  base_font  = font_google("Inter")
)
```

For rules that need access to Bootstrap Sass variables but don't fit a `bs_theme()` argument, use `bs_add_rules()`:

```r
app_theme <- bs_theme(...) %>%
  bs_add_rules(".sidebar-title { font-size: $font-size-lg; }")
```

Reserve `www/custom.css` for app-specific component styles that sit *on top of* the theme, not for redefining the theme itself.

## Quick reference — where does this style belong?

| What you want to change | Where |
|--------------------------|-------|
| App-wide colors, fonts, border radius | `bs_theme()` in `ui.R` |
| Sass variable access (e.g., `$font-size-lg`) | `bs_add_rules()` on the theme |
| Spacing, alignment, simple layout | Bootstrap utility classes in R |
| Component-specific visual treatment | `www/custom.css` |
| Data-driven / computed styles | Inline `style=` in R |
