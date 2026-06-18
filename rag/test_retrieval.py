#!/usr/bin/env python3
"""
Test retrieval quality of the RAG database.

Runs a set of test queries with expected section matches and reports
precision metrics.
"""

import sys
import os
sys.path.insert(0, os.path.dirname(__file__))

os.environ["DB_PATH"] = os.path.join(os.path.dirname(__file__), "rag.db")

from mcp_server import hybrid_search, get_model

# Each test: (query, list of substrings that should appear in top-3 results)
TEST_QUERIES = [
    (
        "How do I structure a production Shiny app?",
        ["golem", "rhino", "Production"],
    ),
    (
        "What packages are available for interactive tables?",
        ["DT", "reactable", "Table"],
    ),
    (
        "How to do async programming in Shiny?",
        ["future", "promises", "ExtendedTask"],
    ),
    (
        "What testing tools exist for Shiny apps?",
        ["testthat", "shinytest2", "testServer"],
    ),
    (
        "How to deploy a Shiny app with Docker?",
        ["Docker", "rocker", "Container"],
    ),
    (
        "What are pharma-specific Shiny packages?",
        ["teal", "falcon", "safetyGraphics"],
    ),
    (
        "How to use modules in Shiny?",
        ["moduleServer", "NS()", "Module"],
    ),
    (
        "What caching strategies are available?",
        ["bindCache", "memoise", "cachem"],
    ),
    (
        "How to profile Shiny app performance?",
        ["profvis", "reactlog", "tictoc"],
    ),
    (
        "What JavaScript integration options exist?",
        ["shinyjs", "Shiny.setInputValue", "htmlwidgets"],
    ),
    (
        "What visualization packages can I use?",
        ["ggplot2", "plotly", "highcharter"],
    ),
    (
        "How to theme a Shiny application?",
        ["bslib", "bs_theme", "thematic"],
    ),
]


def run_tests():
    print("=" * 70)
    print("RAG RETRIEVAL QUALITY TEST")
    print("=" * 70)

    total_queries = len(TEST_QUERIES)
    queries_with_all_hits = 0
    total_expected = 0
    total_found = 0

    for query, expected_terms in TEST_QUERIES:
        results = hybrid_search(query, top_k=3)
        combined_text = " ".join(r["content"] for r in results)

        found_terms = []
        missed_terms = []
        for term in expected_terms:
            if term.lower() in combined_text.lower():
                found_terms.append(term)
            else:
                missed_terms.append(term)

        hit_rate = len(found_terms) / len(expected_terms)
        total_expected += len(expected_terms)
        total_found += len(found_terms)

        status = "PASS" if hit_rate == 1.0 else ("PARTIAL" if hit_rate > 0 else "FAIL")

        if hit_rate == 1.0:
            queries_with_all_hits += 1

        print(f"\n{'─' * 70}")
        print(f"Query: {query}")
        print(f"Status: {status} ({len(found_terms)}/{len(expected_terms)} terms found)")
        if missed_terms:
            print(f"  Missing: {', '.join(missed_terms)}")
        print(f"  Top results:")
        for i, r in enumerate(results, 1):
            section = " > ".join(r["headers"]) if r["headers"] else r["section"]
            print(f"    {i}. [{r['rrf_score']:.6f}] {section}")

    print(f"\n{'=' * 70}")
    print("SUMMARY")
    print(f"{'=' * 70}")
    print(f"Queries with all expected terms in top-3: {queries_with_all_hits}/{total_queries} "
          f"({queries_with_all_hits/total_queries*100:.0f}%)")
    print(f"Total term recall: {total_found}/{total_expected} "
          f"({total_found/total_expected*100:.0f}%)")
    print(f"{'=' * 70}")

    return total_found / total_expected


if __name__ == "__main__":
    recall = run_tests()
    sys.exit(0 if recall >= 0.8 else 1)
