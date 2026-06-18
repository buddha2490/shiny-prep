---
name: cdisc-data-validation
description: Auto-invoked when validating or QC-ing SDTM/ADaM datasets against CDISC standards — required variables, naming conventions, types, labels, controlled terminology, ISO 8601 dates, missing-value handling, and cross-domain consistency. Use when asked to validate CDISC data, check standards compliance, audit a clinical dataset, or produce a data-validation report before building a Shiny app on clinical data.
---

# CDISC Data Validation Skill

Validate a folder of SDTM and/or ADaM datasets against CDISC standards and produce a findings report. This skill is the **procedure**; the **standards it checks against** are defined in [`.claude/rules/cdisc-conventions.md`](../../rules/cdisc-conventions.md). Required-variable lists and controlled-terminology codelists come from the CDISC RAG (`mcp__shiny-rag__rag_search`) at run time — never hardcode them.

The skill is self-contained: it reads datasets directly with `haven`. It does not depend on any upstream profiling step.

## Trigger

Use this skill when the user asks to:

- Validate or QC SDTM/ADaM datasets against CDISC standards
- Check standards compliance of one or more clinical domains
- Audit variable names, types, labels, or controlled-terminology values
- Find missing required variables, malformed dates, or cross-domain inconsistencies
- Produce a data-validation report (e.g., before building a Shiny app on the data)

## Inputs

- **Required:** a path to a directory of datasets — `.xpt` (SDTM transport), `.sas7bdat` (SAS), or `.rds` (ADaM intermediates). One dataset per domain, file name = domain (e.g. `dm.xpt` → `DM`).
- **Optional:** a domain whitelist (`--domains=DM,AE,EX`) and an output path for the report. Default: validate every dataset found; write the report alongside the data.

If the path or dataset types are unclear, ask before loading.

---

## Process

### Step 1 — Load datasets and build an inventory

Load every domain directly with `haven`, preserving labels and value labels (per [cdisc-conventions: Reading and Writing](../../rules/cdisc-conventions.md#reading-and-writing-datasets)). Build a per-variable metadata table and per-variable value frequencies — everything the checks need, computed once.

```r
library(haven)
library(dplyr)
library(purrr)
library(stringr)
library(tibble)

# --- Load one dataset by extension -------------------------------------------
load_domain <- function(path) {
  switch(tolower(tools::file_ext(path)),
    xpt      = haven::read_xpt(path),
    sas7bdat = haven::read_sas(path),
    rds      = readRDS(path),
    stop("Unsupported dataset type: ", basename(path), call. = FALSE)
  )
}

data_dir <- "data/adam"   # <- the user's folder
files    <- list.files(data_dir, pattern = "\\.(xpt|sas7bdat|rds)$",
                       full.names = TRUE, ignore.case = TRUE)

datasets <- files %>%
  rlang::set_names(toupper(tools::file_path_sans_ext(basename(files)))) %>%
  map(load_domain)

# --- Per-variable metadata from a haven-labelled data frame ------------------
# label  lives in attr(x, "label"); value labels in attr(x, "labels").
# Count NA and blank-string separately — a blank "" is a VALID SDTM value,
# not the same as a missing NA (see cdisc-conventions: Missing Values).
dataset_metadata <- function(ds) {
  tibble(
    variable = names(ds),
    label    = map_chr(ds, ~ attr(.x, "label") %||% ""),
    type     = map_chr(ds, ~ class(.x)[1]),
    n        = nrow(ds),
    n_na     = map_int(ds, ~ sum(is.na(.x))),
    n_blank  = map_int(ds, ~ if (is.character(.x)) sum(.x == "", na.rm = TRUE) else 0L)
  )
}

# --- Observed values + counts for a character/factor variable (CT checks) ----
value_freq <- function(x) {
  haven::as_factor(x) %>%        # surfaces SAS value labels, keeps order
    fct_count_safe()             # value | n  (see helper below)
}
fct_count_safe <- function(f) {
  tibble(value = as.character(f)) %>% count(value, name = "n")
}

inventory <- imap(datasets, function(ds, domain) {
  list(
    domain   = domain,
    records  = nrow(ds),
    n_vars   = ncol(ds),
    metadata = dataset_metadata(ds),
    data     = ds                # kept for cross-domain joins in Step 3h
  )
})
```

### Step 2 — Look up CDISC standards via the RAG

For each domain, retrieve the required variables and applicable controlled terminology from `mcp__shiny-rag__rag_search`. **Do not** assert required-variable lists or CT values from memory — query and cite.

Run **per-domain** queries plus the **cross-domain** queries below. Examples:

| Scope | Query (`mcp__shiny-rag__rag_search`) |
|-------|--------------------------------------|
| DM | `SDTM DM demographics required variables USUBJID RFSTDTC SEX RACE ETHNIC` |
| AE | `SDTM AE adverse events required variables AETERM AEDECOD AESEV AESER AEREL AESEQ` |
| EX | `SDTM EX exposure required variables EXTRT EXDOSE EXDOSEU EXSTDTC EXROUTE` |
| LB | `SDTM LB labs required variables LBTESTCD LBTEST LBSTRESN LBSTRESU` |
| ADSL | `ADaM ADSL subject-level required variables SAFFL ITTFL TRTP TRTPN` |
| ADAE | `ADaM ADAE required variables AETERM AEDECOD TRTEMFL` |
| ADTTE | `ADaM ADTTE time-to-event required variables AVAL PARAM CNSR EVNTDESC` |
| *(any other domain)* | `SDTM/ADaM <DOMAIN> required variables and controlled terminology` |
| CT — demographics | `CDISC controlled terminology SEX RACE ETHNIC codelist values` |
| CT — AE | `CDISC controlled terminology AESEV AESER AEREL adverse event` |
| Naming | `SDTM variable naming uppercase 8 characters domain prefix suffix DTC TERM DECOD` |
| Dates | `SDTM ISO 8601 DTC date format YYYY-MM-DD partial dates` |
| Flags | `ADaM analysis flags SAFFL ITTFL Y empty string missing value handling` |

If a query returns nothing useful (the pharma CT sources may not yet be ingested), say so in the report — flag the check as **NOT VERIFIED** rather than inventing a standard.

### Step 3 — Run the checks

Apply each check below per domain, using the `inventory` (Step 1) and the RAG results (Step 2). Each is keyed to a section of [`cdisc-conventions.md`](../../rules/cdisc-conventions.md). Factor the individual checks into small pure functions so they can be unit-tested per [`testing.md`](../../rules/testing.md).

| # | Check | Rule section | Logic | Severity on fail |
|---|-------|--------------|-------|------------------|
| a | **Required variables present** | Variable Attributes | `setdiff(required_from_rag, metadata$variable)` | **BLOCKING** if any absent |
| b | **Naming conventions** | Variable Attributes | uppercase, ≤8 chars, correct domain prefix, valid suffix (`--DTC`/`--TERM`/`--DECOD`/`--CD`/`--SEQ`/`--N`) | **WARNING** |
| c | **Variable types** | Reading/Writing | `--DTC` → character (not Date); `--STRESN`/`AVAL`/dose → numeric; flags → character; `--SEQ` → integer | **WARNING** |
| d | **Labels** | Variable Attributes | non-empty label required; ≤40 chars for XPT v5 transport | **WARNING** (empty) / **NOTE** (>40) |
| e | **Controlled terminology** | Controlled Terminology | `value_freq()` observed values vs RAG codelist | **BLOCKING** (value not in *closed* codelist) / **NOTE** (non-standard value in *extensible* codelist — possible sponsor extension) |
| f | **Date format** | Dates and Times | every `--DTC` value matches `^\d{4}(-\d{2}(-\d{2}(T\d{2}:\d{2}(:\d{2})?)?)?)?$` | **BLOCKING** (malformed) / **NOTE** (partial date `YYYY` or `YYYY-MM`) |
| g | **Missing values** | Missing Values | `USUBJID` never `NA`; required numerics not `NA`; flags encoded `"Y"`/`""` not `TRUE`/`FALSE`/`NA` | **BLOCKING** (`USUBJID`/required) / **WARNING** (flag encoding, >20% missing on non-required) |
| h | **Cross-domain consistency** | Cross-Domain Consistency | every non-DM `USUBJID` exists in DM; one `STUDYID` across all domains; `--SEQ` unique within `USUBJID`; event dates within `RFSTDTC`–`RFENDTC` | **BLOCKING** (subject/STUDYID/SEQ) / **WARNING** (date out of window) |

Accumulate every result into one tidy findings table — greppable, sortable, and ready to render:

```r
new_findings <- function() {
  tibble(severity = character(), domain = character(), variable = character(),
         message = character(), actual = character(), expected = character(),
         reference = character())
}

add_finding <- function(findings, severity, domain, variable, message,
                        actual = NA_character_, expected = NA_character_,
                        reference = NA_character_) {
  bind_rows(findings, tibble(severity, domain, variable, message,
                             actual, expected, reference))
}

# Example — check h, cross-domain subject consistency
dm <- inventory$DM$data
check_subjects_in_dm <- function(findings, domain, ds, dm) {
  orphans <- anti_join(ds, dm, by = "USUBJID") %>% distinct(USUBJID)
  if (nrow(orphans) > 0) {
    findings <- add_finding(findings, "BLOCKING", domain, "USUBJID",
      "Subjects present in domain but absent from DM",
      actual    = paste(nrow(orphans), "orphan subjects"),
      expected  = "all USUBJID must exist in DM",
      reference = "CDISC SDTM-IG cross-domain consistency")
  }
  findings
}
```

> **PHARMA:** the findings table carries `USUBJID` counts and codes — never paste raw subject identifiers or verbatim AE terms into a report that will be logged or shared. Report counts, not patients (see [logging: Rule 6](../../rules/logging.md)).

### Step 4 — Classify findings

| Severity | Meaning |
|----------|---------|
| **BLOCKING** | Missing required variable, invalid CT value in a closed codelist, malformed date, missing/duplicate key, cross-domain mismatch |
| **WARNING** | Missing label, type mismatch, flag encoded as `TRUE`/`FALSE`, high missingness on a non-required variable |
| **NOTE** | Naming edge case, extensible-CT value, partial date, label >40 chars, informational |
| **NOT VERIFIED** | Standard could not be retrieved from the RAG — check not run |
| **PASS** | Check ran with no issues |

### Step 5 — Emit the report

Produce a **gt** summary table (the repo default for static, publication-quality output) and a per-domain findings listing. Offer to render a self-contained Quarto report for archival/traceability.

```r
library(gt)

summary_tbl <- findings %>%
  count(domain, severity) %>%
  tidyr::pivot_wider(names_from = severity, values_from = n, values_fill = 0)

summary_tbl %>%
  gt(rowname_col = "domain") %>%
  tab_header(title = "CDISC Validation Summary") %>%
  sub_missing(missing_text = "0")            # NOT fmt_missing() — deprecated
```

For an archivable deliverable, write a static Quarto report (`cdisc-validation-<YYYY-MM-DD>.qmd`, `format: html`, `embed-resources: true`) containing: an abstract with BLOCKING/WARNING/NOTE counts, the summary table, a per-domain section (required-variable checklist, variable detail, CT violations, cross-domain result, domain verdict), and a **RAG reference log** listing every `rag_search` query and a one-line result summary, so each standard cited is traceable.

---

## Finding Format

When reporting an individual finding in prose:

```
**[SEVERITY]** `DOMAIN.VARIABLE` — short description

- Actual:    <what was found in the data>
- Expected:  <what CDISC requires>
- Reference: <RAG result — codelist id or SDTM/ADaM-IG section>
- Fix:       <concrete action>
```

---

## Boundaries — what this skill does NOT do

- It does **not** *fix* the data — it reports findings. Derivation/remediation is a separate task (hand to the `shiny-r-architect` for code, or to an ADaM derivation workflow).
- It does **not** invent standards. If the RAG lacks a domain's CT or required-variable list, the affected checks are **NOT VERIFIED**, not guessed.
- It is **not** a Shiny module. If the user wants validation results displayed *in* an app, this skill produces the findings tibble; building the UI is `raw-shiny-app` / `dt-table` / `gt-table` territory.

## Related

- [`.claude/rules/cdisc-conventions.md`](../../rules/cdisc-conventions.md) — the standards this skill enforces
- [`.claude/rules/logging.md`](../../rules/logging.md) — no PHI/PII in any logged or shared output
- `mcp__shiny-rag__rag_search` — the source of required-variable lists and CT codelists
