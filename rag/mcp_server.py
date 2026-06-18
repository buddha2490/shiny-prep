#!/usr/bin/env python3
"""
MCP server for the Shiny-prep RAG database.

Exposes two tools:
  - rag_search:  Hybrid vector + keyword search
  - rag_list_sources: List all ingested source files

Reads DB_PATH from environment (default: rag/rag.db alongside this script).
"""

import json
import os
import struct
import sqlite3
import math
from pathlib import Path

import numpy as np
from sentence_transformers import SentenceTransformer
from mcp.server.fastmcp import FastMCP

# ---------------------------------------------------------------------------
# Config
# ---------------------------------------------------------------------------

DB_PATH = os.environ.get("DB_PATH", str(Path(__file__).parent / "rag.db"))
MODEL_NAME = os.environ.get("RAG_MODEL", "all-MiniLM-L6-v2")

# ---------------------------------------------------------------------------
# Globals (loaded once at startup)
# ---------------------------------------------------------------------------

_model: SentenceTransformer | None = None
_conn: sqlite3.Connection | None = None


def get_model() -> SentenceTransformer:
    global _model
    if _model is None:
        _model = SentenceTransformer(MODEL_NAME)
    return _model


def get_conn() -> sqlite3.Connection:
    global _conn
    if _conn is None:
        _conn = sqlite3.connect(DB_PATH)
        _conn.row_factory = sqlite3.Row
    return _conn


# ---------------------------------------------------------------------------
# Search helpers
# ---------------------------------------------------------------------------

def deserialize_vector(blob: bytes, dim: int) -> np.ndarray:
    return np.array(struct.unpack(f"{dim}f", blob), dtype=np.float32)


def cosine_similarity(a: np.ndarray, b: np.ndarray) -> float:
    dot = float(np.dot(a, b))
    norm_a = float(np.linalg.norm(a))
    norm_b = float(np.linalg.norm(b))
    if norm_a == 0 or norm_b == 0:
        return 0.0
    return dot / (norm_a * norm_b)


def vector_search(query_vec: np.ndarray, top_k: int = 10) -> list[dict]:
    """Brute-force cosine similarity search over all chunks."""
    conn = get_conn()
    rows = conn.execute(
        "SELECT id, source, section, headers, content, chunk_type, embedding, dim FROM chunks"
    ).fetchall()

    scored = []
    for row in rows:
        vec = deserialize_vector(row["embedding"], row["dim"])
        sim = cosine_similarity(query_vec, vec)
        scored.append({
            "id": row["id"],
            "source": row["source"],
            "section": row["section"],
            "headers": json.loads(row["headers"]),
            "content": row["content"],
            "chunk_type": row["chunk_type"],
            "score": sim,
            "match_type": "vector",
        })

    scored.sort(key=lambda x: x["score"], reverse=True)
    return scored[:top_k]


_STOPWORDS = frozenset(
    "a an the is are was were be been being have has had do does did "
    "will would shall should may might can could and or not no nor "
    "for to of in on at by from with how what which who whom where "
    "when why that this these those it its i my we our they them".split()
)


def _build_fts_query(query: str) -> str:
    """Build an FTS5 query from natural language, stripping stopwords."""
    tokens = [w for w in query.lower().split() if w.strip("?.,!") not in _STOPWORDS]
    tokens = [w.strip("?.,!") for w in tokens]
    tokens = [w for w in tokens if w]
    if not tokens:
        return query.split()[0] if query.split() else ""
    return " OR ".join(f'"{t}"' for t in tokens)


def keyword_search(query: str, top_k: int = 10) -> list[dict]:
    """FTS5 keyword search."""
    conn = get_conn()
    fts_query = _build_fts_query(query)
    try:
        rows = conn.execute(
            """SELECT c.id, c.source, c.section, c.headers, c.content, c.chunk_type,
                      rank
               FROM chunks_fts f
               JOIN chunks c ON c.id = f.rowid
               WHERE chunks_fts MATCH ?
               ORDER BY rank
               LIMIT ?""",
            (fts_query, top_k),
        ).fetchall()
    except sqlite3.OperationalError:
        return []

    results = []
    for row in rows:
        results.append({
            "id": row["id"],
            "source": row["source"],
            "section": row["section"],
            "headers": json.loads(row["headers"]),
            "content": row["content"],
            "chunk_type": row["chunk_type"],
            "score": -row["rank"],  # FTS5 rank is negative (lower = better)
            "match_type": "keyword",
        })
    return results


def hybrid_search(query: str, top_k: int = 5, keyword_weight: float = 0.3) -> list[dict]:
    """Reciprocal Rank Fusion of vector + keyword results."""
    model = get_model()
    query_vec = model.encode(query, normalize_embeddings=True).astype(np.float32)

    vec_results = vector_search(query_vec, top_k=top_k * 2)
    kw_results = keyword_search(query, top_k=top_k * 2)

    # Reciprocal Rank Fusion (k=60)
    k = 60
    rrf_scores: dict[int, float] = {}
    chunk_map: dict[int, dict] = {}

    for rank, r in enumerate(vec_results):
        cid = r["id"]
        rrf_scores[cid] = rrf_scores.get(cid, 0) + (1 - keyword_weight) / (k + rank + 1)
        chunk_map[cid] = r

    for rank, r in enumerate(kw_results):
        cid = r["id"]
        rrf_scores[cid] = rrf_scores.get(cid, 0) + keyword_weight / (k + rank + 1)
        if cid not in chunk_map:
            chunk_map[cid] = r

    sorted_ids = sorted(rrf_scores, key=lambda x: rrf_scores[x], reverse=True)[:top_k]

    results = []
    for cid in sorted_ids:
        entry = chunk_map[cid]
        entry["rrf_score"] = round(rrf_scores[cid], 6)
        # Remove embedding blob from output
        entry.pop("embedding", None)
        results.append(entry)

    return results


# ---------------------------------------------------------------------------
# MCP Server
# ---------------------------------------------------------------------------

mcp = FastMCP(
    "shiny-rag",
    instructions="RAG server for R Shiny developer knowledge base. "
                 "Search documentation about Shiny frameworks, packages, patterns, and pharma considerations.",
)


@mcp.tool()
def rag_search(query: str, top_k: int = 5) -> str:
    """Search the Shiny developer knowledge base.

    Uses hybrid search (semantic + keyword) to find relevant documentation
    chunks about R Shiny development, including frameworks, packages,
    architecture patterns, testing, deployment, and pharma-specific topics.

    Args:
        query: Natural language search query
        top_k: Number of results to return (default 5, max 20)
    """
    top_k = min(max(top_k, 1), 20)
    results = hybrid_search(query, top_k=top_k)

    if not results:
        return "No results found."

    output_parts = []
    for i, r in enumerate(results, 1):
        header_path = " > ".join(r["headers"]) if r["headers"] else r["section"]
        output_parts.append(
            f"--- Result {i} (score: {r['rrf_score']}) ---\n"
            f"Source: {r['source']} | Section: {header_path}\n\n"
            f"{r['content']}\n"
        )

    return "\n".join(output_parts)


@mcp.tool()
def rag_list_sources() -> str:
    """List all documents ingested into the knowledge base, with chunk counts."""
    conn = get_conn()
    rows = conn.execute(
        "SELECT source, COUNT(*) as chunks FROM chunks GROUP BY source ORDER BY source"
    ).fetchall()

    if not rows:
        return "No documents ingested yet."

    lines = ["Ingested sources:"]
    for row in rows:
        lines.append(f"  - {row['source']}: {row['chunks']} chunks")

    total = conn.execute("SELECT COUNT(*) FROM chunks").fetchone()[0]
    lines.append(f"\nTotal chunks: {total}")
    return "\n".join(lines)


if __name__ == "__main__":
    mcp.run()
