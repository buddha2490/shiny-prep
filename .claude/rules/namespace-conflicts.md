# Namespace Conflicts

When two loaded packages export the same function name, use `package::function()` for the less frequently used one. Do NOT use `::` notation for non-conflicting functions.

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
| `alpha()` | ggplot2, scales | ggplot2 | `scales::alpha()` |
| `col_factor()` | readr, scales | readr | `scales::col_factor()` |
| `discard()` | purrr, scales | purrr | `scales::discard()` |
| `stamp()` | lubridate, scales | lubridate | `scales::stamp()` |

## Resolution Strategy

1. **Load order matters:** Load the more frequently used package LAST — it masks earlier ones
2. **Use `::` for the minority package:** Qualify only the less-used package's function
3. **For heavy dual-use:** Use `conflicted::conflict_prefer("filter", "dplyr")` in `global.R` to make conflicts explicit errors instead of silent masking
4. **In test files:** Load only the packages the test needs — fewer packages means fewer conflicts
