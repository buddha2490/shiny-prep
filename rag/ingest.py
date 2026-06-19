#!/usr/bin/env python3
"""
Embedding pipeline for the Shiny-prep RAG.

Parses QMD/Markdown files into semantic chunks, generates embeddings
with sentence-transformers, and stores everything in a SQLite database
with FTS5 for hybrid (vector + keyword) search.

Usage:
    python ingest.py <file_or_directory> [--db rag.db] [--model all-MiniLM-L6-v2]
"""

import argparse
import hashlib
import json
import os
import re
import sqlite3
import struct
import sys
from pathlib import Path

import numpy as np
from sentence_transformers import SentenceTransformer

# ---------------------------------------------------------------------------
# Chunking
# ---------------------------------------------------------------------------

def parse_qmd(text: str, source_file: str) -> list[dict]:
    """Split a QMD/Markdown document into semantic chunks by section.

    Strategy:
    - Split on h1/h2/h3 headers (# / ## / ###)
    - Each chunk includes its header hierarchy for context
    - Tables are kept with their parent section
    - YAML front matter is stored as a metadata-only chunk
    """
    lines = text.split("\n")
    chunks: list[dict] = []

    # --- Extract YAML front matter ---
    yaml_block = ""
    content_start = 0
    if lines and lines[0].strip() == "---":
        for i, line in enumerate(lines[1:], start=1):
            if line.strip() == "---":
                yaml_block = "\n".join(lines[1:i])
                content_start = i + 1
                break

    if yaml_block:
        chunks.append({
            "source": source_file,
            "section": "front-matter",
            "headers": [],
            "content": yaml_block,
            "chunk_type": "metadata",
        })

    # --- Walk lines and accumulate sections ---
    header_re = re.compile(r"^(#{1,3})\s+(.+)$")
    current_headers: list[str] = ["", "", ""]  # h1, h2, h3
    current_content_lines: list[str] = []
    current_section = ""
    in_code_fence = False

    def flush():
        nonlocal current_content_lines, current_section
        body = "\n".join(current_content_lines).strip()
        if body:
            header_trail = [h for h in current_headers if h]
            # Build a rich chunk: header breadcrumb + body
            context_prefix = " > ".join(header_trail)
            enriched = f"{context_prefix}\n\n{body}" if context_prefix else body
            chunks.append({
                "source": source_file,
                "section": current_section or "introduction",
                "headers": list(header_trail),
                "content": enriched,
                "chunk_type": "section",
            })
        current_content_lines = []

    for line in lines[content_start:]:
        # Track code fences — don't parse headers inside them
        if line.strip().startswith("```"):
            in_code_fence = not in_code_fence
            current_content_lines.append(line)
            continue

        m = header_re.match(line) if not in_code_fence else None
        if m:
            flush()
            level = len(m.group(1))  # 1, 2, or 3
            title = m.group(2).strip()
            current_headers[level - 1] = title
            # Clear deeper headers
            for j in range(level, 3):
                current_headers[j] = ""
            current_section = title
        else:
            current_content_lines.append(line)

    flush()
    return chunks


def split_large_chunks(chunks: list[dict], max_tokens: int = 300) -> list[dict]:
    """Split chunks that are too large into smaller pieces.

    Uses a rough word-count proxy for tokens (~1.3 tokens/word).
    Splits on paragraph boundaries (double newline).
    """
    result = []
    for chunk in chunks:
        words = chunk["content"].split()
        est_tokens = int(len(words) * 1.3)
        if est_tokens <= max_tokens or chunk["chunk_type"] == "metadata":
            result.append(chunk)
            continue

        # Split on double-newline (paragraph boundaries)
        paragraphs = re.split(r"\n{2,}", chunk["content"])
        current_para_group: list[str] = []
        current_word_count = 0
        part = 1

        for para in paragraphs:
            p_words = len(para.split())
            if current_word_count + p_words > max_tokens / 1.3 and current_para_group:
                result.append({
                    **chunk,
                    "content": "\n\n".join(current_para_group),
                    "section": f"{chunk['section']} (part {part})",
                })
                part += 1
                current_para_group = []
                current_word_count = 0
            current_para_group.append(para)
            current_word_count += p_words

        if current_para_group:
            suffix = f" (part {part})" if part > 1 else ""
            result.append({
                **chunk,
                "content": "\n\n".join(current_para_group),
                "section": f"{chunk['section']}{suffix}",
            })

    return result


# ---------------------------------------------------------------------------
# Embedding helpers
# ---------------------------------------------------------------------------

def embed_chunks(model: SentenceTransformer, chunks: list[dict]) -> np.ndarray:
    """Generate embeddings for all chunks."""
    texts = [c["content"] for c in chunks]
    embeddings = model.encode(texts, show_progress_bar=True, normalize_embeddings=True)
    return np.array(embeddings, dtype=np.float32)


def serialize_vector(vec: np.ndarray) -> bytes:
    """Serialize a float32 vector to bytes for SQLite storage."""
    return struct.pack(f"{len(vec)}f", *vec.tolist())


def content_hash(text: str) -> str:
    return hashlib.sha256(text.encode()).hexdigest()[:16]


# ---------------------------------------------------------------------------
# Database
# ---------------------------------------------------------------------------

def init_db(db_path: str) -> sqlite3.Connection:
    """Create or open the RAG database and ensure schema exists."""
    conn = sqlite3.connect(db_path)
    conn.execute("PRAGMA journal_mode=WAL")
    conn.executescript("""
        CREATE TABLE IF NOT EXISTS chunks (
            id          INTEGER PRIMARY KEY AUTOINCREMENT,
            source      TEXT NOT NULL,
            section     TEXT NOT NULL,
            headers     TEXT NOT NULL,       -- JSON array
            content     TEXT NOT NULL,
            chunk_type  TEXT NOT NULL,
            content_hash TEXT NOT NULL UNIQUE,
            embedding   BLOB NOT NULL,
            dim         INTEGER NOT NULL,
            created_at  TEXT DEFAULT (datetime('now'))
        );

        CREATE TABLE IF NOT EXISTS ingest_log (
            id          INTEGER PRIMARY KEY AUTOINCREMENT,
            source      TEXT NOT NULL,
            chunks_added INTEGER NOT NULL,
            model_name  TEXT NOT NULL,
            created_at  TEXT DEFAULT (datetime('now'))
        );
    """)

    # FTS5 virtual table for keyword search
    # Check if it exists first
    cur = conn.execute(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='chunks_fts'"
    )
    if cur.fetchone() is None:
        conn.execute("""
            CREATE VIRTUAL TABLE chunks_fts USING fts5(
                content, section, source,
                content='chunks',
                content_rowid='id'
            );
        """)
        # Triggers to keep FTS in sync
        conn.executescript("""
            CREATE TRIGGER IF NOT EXISTS chunks_ai AFTER INSERT ON chunks BEGIN
                INSERT INTO chunks_fts(rowid, content, section, source)
                VALUES (new.id, new.content, new.section, new.source);
            END;

            CREATE TRIGGER IF NOT EXISTS chunks_ad AFTER DELETE ON chunks BEGIN
                INSERT INTO chunks_fts(chunks_fts, rowid, content, section, source)
                VALUES ('delete', old.id, old.content, old.section, old.source);
            END;

            CREATE TRIGGER IF NOT EXISTS chunks_au AFTER UPDATE ON chunks BEGIN
                INSERT INTO chunks_fts(chunks_fts, rowid, content, section, source)
                VALUES ('delete', old.id, old.content, old.section, old.source);
                INSERT INTO chunks_fts(rowid, content, section, source)
                VALUES (new.id, new.content, new.section, new.source);
            END;
        """)

    conn.commit()
    return conn


def delete_source(conn: sqlite3.Connection, source: str) -> int:
    """Delete all chunks (and ingest-log rows) for a single source file.

    The FTS triggers keep `chunks_fts` in sync on DELETE, so keyword search
    stays consistent. Returns the number of chunk rows removed.
    """
    cur = conn.execute("DELETE FROM chunks WHERE source = ?", (source,))
    removed = cur.rowcount
    conn.execute("DELETE FROM ingest_log WHERE source = ?", (source,))
    conn.commit()
    return removed


def reset_db(conn: sqlite3.Connection) -> int:
    """Remove every chunk and ingest-log row, leaving the schema intact.

    Use to rebuild the corpus from scratch (e.g. after editing many sources).
    Returns the number of chunk rows removed.
    """
    cur = conn.execute("DELETE FROM chunks")
    removed = cur.rowcount
    conn.execute("DELETE FROM ingest_log")
    conn.commit()
    return removed


def upsert_chunks(
    conn: sqlite3.Connection,
    chunks: list[dict],
    embeddings: np.ndarray,
    source: str,
    model_name: str,
):
    """Insert chunks, skipping duplicates by content hash."""
    added = 0
    for chunk, vec in zip(chunks, embeddings):
        h = content_hash(chunk["content"])
        try:
            conn.execute(
                """INSERT INTO chunks
                   (source, section, headers, content, chunk_type, content_hash, embedding, dim)
                   VALUES (?, ?, ?, ?, ?, ?, ?, ?)""",
                (
                    chunk["source"],
                    chunk["section"],
                    json.dumps(chunk["headers"]),
                    chunk["content"],
                    chunk["chunk_type"],
                    h,
                    serialize_vector(vec),
                    len(vec),
                ),
            )
            added += 1
        except sqlite3.IntegrityError:
            pass  # duplicate content_hash — skip

    conn.execute(
        "INSERT INTO ingest_log (source, chunks_added, model_name) VALUES (?, ?, ?)",
        (source, added, model_name),
    )
    conn.commit()
    print(f"  Inserted {added} new chunks from {source}")


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def ingest_file(
    filepath: str,
    conn: sqlite3.Connection,
    model: SentenceTransformer,
    model_name: str,
    replace: bool = False,
):
    """Ingest a single QMD/MD file.

    When `replace` is True, existing chunks for this source are deleted first so
    an edited file fully replaces its old chunks (content-hash dedup otherwise
    leaves stale chunks behind alongside the new ones).
    """
    path = Path(filepath)
    print(f"Processing: {path.name}")
    if replace:
        removed = delete_source(conn, path.name)
        if removed:
            print(f"  Replaced: removed {removed} existing chunks for {path.name}")
    text = path.read_text(encoding="utf-8")
    chunks = parse_qmd(text, source_file=path.name)
    chunks = split_large_chunks(chunks, max_tokens=300)
    print(f"  {len(chunks)} chunks after splitting")

    if not chunks:
        print("  No chunks to embed — skipping")
        return

    embeddings = embed_chunks(model, chunks)
    upsert_chunks(conn, chunks, embeddings, source=path.name, model_name=model_name)


def main():
    parser = argparse.ArgumentParser(description="Ingest documents into the RAG database")
    parser.add_argument("path", nargs="?", help="File or directory to ingest "
                        "(optional when using --purge-source)")
    parser.add_argument("--db", default=os.path.join(os.path.dirname(__file__), "rag.db"),
                        help="Path to SQLite database (default: rag/rag.db)")
    parser.add_argument("--model", default="all-MiniLM-L6-v2",
                        help="Sentence-transformers model name")
    parser.add_argument("--replace-source", action="store_true",
                        help="Delete each file's existing chunks before re-ingesting "
                             "(clean replace of edited sources, avoids stale chunks)")
    parser.add_argument("--reset", action="store_true",
                        help="Wipe ALL chunks before ingesting (rebuild corpus from scratch)")
    parser.add_argument("--purge-source", metavar="SOURCE", action="append", default=[],
                        help="Delete all chunks for SOURCE (e.g. an orphaned file whose "
                             "source no longer exists) and exit. Repeatable.")
    args = parser.parse_args()

    # --- Purge-only mode: delete named sources, no model load, then exit ---
    if args.purge_source:
        conn = init_db(args.db)
        for src in args.purge_source:
            removed = delete_source(conn, src)
            print(f"Purged {removed} chunks for source: {src}")
        total = conn.execute("SELECT COUNT(*) FROM chunks").fetchone()[0]
        print(f"\nDone. Total chunks in database: {total}")
        conn.close()
        return

    if not args.path:
        parser.error("a path is required unless --purge-source is given")

    model_name = args.model
    print(f"Loading model: {model_name}")
    model = SentenceTransformer(model_name)

    conn = init_db(args.db)

    if args.reset:
        removed = reset_db(conn)
        print(f"Reset: removed {removed} existing chunks\n")

    target = Path(args.path)
    if target.is_file():
        ingest_file(str(target), conn, model, model_name, replace=args.replace_source)
    elif target.is_dir():
        files = sorted(target.glob("**/*.qmd")) + sorted(target.glob("**/*.md"))
        if not files:
            print(f"No .qmd or .md files found in {target}")
            sys.exit(1)
        for f in files:
            ingest_file(str(f), conn, model, model_name, replace=args.replace_source)
    else:
        print(f"Path not found: {target}")
        sys.exit(1)

    # Summary
    total = conn.execute("SELECT COUNT(*) FROM chunks").fetchone()[0]
    print(f"\nDone. Total chunks in database: {total}")
    conn.close()


if __name__ == "__main__":
    main()
