# R Style Guide

Follow the [tidyverse style guide](https://style.tidyverse.org/) with these project-specific rules.

## Naming

- Use `snake_case` for all functions, variables, and file names
- No abbreviations unless they are widely understood in context

## Package Loading

- **Default:** Use `library(package)` then call functions unqualified (e.g., `filter()`, not `dplyr::filter()`)
- **Exception:** Use `package::function()` only for genuine namespace conflicts (see `namespace-conflicts` rule)
- Never use `require()` — always use `library()`

## Pipes

- Prefer the tidyverse pipe `%>%` unless the user specifies the base pipe `|>`
- One operation per line in pipe chains

## Comments

- Every logical section of code gets a comment explaining *why*, not just *what*
- Use section headers for major blocks:

```r
# --- Section Name -----------------------------------------------------------
```

## Formatting

- 2-space indentation (tidyverse default)
- Line length: 80 characters soft limit, 120 hard limit
- One blank line between logical sections
- No trailing whitespace
