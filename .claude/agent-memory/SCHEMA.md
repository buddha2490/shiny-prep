# Agent Memory Schema (canonical)

This is the **single source of truth** for how every agent in this repo records
persistent memory. All six agents (`shiny-feature-planner`, `shiny-ux-arbiter`,
`shiny-r-architect`, `r-test-developer`, `r-code-reviewer`, `shiny-debugger`)
use the **structured-lite** layout described here. Each agent's definition embeds
a condensed copy of these rules and points back to this file — if the two ever
drift, this file wins.

## Layout

```
.claude/agent-memory/<agent-name>/
  MEMORY.md        # always-loaded INDEX — one line per topic file, no content
  patterns.md      # topic file (frontmatter + many related facts)
  conventions.md   # topic file
  codebase.md      # topic file
  ...
```

Each agent owns its own directory. Memory is **project-scoped and committed to
version control** — tailor every entry to this project, not to generic R/Shiny.

## `MEMORY.md` is an index, not a store

`MEMORY.md` is loaded into the agent's system prompt every session, so it must
stay small. It contains **one line per topic file** and nothing else:

```markdown
# <Agent> — Memory Index
- [Module patterns](patterns.md) — NS, returned reactives, R6 bridge, nesting
- [Confirmed conventions](conventions.md) — 3-file layout, %>%, DT API
```

Rules:
- One line per topic file: `- [Title](file.md) — one-line hook`
- No frontmatter, no memory content (never write a fact directly into the index)
- Lines past ~200 are truncated from the system prompt — but a pure index should
  never approach that. If it does, the memory is being misused as a store.

## Topic files hold the memory

Group facts **semantically by topic**, not chronologically. A topic file may
hold several related facts. Every topic file begins with frontmatter:

```markdown
---
name: <kebab-slug>            # matches the filename stem; used for [[links]]
description: <one-line summary — used to judge relevance when recalling>
type: pattern                 # one of the type vocabulary below
updated: 2026-06-19           # date this file was last meaningfully changed
---

## Some Fact or Pattern
- detail ...
- detail ... (related: [[other-topic]])
```

Cross-link related files with `[[name]]`, where `name` is the other file's
`name:` slug. Link liberally — a `[[name]]` that doesn't resolve yet is fine; it
marks a file worth writing later, not an error.

## Type vocabulary

Exactly one `type:` per file, from this fixed set:

| Type           | Use for |
|----------------|---------|
| `pattern`      | A reusable how-to confirmed in this repo (a module wiring pattern, a plotly recipe, a test scaffold). |
| `convention`   | A house rule / standard this project follows (three-file layout, `%>%`, naming, DT-vs-gt default). |
| `codebase-fact`| Where something lives or what it does — R6 class locations, utility functions, module inputs/outputs, `global.R` data objects, file paths. |
| `pitfall`      | A trap and how to avoid it — namespace masking, UI/server ID mismatch, deprecated API, a reactive prone to looping. |
| `decision`     | An intentional choice and *why* — an architectural call, a deliberate deviation from the style guide, a package selection. |

If a file spans two types, split it or pick the dominant one. Don't invent new
type values.

## Discipline

- **No duplicates.** Before writing, check for an existing topic file to extend.
- **Keep it true.** Update or remove memories that turn out to be wrong or
  outdated. If the user corrects something you stated from memory, fix it at the
  source. If the user says to forget something, remove the entry.
- **Save on explicit request immediately** — no need to wait for a pattern to
  repeat when the user says "remember this."
- **Don't save:** session-only state or in-progress task detail; unverified
  conclusions from skimming a single file; anything already in `CLAUDE.md` or the
  `.claude/rules/`. When the user asks you to save something ephemeral (an
  activity log, a PR list), save what was *surprising or non-obvious* about it,
  not the raw dump.
- **Verify before recommending from memory.** A memory naming a file, function,
  or flag is a claim that it existed *when written*. Before acting on it: check
  the path exists / grep the symbol. For questions about *current* repo state,
  prefer `git log` and reading the code over a frozen memory snapshot.

## Memory vs. plans and tasks

Memory is for facts useful in **future** conversations. For aligning on an
approach mid-task use a Plan; for tracking steps within the current conversation
use Tasks. Don't persist conversation-scoped work as memory.
