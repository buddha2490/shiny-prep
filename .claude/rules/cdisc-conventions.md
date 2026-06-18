# CDISC Conventions

These rules apply to all code that creates, transforms, or validates CDISC datasets (SDTM, ADaM). They define the standards the `cdisc-data-validation` skill checks against. When CDISC data flows through a Shiny app, the no-PHI rule in [logging](logging.md) overrides convenience — log codes and counts, never subject data.

## Reading and Writing Datasets

- **Read SDTM transport files** with `haven::read_xpt()`; **read SAS datasets** with `haven::read_sas()`; ADaM intermediates are typically stored as `.rds` and read with `readRDS()`
- `haven` returns **labelled** vectors: the variable label lives in `attr(x, "label")` and value labels (SAS formats) in `attr(x, "labels")`. Preserve these — do not strip labels with `as.numeric()`/`as.character()` mid-pipeline
- Read variable labels with `labelled::var_label()`; for display, convert a labelled vector to a factor with `haven::as_factor()` (never coerce to bare integer, which discards the value labels)
- **Read missing as missing, not as a sentinel:** `haven` maps SAS `.` to `NA` on read. Never reintroduce `.` or `"NA"` strings in R
- **Write final datasets** with `haven::write_xpt(version = 5)`. Apply labels, types, and lengths with `xportr` (`xportr_label()`, `xportr_type()`, `xportr_length()`) *before* writing — XPT v5 caps variable names at 8 chars and labels at 40 chars

## Identifiers

- `STUDYID` must be consistent across all domains within a study
- `USUBJID` format: `{STUDYID}-{SITEID}-{SUBJID}` — must be unique and match across domains
- `--SEQ` variables (e.g., `AESEQ`, `CMSEQ`) must be unique integers within each `USUBJID`

## Dates and Times

- All dates use ISO 8601 format: `YYYY-MM-DD` or `YYYY-MM-DDThh:mm:ss`
- Partial dates are permitted per SDTM-IG rules (e.g., `2024-01` when day is unknown)
- Study day variables (`--DY`) are calculated relative to `RFSTDTC`:
  - On or after RFSTDTC: `date - RFSTDTC + 1` (no day zero)
  - Before RFSTDTC: `date - RFSTDTC`

## Missing Values

- In R, missing is `NA` — never the SAS special value `.`, never the string `"NA"` or `"."`
- **Character variables** use the empty string `""` for "not collected" where the SDTM-IG expects it; **numeric** variables use `NA`. Do not fill character missings with `NA_character_` when the standard calls for a blank
- **ADaM flag variables** (`SAFFL`, `ITTFL`, `TRTEMFL`, etc.) are encoded `"Y"` / `""` (or `"Y"` / `"N"` where the spec defines both) — never logical `TRUE`/`FALSE`, never `NA`
- Distinguish "missing" from "not applicable": a blank `--DY` because the date is unknown is different from a structurally absent value. Document which is intended

## Controlled Terminology

- Use CDISC Controlled Terminology values exactly as published — no custom values unless the spec explicitly allows extensible CT
- When available, query the CDISC RAG (`mcp__shiny-rag__rag_search`) for current CT values rather than hardcoding

## Cross-Domain Consistency

- All subjects referenced in any domain must exist in DM
- Event dates must fall within the subject's study period (`RFSTDTC` to `RFENDTC`) unless the event is a screen failure or pre-study
- DM is always generated/processed first; other domains reference it

## Variable Attributes

- All variables must carry labels (required for XPT transport)
- Variable names: uppercase, max 8 characters per SDTM-IG
- Use `xportr` functions to apply labels, types, and lengths before writing XPT
- Write final datasets with `haven::write_xpt()` (see [Reading and Writing Datasets](#reading-and-writing-datasets))
