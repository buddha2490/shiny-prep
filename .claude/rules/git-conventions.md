# Git Conventions

How work is branched, committed, and merged in this project. Commit hygiene and
the lockfile rule are intertwined: every commit that changes dependencies must
carry the `renv.lock` update with it (see [renv](renv.md) Rule 5). "Done" is
defined by the Acceptance Gate in `CLAUDE.md`, not by a green commit.

## Rule 1 — Branch off `main`; never commit features straight to it

`main` is the integration branch and should always run. Do feature work on a
branch and merge via a pull request.

| Prefix | Use for |
|--------|---------|
| `feature/<name>` | New functionality |
| `fix/<name>` | Bug fixes |
| `refactor/<name>` | Restructuring with no behavior change |
| `chore/<name>` | Tooling, deps, build, agents/rules/skills |
| `docs/<name>` | Documentation only |

Use short, hyphenated, descriptive names: `feature/ae-listing-filters`,
`fix/null-client-cascade`. One logical change per branch.

## Rule 2 — Conventional Commits

Commit subjects follow `type(scope): subject`:

```
feat(examples): add shinychat + ellmer streaming-chat reference app
fix(mod_rag_chat): guard NULL client from with_error_handling fallback
chore(build): add runtime Acceptance Gate so "done" means the app runs
docs(rules): add git-conventions rule
```

- **Types:** `feat`, `fix`, `refactor`, `chore`, `docs`, `test`, `perf`, `style`.
- **Scope** is optional but encouraged — the module, example, or area touched.
- **Subject** is imperative mood, lower-case, no trailing period, ≤ 72 chars.
- Add a body (blank line, then wrapped prose) when the *why* isn't obvious from
  the subject. Explain the reason for the change, not just the mechanics.

## Rule 3 — Atomic commits: code + tests + lockfile together

A commit is one logical, self-consistent unit. When a change adds or removes a
package, the `renv.lock` update lives in the **same** commit as the code that
needs it — a follow-up "update lockfile" commit breaks `renv::restore()` for
anyone landing between the two (see [renv](renv.md) Rule 5). Likewise, ship a
function and its tests together, not in separate commits.

## Rule 4 — Never commit broken work

Do not commit with failing tests, a failing build, or a feature that does not
pass the **Acceptance Gate** in `CLAUDE.md` (the real app launches and every
user-facing surface works). A commit on a branch should leave that branch in a
runnable state. If you must checkpoint mid-task, say so in the commit body.

## Rule 5 — Claude may auto-commit completed units; never auto-push

When Claude is doing the work in this repo:

- **Commit without asking** once a logical unit is *complete and verified* —
  code written, tests passing, Acceptance Gate met for the change. Group the
  related files (code + tests + `renv.lock`) into one Conventional-Commit.
- **Always branch first** if the current branch is `main` — never auto-commit a
  feature onto `main`.
- **Never push, open a PR, or merge without explicit confirmation.** Pushing is
  outward-facing; the user decides when work leaves the local machine.
- Append a co-authorship trailer to Claude-authored commits when the harness
  convention calls for it.

## Rule 6 — Pull requests

Open a PR to merge a branch into `main`.

- **Title:** the same Conventional-Commit form as the headline commit.
- **Body:** what changed and why, how it was verified (which surfaces were
  exercised per the Acceptance Gate — be honest about coverage), and any
  follow-ups. Link related issues/backlog items.
- Keep PRs scoped to one logical change so review stays tractable.
- Do not merge with a red CI / failing test suite.

## Rule 7 — What never gets committed

Runtime artifacts and the built library stay out of git. The `renv` library,
staging, and sandbox are covered by [renv](renv.md) Rule 4; logs are covered by
[logging](logging.md) Rule 7 (`logs/`, `*.log`). Large regenerable data
(e.g. `examples/02. plotly/gwas_data.csv`) is gitignored and rebuilt from its
generator script. Never commit secrets, credentials, or PHI/PII. When in doubt,
check the relevant `.gitignore` before staging.
