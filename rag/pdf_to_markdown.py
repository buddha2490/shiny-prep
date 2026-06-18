#!/usr/bin/env python3
"""
Convert CRAN reference manual PDFs into structured Markdown files
suitable for the RAG ingestion pipeline.

Each PDF produces one .md file in the output directory, with:
  - YAML front matter (package name, version, description)
  - One h2 (##) section per exported function
  - Bold sub-section labels (Description, Usage, Arguments, etc.)

Usage:
    python pdf_to_markdown.py <pdf_dir_or_file> [--output rag/sources]
"""

import argparse
import re
import sys
from pathlib import Path

import fitz  # PyMuPDF


# ---------------------------------------------------------------------------
# PDF text extraction
# ---------------------------------------------------------------------------

def extract_full_text(pdf_path: str) -> tuple[str, int]:
    """Extract all text from a PDF, return (text, page_count)."""
    doc = fitz.open(pdf_path)
    pages = []
    for page in doc:
        pages.append(page.get_text())
    doc.close()
    return "\n".join(pages), len(pages)


# ---------------------------------------------------------------------------
# CRAN reference manual parser
# ---------------------------------------------------------------------------

def parse_package_metadata(text: str) -> dict:
    """Extract package name, version, title, and description from page 1."""
    meta = {}

    # Package name from "Package 'name'" header
    m = re.search(r"Package\s+'([^']+)'", text)
    if m:
        meta["package"] = m.group(1)

    # Version
    m = re.search(r"Version\s+(\S+)", text)
    if m:
        meta["version"] = m.group(1)

    # Title — appears after "Title" label, before "Version" or "Description"
    m = re.search(r"Title\s+(.+?)(?:\nVersion|\nType)", text, re.DOTALL)
    if m:
        meta["title"] = " ".join(m.group(1).split())

    # Description — multi-line, ends at "License"
    m = re.search(r"Description\s+(.+?)(?:\nLicense)", text, re.DOTALL)
    if m:
        meta["description"] = " ".join(m.group(1).split())

    return meta


def extract_toc_functions(text: str) -> list[str]:
    """Extract function names from the Table of Contents section.

    CRAN TOC entries are dotted-leader lines:
        function_name . . . . . . . . . . . . . . . . . . . . . 5

    The page number may sit on the same line or wrap to the next, and a long
    name may be split from its dotted leader across a line break
    ("titlePanel\\n. . ."). Large manuals (e.g. shiny) also repeat a "Contents"
    running header on each TOC page and carry an earlier stray "Contents" inside
    the page-1 author/description block. So: anchor on the first "Contents" that
    is actually followed by a dotted entry, read to the terminal "Index <page>"
    line, and capture names independently of page-number placement.
    """
    # Anchor on the first "Contents" immediately followed by a dotted TOC entry,
    # skipping any stray "Contents" in the page-1 author/description block.
    toc_start = None
    for m in re.finditer(r"\nContents\n", text):
        if re.match(r"\s*[A-Za-z][\w.\-]*\s+\.(?:\s*\.){2,}", text[m.end():m.end() + 120]):
            toc_start = m.end()
            break
    if toc_start is None:
        return []

    # End at the terminal "Index\n<page>" line that closes the TOC.
    end_match = re.search(r"\nIndex\s*\n\s*\d+", text[toc_start:])
    toc_end = toc_start + (end_match.start() if end_match else 16000)
    toc_text = text[toc_start:toc_end]

    # Capture each entry's name. `\s+` spans an optional line break, so names
    # that wrapped away from their dotted leader still match; page numbers are
    # ignored entirely (they vary between same-line and next-line).
    functions = []
    for m in re.finditer(r"([A-Za-z][\w.\-]+)\s+\.[ .]{3,}", toc_text):
        name = m.group(1).strip()
        if name not in ("Contents", "Index") and name not in functions:
            functions.append(name)

    return functions


def _find_toc_end(text: str) -> int:
    """Find the position where the Table of Contents ends and function docs begin.

    In CRAN manuals, the TOC ends with an "Index  <page>" entry, then the first
    function documentation block starts.
    """
    # The TOC ends at the "Index" entry line, after which function docs begin.
    # Look for the Index line in the TOC (not the actual Index section at the end)
    contents_match = re.search(r"\nContents\n", text)
    if not contents_match:
        return 0

    # Find "Index\n<number>\n" which marks the end of the TOC
    index_in_toc = re.search(r"\nIndex\s*\n\s*\d+\s*\n", text[contents_match.end():])
    if index_in_toc:
        return contents_match.end() + index_in_toc.end()

    return contents_match.end() + 500  # fallback


def find_function_blocks(text: str, toc_functions: list[str]) -> list[dict]:
    """Split the document text into function documentation blocks.

    Strategy: skip past the TOC, then for each function name from the TOC,
    find its documentation entry in the body text. Each function's doc starts
    with its name followed (within a few lines) by "Description".

    Returns list of dicts with keys: name, title, body
    """
    if not toc_functions:
        return []

    body_start = _find_toc_end(text)
    body_text = text[body_start:]

    # For each function, find its entry point in the body text.
    # Pattern: function_name on a line, then a title line, then Description
    # within a few lines (allowing page header noise in between).
    entries = []

    for func_name in toc_functions:
        escaped = re.escape(func_name)

        # Pattern: function_name\n title_text \n Description
        # Allow up to 5 lines between name and Description for page noise
        # Use (?:^|\n) to also match the very first function at the start of body
        pattern = (
            r"(?:^|\n)" + escaped + r"\s*\n"
            + r"((?:.*\n){0,5}?)"
            + r"Description\s*\n"
        )

        # Search from after the last found entry to avoid re-matching
        search_start = entries[-1]["rel_pos"] + 1 if entries else 0
        match = re.search(pattern, body_text[search_start:])

        if match:
            abs_pos = search_start + match.start()
            # Extract title from the captured group between name and Description
            title_raw = match.group(1).strip()
            # Clean: remove page numbers, blank lines, running headers
            title_lines = [
                l.strip() for l in title_raw.split("\n")
                if l.strip() and not re.match(r"^\d+$", l.strip())
            ]
            title = " ".join(title_lines)
            # Remove the function name if it appears in the title (running header)
            title = re.sub(r"^" + re.escape(func_name) + r"\s*", "", title).strip()

            entries.append({
                "name": func_name,
                "title": title,
                "rel_pos": abs_pos,
                "abs_pos": body_start + abs_pos,
            })

    # Extract body text for each entry
    blocks = []
    for i, entry in enumerate(entries):
        start = entry["abs_pos"]
        if i + 1 < len(entries):
            end = entries[i + 1]["abs_pos"]
        else:
            # Last block — stop before the Index section at end of document
            idx_match = re.search(r"\nIndex\s*\n", text[start:])
            end = start + idx_match.start() if idx_match else len(text)

        blocks.append({
            "name": entry["name"],
            "title": entry["title"],
            "body": text[start:end].strip(),
        })

    return blocks


_SECTION_LABELS = {
    "Description", "Usage", "Arguments", "Details", "Value",
    "Functions", "See Also", "Examples", "Note", "Notes",
    "References", "Author(s)", "Format", "Source",
    "OpenTelemetry", "Reference Manual",
}

# Sections whose content should be wrapped in code fences
_CODE_SECTIONS = {"Usage", "Examples"}


def clean_function_body(body: str, func_name: str, all_func_names: set[str] | None = None) -> str:
    """Clean up a function's raw text body into readable markdown-ish text.

    - Remove page headers/footers (page numbers, running function names)
    - Convert section labels to bold markdown
    - Wrap Usage/Examples in code fences (prevents ## S4 method becoming h2)
    - Clean up whitespace
    """
    if all_func_names is None:
        all_func_names = {func_name}

    lines = body.split("\n")
    cleaned = []
    in_code_section = False
    current_section = ""

    i = 0
    while i < len(lines):
        line = lines[i]
        stripped = line.strip()

        # Skip standalone page numbers
        if re.match(r"^\d+$", stripped):
            i += 1
            continue

        # Skip running headers: function names from the package appearing
        # alone on a line (page headers/footers in the PDF)
        if stripped in all_func_names and i > 0:
            i += 1
            continue

        # Skip page-number + function-name header lines like "8\nPool-class"
        if re.match(r"^\d+\s+\S+", stripped) and any(
            stripped.endswith(fn) or stripped.startswith(fn)
            for fn in all_func_names
        ):
            i += 1
            continue

        # Detect section labels
        if stripped in _SECTION_LABELS:
            # Close code fence if we were in one
            if in_code_section:
                cleaned.append("```")
                in_code_section = False

            cleaned.append("")
            cleaned.append(f"**{stripped}**")
            cleaned.append("")
            current_section = stripped

            # Open code fence for Usage/Examples
            if stripped in _CODE_SECTIONS:
                cleaned.append("```r")
                in_code_section = True

            i += 1
            continue

        # Inside code fences, escape leading ## to prevent markdown header parsing
        if in_code_section and stripped.startswith("## "):
            line = line.replace("## ", "# ", 1)

        cleaned.append(line)
        i += 1

    # Close any open code fence
    if in_code_section:
        cleaned.append("```")

    return "\n".join(cleaned)


def format_function_block(block: dict, all_func_names: set[str] | None = None) -> str:
    """Format a single function block as markdown."""
    name = block["name"]
    title = block["title"]
    body = clean_function_body(block["body"], name, all_func_names)

    # Remove the function name + title header from body since we'll use ## header
    # The body starts with "function_name  title\nDescription\n..."
    # Strip that prefix
    lines = body.split("\n")
    # Find where Description starts and take from there
    desc_idx = None
    for idx, line in enumerate(lines):
        if line.strip() == "**Description**":
            desc_idx = idx
            break

    if desc_idx is not None:
        body = "\n".join(lines[desc_idx:])
    else:
        # Fallback: try to strip the header manually
        body = re.sub(
            r"^.*?" + re.escape(name) + r".*?\n",
            "",
            body,
            count=1,
        )

    # Clean up excessive blank lines
    body = re.sub(r"\n{3,}", "\n\n", body).strip()

    return f"## {name}\n\n*{title}*\n\n{body}"


# ---------------------------------------------------------------------------
# Main conversion
# ---------------------------------------------------------------------------

def convert_pdf_to_markdown(pdf_path: str) -> tuple[str, dict]:
    """Convert a single CRAN reference manual PDF to markdown.

    Returns (markdown_text, metadata_dict).
    """
    text, page_count = extract_full_text(pdf_path)
    meta = parse_package_metadata(text)
    pkg_name = meta.get("package", Path(pdf_path).stem)

    # Extract function list from TOC
    toc_functions = extract_toc_functions(text)

    if not toc_functions:
        print(f"  WARNING: No functions found in TOC for {pkg_name}")
        # Fallback: return the raw text as a single section
        return f"# {pkg_name}\n\n{text}", meta

    # Find and parse function blocks
    blocks = find_function_blocks(text, toc_functions)

    # Build markdown
    parts = []

    # YAML front matter
    parts.append("---")
    parts.append(f'title: "{pkg_name}"')
    if "version" in meta:
        parts.append(f'version: "{meta["version"]}"')
    if "title" in meta:
        parts.append(f'package_title: "{meta["title"]}"')
    if "description" in meta:
        # Escape quotes in description
        desc = meta["description"].replace('"', '\\"')
        parts.append(f'description: "{desc}"')
    parts.append("---")
    parts.append("")

    # Package header
    parts.append(f"# {pkg_name}")
    parts.append("")

    # Package overview
    if "title" in meta:
        parts.append(f"*{meta['title']}*")
        parts.append("")
    if "description" in meta:
        parts.append(meta["description"])
        parts.append("")

    # Function blocks
    all_func_names = {b["name"] for b in blocks}
    found_names = set()
    for block in blocks:
        formatted = format_function_block(block, all_func_names)
        parts.append(formatted)
        parts.append("")
        found_names.add(block["name"])

    # Report coverage
    missing = [f for f in toc_functions if f not in found_names]
    if missing:
        print(f"  Missing functions ({len(missing)}): {', '.join(missing[:10])}")
        if len(missing) > 10:
            print(f"    ... and {len(missing) - 10} more")

    markdown = "\n".join(parts)

    # Final cleanup
    markdown = re.sub(r"\n{3,}", "\n\n", markdown)

    return markdown, meta


def main():
    parser = argparse.ArgumentParser(
        description="Convert CRAN reference manual PDFs to markdown for RAG ingestion"
    )
    parser.add_argument("path", help="PDF file or directory of PDFs")
    parser.add_argument(
        "--output", "-o",
        default=str(Path(__file__).parent / "sources"),
        help="Output directory for markdown files (default: rag/sources)",
    )
    args = parser.parse_args()

    output_dir = Path(args.output)
    output_dir.mkdir(parents=True, exist_ok=True)

    target = Path(args.path)
    if target.is_file():
        pdfs = [target]
    elif target.is_dir():
        pdfs = sorted(target.glob("*.pdf"))
    else:
        print(f"Path not found: {target}")
        sys.exit(1)

    if not pdfs:
        print(f"No PDF files found in {target}")
        sys.exit(1)

    print(f"Converting {len(pdfs)} PDFs to markdown in {output_dir}/\n")

    for pdf_path in pdfs:
        print(f"Processing: {pdf_path.name}")
        try:
            markdown, meta = convert_pdf_to_markdown(str(pdf_path))
            pkg_name = meta.get("package", pdf_path.stem)
            out_file = output_dir / f"{pkg_name}.md"
            out_file.write_text(markdown, encoding="utf-8")

            # Count h2 sections as proxy for function count
            func_count = markdown.count("\n## ")
            print(f"  -> {out_file.name} ({func_count} functions, {len(markdown)} chars)")
        except Exception as e:
            print(f"  ERROR: {e}")
            import traceback
            traceback.print_exc()

    print(f"\nDone. Markdown files written to {output_dir}/")


if __name__ == "__main__":
    main()
