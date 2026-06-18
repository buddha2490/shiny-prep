#!/usr/bin/env python3
"""
Convert CDISC Implementation Guide PDFs (SDTM-IG, ADaM-IG) into structured
Markdown for the RAG ingestion pipeline.

These are *standards* documents, not CRAN reference manuals, so they need a
different parser than pdf_to_markdown.py. The valuable, structured content is:

  - Per-domain variable specification tables (Variable Name / Label / Type /
    Controlled Terms / Role / CDISC Notes / Core) — extracted via find_tables()
  - Per-domain assumptions (the business rules) — extracted as prose
  - The cross-cutting conventions chapters (naming, missing values, dates, CT)

Bulky example data tables and CRF mockups are intentionally skipped — they add
retrieval noise without reference value.

Variable tables are emitted in small row-groups (one Markdown table per group)
so each chunk stays inside the embedding model's window and retrieves cleanly.

Usage:
    python ig_to_markdown.py            # writes sdtm-ig.md and adam-ig.md
    python ig_to_markdown.py --sdtm-only
    python ig_to_markdown.py --adam-only
"""

import argparse
import re
from pathlib import Path

import fitz  # PyMuPDF

HERE = Path(__file__).parent
PDF_DIR = HERE.parent / "docs" / "pdf"
OUT_DIR = HERE / "sources"

SDTM_PDF = PDF_DIR / "SDTMIG v3.4-FINAL_2022-07-21.pdf"
ADAM_PDF = PDF_DIR / "ADaMIG_v1.3.pdf"

# Header/footer boilerplate to strip from every page.
FOOTER_RES = [
    re.compile(r"Implementation Guide", re.I),
    re.compile(r"Clinical Data Interchange Standards Consortium", re.I),
    re.compile(r"All rights reserved", re.I),
    re.compile(r"^Page\s+\d+\s*$", re.I),
    re.compile(r"^\d{4}-\d{2}-\d{2}\s*$"),
    re.compile(r"^©\s*\d{4}"),
    re.compile(r"^CDISC\b.*Model"),
]

# Rows in a variable spec table whose header looks like this.
SPEC_HEADER_HINTS = {"variable name", "variable label", "cdisc notes", "core"}

# Variable tables are emitted in groups packed to this word budget so each
# chunk stays inside the embedding model's ~256-token window (verbose CDISC
# Notes vary wildly, so a fixed variable count per group does not work).
WORDS_PER_GROUP = 150


# ---------------------------------------------------------------------------
# Text helpers
# ---------------------------------------------------------------------------

def is_footer(line: str) -> bool:
    s = line.strip()
    return any(r.search(s) for r in FOOTER_RES)


def dehyphenate(text: str) -> str:
    """Join words split across a line break: "investiga-\ntion" -> "investigation"."""
    return re.sub(r"(\w)-\n(\w)", r"\1\2", text)


def prose_from_pages(doc, p_start: int, p_end: int, y_top=72, y_bot=52) -> str:
    """Extract flowing prose from a page range using text blocks as paragraphs.

    p_start/p_end are 0-indexed, half-open [p_start, p_end). Drops header/footer
    bands by y-position and boilerplate by content; each surviving block becomes
    one paragraph.
    """
    paras = []
    for p in range(p_start, p_end):
        page = doc[p]
        height = page.rect.height
        for x0, y0, x1, y1, text, *_ in page.get_text("blocks"):
            if y0 < y_top or y1 > height - y_bot:
                continue
            block = dehyphenate(text).strip()
            if not block:
                continue
            lines = [l for l in block.split("\n") if not is_footer(l)]
            block = " ".join(" ".join(lines).split())
            if len(block) < 3:
                continue
            paras.append(block)
    # Neutralize stray leading '#' (e.g. "# of capsules" in CRF mockups) so the
    # ingest chunker doesn't mistake body text for a Markdown header.
    return re.sub(r"(?m)^(\s*)(#+)", r"\1\\\2", "\n\n".join(paras))


def page_text(doc, p: int) -> str:
    return doc[p].get_text()


def split_prose_by_titles(text: str, titles: list[str]) -> list[tuple[str, str]]:
    """Split one prose stream into (title, body) by locating each numbered
    section title in order. Robust when many subsections share a PDF page —
    boundaries come from the headings, not page numbers.
    """
    positions = []
    pos = 0
    for t in titles:
        pat = re.compile(r"\b" + r"\s+".join(re.escape(w) for w in t.split()))
        m = pat.search(text, pos)
        if m:
            positions.append((t, m.start(), m.end()))
            pos = m.end()
        else:
            positions.append((t, None, None))
    out = []
    for i, (t, _start, end) in enumerate(positions):
        if end is None:
            continue
        nxt = next((positions[j][1] for j in range(i + 1, len(positions))
                    if positions[j][1] is not None), None)
        body = (text[end:nxt] if nxt else text[end:]).strip(" \n–-:")
        out.append((t, body))
    return out


# ---------------------------------------------------------------------------
# Variable spec table extraction
# ---------------------------------------------------------------------------

def is_spec_header(row) -> bool:
    cells = " ".join((c or "").lower().replace("\n", " ") for c in row)
    return sum(h in cells for h in SPEC_HEADER_HINTS) >= 2


def extract_spec_rows(doc, p_start: int, p_end: int) -> list[list[str]]:
    """Collect and merge a (possibly multi-page) variable spec table.

    Returns a list of cleaned rows [name, label, type, ct, role, notes, core].
    Continuation rows (blank Variable Name) are merged into the prior variable.
    Only tables whose header matches the spec signature are kept, so example
    data tables in the same page range are ignored.
    """
    header = None
    rows: list[list[str]] = []
    for p in range(p_start, p_end):
        for tab in doc[p].find_tables().tables:
            data = tab.extract()
            if not data or not is_spec_header(data[0]):
                continue
            if header is None:
                header = [(_clean_cell(c)) for c in data[0]]
            for raw in data[1:]:
                cells = [_clean_cell(c) for c in raw]
                if not any(cells):
                    continue
                name = cells[0]
                if name:                       # new variable
                    rows.append(cells)
                elif rows:                     # continuation — append to prior
                    for i, c in enumerate(cells):
                        if c:
                            rows[-1][i] = (rows[-1][i] + " " + c).strip()
    return rows if header else []


def _clean_cell(c) -> str:
    if not c:
        return ""
    return " ".join(c.replace("\n", " ").split()).strip()


def md_escape(text: str) -> str:
    return text.replace("|", "\\|")


def emit_variable_tables(domain_code: str, rows: list[list[str]],
                         ncols: int) -> list[str]:
    """Emit row-grouped Markdown tables under '### {code} Variables' headers."""
    if not rows:
        return []
    # Normalize to a fixed column layout. SDTM = 7 cols, ADaM = 6 cols.
    if ncols == 7:
        cols = ["Variable", "Label", "Type", "Controlled Terms / Codelist",
                "Role", "CDISC Notes", "Core"]
    else:
        cols = ["Variable", "Label", "Type", "Controlled Terms / Codelist",
                "Core", "CDISC Notes"]

    header = "| " + " | ".join(cols) + " |"
    sep = "|" + "|".join(["---"] * len(cols)) + "|"

    # Pack rows into groups by word budget (keeps each chunk embeddable).
    groups, cur, cur_w = [], [], 0
    for r in rows:
        rw = len(" ".join(r).split())
        if cur and cur_w + rw > WORDS_PER_GROUP:
            groups.append(cur)
            cur, cur_w = [], 0
        cur.append(r)
        cur_w += rw
    if cur:
        groups.append(cur)

    out = []
    for gi, group in enumerate(groups):
        head = f"### {domain_code} Variables" + (f" (part {gi + 1})" if len(groups) > 1 else "")
        lines = [head, "", header, sep]
        for r in group:
            r = (r + [""] * len(cols))[:len(cols)]
            lines.append("| " + " | ".join(md_escape(c) for c in r) + " |")
        out.append("\n".join(lines))
    return out


# ---------------------------------------------------------------------------
# SDTM-IG
# ---------------------------------------------------------------------------

def find_marker_page(doc, p_start, p_end, pattern) -> int | None:
    rx = re.compile(pattern, re.I)
    for p in range(p_start, p_end):
        if rx.search(page_text(doc, p)):
            return p
    return None


SPEC_RX = re.compile(r"\b([A-Z]{2,4})\s*[–-]\s*Specification")


def sdtm_domain_blocks(doc) -> list[dict]:
    """Ordered list of real domains, one per "XX – Specification" heading.

    This is more reliable than the TOC, which buries individual domains (LB, MB,
    EC, …) inside container sections. Each block is [spec_pg, next_pg) 0-indexed.
    """
    sec7 = next((p - 1 for lvl, t, p in doc.get_toc() if t.startswith("7 ")),
                doc.page_count)
    found, seen = [], set()
    for p in range(0, sec7):
        for m in SPEC_RX.finditer(doc[p].get_text()):
            c = m.group(1)
            if c not in seen:
                seen.add(c)
                found.append({"code": c, "spec_pg": p})
    for i, b in enumerate(found):
        b["next_pg"] = found[i + 1]["spec_pg"] if i + 1 < len(found) else sec7
    return found


def parse_sdtm(doc) -> str:
    parts = [_sdtm_front_matter(doc)]

    # --- Conventions: chapter 4 (Assumptions for Domain Models) ---
    toc = doc.get_toc()
    ch4 = [(t, p - 1) for lvl, t, p in toc if lvl in (2, 3, 4) and t.split()[0].startswith("4.")]
    ch4_start = next((p - 1 for lvl, t, p in toc if t.startswith("4 ")), None)
    ch5 = next((p - 1 for lvl, t, p in toc if t.startswith("5 ")), None)
    if ch4 and ch4_start is not None and ch5:
        parts.append("# SDTM-IG Conventions\n")
        full = prose_from_pages(doc, ch4_start, ch5)
        for title, body in split_prose_by_titles(full, [t for t, _ in ch4]):
            if body and len(body) > 30:
                parts.append(f"## {title}\n\n{body}")

    # --- Domains (driven by the real "XX – Specification" markers, which give
    #     true per-domain granularity even inside container TOC sections) ---
    parts.append("# SDTM-IG Domains\n")
    for blk in sdtm_domain_blocks(doc):
        code, spec_pg, next_pg = blk["code"], blk["spec_pg"], blk["next_pg"]

        assum_pg = find_marker_page(doc, spec_pg, next_pg, rf"{code}\s*[–-]\s*Assumptions")
        exam_pg = find_marker_page(doc, spec_pg, next_pg, rf"{code}\s*[–-]\s*Examples?")

        name, structure = _dataset_line(doc, spec_pg, code)
        title = f"{name} ({code})" if name else code
        desc = _domain_description(doc, code, spec_pg)

        section = [f"## {title}"]
        if structure:
            section.append(f"*Structure: {structure}.*")
        if desc:
            section.append(desc)
        parts.append("\n\n".join(section))

        # Variable table: Specification pages up to Assumptions/Examples.
        if assum_pg is not None:
            tbl_end = assum_pg + 1
        elif exam_pg is not None:
            tbl_end = exam_pg + 1
        else:
            tbl_end = next_pg
        rows = extract_spec_rows(doc, spec_pg, min(max(spec_pg + 1, tbl_end), next_pg))
        for tbl in emit_variable_tables(code, rows, ncols=7):
            parts.append(tbl)

        # Assumptions: Assumptions marker up to Examples.
        if assum_pg is not None:
            a_end = exam_pg if exam_pg is not None else next_pg
            a_body = prose_from_pages(doc, assum_pg, max(assum_pg + 1, a_end))
            a_body = _after(a_body, rf"{code}\s*[–-]\s*Assumptions")
            a_body = _trim_at(a_body, rf"{code}\s*[–-]\s*Examples?")
            if len(a_body) > 60:
                parts.append(f"### {code} Assumptions\n\n{a_body}")

    return "\n\n".join(parts) + "\n"


def _dataset_line(doc, spec_pg, code) -> tuple[str | None, str | None]:
    """Parse the "xx.xpt, <Full Name> — <class>. One record per … ." line.

    Returns (full_name, structure_phrase), either of which may be None.
    """
    pat = re.compile(rf"{code.lower()}\.xpt,\s*([^\n]+)")
    for p in (spec_pg, spec_pg + 1):
        if p >= doc.page_count:
            continue
        m = pat.search(dehyphenate(page_text(doc, p)))
        if not m:
            continue
        line = " ".join(m.group(1).split())
        name = re.split(r"\s+[—–-]\s+", line, maxsplit=1)[0].strip()
        sm = re.search(r"(One record per[^.\n]*)", line)
        structure = sm.group(1).strip().rstrip(",") if sm else None
        return (name or None), structure
    return None, None


def _domain_description(doc, code, spec_pg) -> str:
    """Description text between the "XX – Description/Overview" marker and the
    spec table. Returns "" if the marker is absent (avoids prior-domain leak)."""
    lo = max(0, spec_pg - 1)
    txt = prose_from_pages(doc, lo, min(spec_pg + 1, doc.page_count))
    m = re.search(rf"{code}\s*[–-]\s*(?:Description|Overview|Definition)[^\n]*", txt)
    if not m:
        return ""
    desc = txt[m.end():]
    desc = _trim_at(desc, rf"{code}\s*[–-]\s*Specification|\b[a-z]{{2,4}}\.xpt\b|Variable\s+Name")
    return desc.strip(" \n–-:")


def _sdtm_front_matter(doc) -> str:
    return (
        "---\n"
        'title: "SDTM-IG"\n'
        'version: "3.4"\n'
        'package_title: "CDISC SDTM Implementation Guide: Human Clinical Trials v3.4"\n'
        'description: "Study Data Tabulation Model Implementation Guide v3.4 — '
        'domain specifications, variable definitions, controlled terminology references, '
        'and conventions for SDTM datasets (naming, missing values, dates, coding)."\n'
        "---\n\n"
        "# SDTM-IG\n\n"
        "*CDISC Study Data Tabulation Model Implementation Guide for Human Clinical "
        "Trials, version 3.4.* Reference extract: domain variable specifications, "
        "per-domain assumptions, and cross-cutting conventions. Example data tables "
        "from the source PDF are omitted."
    )


# ---------------------------------------------------------------------------
# ADaM-IG
# ---------------------------------------------------------------------------

def parse_adam(doc) -> str:
    parts = [_adam_front_matter(doc)]
    toc = doc.get_toc()

    # Section 2 fundamentals + section 3 conventions as prose; 3.2/3.3.x as tables.
    def page_of(prefix):
        return next((p - 1 for lvl, t, p in toc if t.split()[0] == prefix), None)

    # --- Conventions: 3.1.x prose ---
    conv_titles = [t for lvl, t, p in toc if t.split()[0].startswith("3.1")]
    sec31 = page_of("3.1")
    sec32 = page_of("3.2")
    if conv_titles and sec31 is not None and sec32:
        parts.append("# ADaM-IG Variable Conventions\n")
        full = prose_from_pages(doc, sec31, sec32)
        for title, body in split_prose_by_titles(full, conv_titles):
            if body and len(body) > 30:
                parts.append(f"## {title}\n\n{body}")

    # --- Variable tables: 3.2 (ADSL) and each 3.3.x (BDS) ---
    var_secs = [(t, p - 1) for lvl, t, p in toc
                if t.split()[0] == "3.2" or t.split()[0].startswith("3.3")]
    sec34 = page_of("3.4") or page_of("4")
    parts.append("# ADaM-IG Variables\n")
    for i, (title, start) in enumerate(var_secs):
        end = var_secs[i + 1][1] if i + 1 < len(var_secs) else (sec34 or doc.page_count)
        rows = extract_spec_rows(doc, start, max(start + 1, end))
        clean_title = re.sub(r"^\d[\d.]*\s+", "", title).strip()
        code = _adam_group_code(title)
        intro = prose_from_pages(doc, start, max(start + 1, start + 1))
        intro = _strip_leading_title(intro, clean_title)
        intro = _trim_at(intro, r"Variable\s*Name")
        parts.append(f"## {clean_title}")
        if intro and len(intro) > 40:
            parts.append(intro)
        for blk in emit_variable_tables(code, rows, ncols=6):
            parts.append(blk)

    return "\n\n".join(parts) + "\n"


def _adam_group_code(title: str) -> str:
    return "ADSL" if title.split()[0] == "3.2" else "BDS"


def _adam_front_matter(doc) -> str:
    return (
        "---\n"
        'title: "ADaM-IG"\n'
        'version: "1.3"\n'
        'package_title: "CDISC ADaM Implementation Guide v1.3"\n'
        'description: "Analysis Data Model Implementation Guide v1.3 — standard ADaM '
        'variables, ADSL and Basic Data Structure (BDS) variable specifications, '
        'naming fragments, flag and timing conventions for analysis datasets."\n'
        "---\n\n"
        "# ADaM-IG\n\n"
        "*CDISC Analysis Data Model Implementation Guide, version 1.3.* Reference "
        "extract: standard variable conventions, ADSL and BDS variable specifications, "
        "and naming fragments."
    )


# ---------------------------------------------------------------------------
# Shared prose trimming
# ---------------------------------------------------------------------------

def _strip_leading_title(body: str, title: str) -> str:
    """Remove a repeated section-title line at the start of extracted prose."""
    bare = re.sub(r"^\d[\d.]*\s+", "", title).strip()
    body = body.lstrip()
    for cand in (title, bare):
        if body.startswith(cand):
            body = body[len(cand):].lstrip(" \n:–-")
    return body


def _trim_at(body: str, pattern: str) -> str:
    m = re.search(pattern, body)
    return body[:m.start()].strip() if m else body


def _after(body: str, pattern: str) -> str:
    m = re.search(pattern, body)
    return body[m.end():].lstrip(" \n:–-") if m else body


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--sdtm-only", action="store_true")
    ap.add_argument("--adam-only", action="store_true")
    ap.add_argument("--output", "-o", default=str(OUT_DIR))
    args = ap.parse_args()
    out_dir = Path(args.output)
    out_dir.mkdir(parents=True, exist_ok=True)

    do_sdtm = not args.adam_only
    do_adam = not args.sdtm_only

    if do_sdtm:
        print(f"Parsing {SDTM_PDF.name} ...")
        doc = fitz.open(SDTM_PDF)
        md = parse_sdtm(doc)
        doc.close()
        f = out_dir / "sdtm-ig.md"
        f.write_text(md, encoding="utf-8")
        print(f"  -> {f.name}  ({md.count(chr(10)+'## ')} sections, {len(md)} chars)")

    if do_adam:
        print(f"Parsing {ADAM_PDF.name} ...")
        doc = fitz.open(ADAM_PDF)
        md = parse_adam(doc)
        doc.close()
        f = out_dir / "adam-ig.md"
        f.write_text(md, encoding="utf-8")
        print(f"  -> {f.name}  ({md.count(chr(10)+'## ')} sections, {len(md)} chars)")


if __name__ == "__main__":
    main()
