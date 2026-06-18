# pharmaRTF / huxtable RTF Output Patterns

Use this rule whenever writing RTF output with pharmaRTF and huxtable together.

## Namespace: Always Qualify Everything

When both packages are loaded, the `set_*` namespace overlap is broad enough that
**all** huxtable formatting calls must use `huxtable::` and all pharmaRTF document
calls must use `pharmaRTF::`. Do not rely on load order.

```r
library(huxtable)
library(pharmaRTF)

# Every huxtable call:  huxtable::set_*()
# Every pharmaRTF call: pharmaRTF::rtf_doc(), pharmaRTF::write_rtf(), etc.
```

## Column Widths

Use `set_width(usable_inches / 6)` combined with proportional `set_col_width()`
values that sum to 1. Do **not** put inch values directly into `set_col_width()`.

```r
# Portrait 8.5" page, 0.5" margins → 7.5" usable
huxtable::set_width(7.5 / 6) %>%
huxtable::set_col_width(c(0.06, 0.79, 0.15))   # proportions summing to 1

# Landscape 11" page, 0.5" margins → 10" usable
huxtable::set_width(10 / 6) %>%
huxtable::set_col_width(c(0.07, 0.29, 0.107, 0.107, 0.107, 0.107, 0.107, 0.106))
```

The "/ 6" denominator is huxtable's internal baseline width. Usable width =
page width − left margin − right margin.

## Document Chain

`rtf_doc(ht)` is the entry point — there is no `add_table()`. Chain document
settings and write in one pipeline:

```r
pharmaRTF::rtf_doc(ht) %>%
  pharmaRTF::set_pagesize(c(width = 8.5, height = 11)) %>%
  pharmaRTF::set_margins(c(top = 0.5, bottom = 0.5, left = 0.5, right = 0.5)) %>%
  pharmaRTF::add_titles(
    pharmaRTF::hf_line("Table Title", bold = TRUE, align = "center"),
    pharmaRTF::hf_line("Subtitle",                 align = "center")
  ) %>%
  pharmaRTF::add_footnotes(
    pharmaRTF::hf_line(
      paste0("Run date: ", format(Sys.Date(), "%d%b%Y")),
      align = "left", italic = TRUE
    )
  ) %>%
  pharmaRTF::write_rtf(file = rtf_path)
```

## Full Single-Header Table Template

```r
ht <- huxtable::as_hux(df, add_colnames = TRUE) %>%
  huxtable::set_bold(1, huxtable::everywhere, TRUE) %>%
  huxtable::set_top_border(1, huxtable::everywhere, 0.5) %>%
  huxtable::set_bottom_border(1, huxtable::everywhere, 0.5) %>%
  huxtable::set_bottom_border(huxtable::final(), huxtable::everywhere, 0.5) %>%
  huxtable::set_header_rows(1, TRUE) %>%
  huxtable::set_valign(1, huxtable::everywhere, "middle") %>%
  huxtable::set_width(usable_inches / 6) %>%
  huxtable::set_col_width(col_proportions) %>%
  huxtable::set_align(huxtable::everywhere, <col>, "left"|"center"|"right") %>%
  huxtable::set_font_size(9)
```

## Multi-Row Span Header Template

When the header requires merged cells (e.g., grouped strata columns):

```r
# Build header rows manually; use add_colnames = FALSE
span_row <- tibble::tibble(Col1 = "Label", Col2 = "GroupA", Col3 = "", ...)
sub_row  <- tibble::tibble(Col1 = "",      Col2 = "Sub1",   Col3 = "Sub2", ...)
df_with_headers <- dplyr::bind_rows(span_row, sub_row, data_df)

ht <- huxtable::as_hux(df_with_headers, add_colnames = FALSE) %>%
  huxtable::merge_cells(1, 2:3) %>%   # merge span across contiguous cols
  huxtable::set_header_rows(1, TRUE) %>%
  huxtable::set_header_rows(2, TRUE) %>%
  huxtable::set_bold(1:2, huxtable::everywhere, TRUE) %>%
  ...
```

## Watch Out For

- **Column order** in the data frame must match your `set_align()` column indices.
  `summarize(Count = ..., Criteria = ...)` produces `Count` before `Criteria` —
  use `select()` to enforce display order before building the huxtable.
- `set_wrap()` controls text wrapping per column: `TRUE` for text columns,
  `FALSE` for narrow number/label columns.
